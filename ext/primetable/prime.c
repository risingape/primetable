#include <ruby.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <pthread.h>

// SSE intrinsics
#include <xmmintrin.h>
#include <smmintrin.h>

// magic number - the slice size
#define SLICE (16*1024)

// mutex to protect the index of the current slice
// and the total number of primes found so far
pthread_mutex_t current_lock;
pthread_mutex_t found_primes_lock;


/*
 * The arguments passed to each of the threads encapsulated in a structure.
 */
struct thread_args {
    int32_t current;   // the current slice, protected by a mutex
    int32_t** primes;    // the primes we found
    int32_t* primesFound;      // the number of primes we found
    int32_t totalFound;
    int32_t nPrimes;  // primes to be found
    int32_t slices;
};


/*
 * 32-bit block wise Erastosthenes sieve
 * This function computes a single block
 * We can find at most (end - start + 1 / 2) primes in a block
 * we need 2 arrays of this size
 * initialise to 1 via memset
 */
void erastosthenesSlice(int32_t start, int32_t end, int8_t* isPrime, int32_t* nPrimes, int32_t* primes) {
    int32_t i = 0;
    int32_t j = 0;
    int32_t s = 0;

  __m128i incv;
    
    __m128i jv;
    int32_t* jvP = (int32_t*)&jv;
    __m128i sv = _mm_set1_epi32(start);
    __m128i ev = _mm_set1_epi32(end / 2);
    
    __m128i compv;
    int32_t* compvP = (int32_t*)&compv;

    for(i = 3; i * i <= end; i += 2) {

        if(i >= 9 && i % 3 == 0) continue;
        if(i >= 25 && i % 5 == 0) continue;
        if(i >= 49 && i % 7 == 0) continue;
        if(i >= 121 && i % 11 == 0) continue;

        // set the correct starting point for the inner loop
        s = ((start + i - 1) / i) * i;
        if(s < i * i) s = i * i;
        if(s % 2 == 0) s += i; // we need an odd start value
        
        /*
         * SSE version of the inner loop. The SSE registers are 128-bit wide. 
         * Regarding 32-bit this gives a vector length of 4. Basically, we are
         * simply unrolling 4 iterations of the loop each time.
         */
        
        // set up the increment vector outside the loop        
        incv = _mm_set1_epi32(i);
        incv = _mm_mullo_epi32(incv, _mm_set_epi32(0, 2, 4, 6));   
        incv = _mm_sub_epi32(incv, sv);

        for(j = s; j <= end; j += 8 * i) {
            // compute j
            jv = _mm_set1_epi32(j);
            jv = _mm_add_epi32(jv, incv);
            jv = _mm_srli_epi32(jv, 1);

            // check if we are beyond the array limits
            compv = _mm_cmplt_epi32(jv, ev);

            if(compvP[3]) isPrime[jvP[3]] = 0;
            if(compvP[2]) isPrime[jvP[2]] = 0;
            if(compvP[1]) isPrime[jvP[1]] = 0;
            if(compvP[0]) isPrime[jvP[0]] = 0;
        }

    }
   
    // collect the found primes
    // special case for i = 0 and start <= 2
    if(start <= 2 ) {
        primes[0] = 2;
        (*nPrimes) = 1;
    } else {
        if(isPrime[0]) {
            primes[0] = start;
            (*nPrimes) = 1;
        } else {
            (*nPrimes) = 0;
        }
    }

    for(i = 1; i < ((end - start + 1) >> 1); i ++) {
        if(isPrime[i]) {
            primes[*nPrimes] = (i << 1) + start;    
            (*nPrimes) ++;
        }
    }
   
    return;
}


// the worker thread
void* worker(void *targs) {
  //thread_args
    struct thread_args *_args = (struct thread_args*)targs;
    int32_t current = 0;
    int8_t* isPrime;

    isPrime = (int8_t*)malloc( (SLICE + 1) / 2 * sizeof(int8_t) );
 
    // get the initial slice
    pthread_mutex_lock(&current_lock);
    current = _args->current;
    _args->current ++;
    pthread_mutex_unlock(&current_lock);

    while(current < _args->slices && _args->totalFound < _args->nPrimes) {
       
        //printf("Thread %u crunching slice %d.\n", pthread_self(), current);
        memset(isPrime, 1, (SLICE + 1) / 2 * sizeof(int8_t));

        // find the primes
        erastosthenesSlice(current * SLICE + 1, (current + 1) * SLICE, isPrime, &(_args->primesFound[current]), _args->primes[current]);

        // update the number of primes we found by all threads so far
        pthread_mutex_lock(&found_primes_lock);
        _args->totalFound += _args->primesFound[current];
        pthread_mutex_unlock(&found_primes_lock);

        //update the slice ID for the next iteration
        pthread_mutex_lock(&current_lock);
        current = _args->current;
        _args->current ++;
        pthread_mutex_unlock(&current_lock);
    }

    pthread_exit(NULL);
}


/*
 * pthread wrapper code
 * The idea is to implement a very simple load balancing.
 * It is obvious that not all slices take the same number of operations.
 * So, whenever a slice is done assign the thread another one until we are done;
 *
 * The problem is, we do not know in advance how many slices there will be
 *
 * Use the prime number theorem to guide the memory allocation? 
 */
void generatePrimes(int32_t nPrimes, int32_t* primes) {

    // all the arrays we need
    pthread_t* threads; // list of thread IDs

    // other variables
    int32_t tmp; // the length of our search space (will be padded)
    int32_t i = 0;
    //int32_t j = 0;

    // get the number of cores
    int32_t numCores = sysconf (_SC_NPROCESSORS_ONLN);
    //printf("Generate primes us %d threads.\n", numCores);

    // structure to hold data to be passed to the threads
    struct thread_args targs;

    /*
     * Fill the thread args structure
     */
    targs.current = 0;

    // approximate the search space for the memory allocation by the prime-counting function
    tmp = (int32_t)(1.2 * (float)nPrimes * logf((float) nPrimes));
    targs.slices = ceilf(tmp / (float)SLICE);
    //printf("Estimated search space: %d, number of slices: %d\n", tmp, targs.slices);

    // allocate the arrays
    targs.primes = (int32_t**)malloc(targs.slices * sizeof(int32_t*));
    for(i = 0; i < targs.slices; i ++) {
        targs.primes[i] = (int32_t*)malloc((SLICE + 1) / 2 * sizeof(int32_t));
    }
    targs.primesFound = (int32_t*)malloc(targs.slices * sizeof(int32_t));
    
    targs.totalFound = 0;
    targs.nPrimes = nPrimes;

    /*
     * Start the threads and wait for them to finish
     */
    threads = (pthread_t*)malloc(numCores * sizeof(pthread_t*));
    for(i = 0; i < numCores; i ++) {
        //printf("Staring thread %d.\n", i);
        if( pthread_create(&(threads[i]), NULL, worker, &targs) != 0) {
            rb_raise(rb_eThreadError, "primes.c: Error starting worker thread");
        } 
    }

    // wait until all threads are done
    //while(targs.current < targs.slices && targs.totalFound < nPrimes) {
        // do nothing
    //}

    // join all threads
    for(i = 0; i < numCores; i ++) {
        if( pthread_join(threads[i], NULL) != 0 ) {
            // report error
             rb_raise(rb_eThreadError, "primes.c: Error joining worker thread");    
        }
    }

    // handle the results
    int32_t leftSpaces = nPrimes;
    i = 0;
    while(leftSpaces > 0) {
        memcpy(&primes[nPrimes - leftSpaces], targs.primes[i], ((leftSpaces >= targs.primesFound[i]) ? targs.primesFound[i] : leftSpaces) * sizeof(int32_t));
        leftSpaces -= targs.primesFound[i];
        i++;
    }

    // clean-up
    for(i = 0; i < targs.slices; i ++) {
        free(targs.primes[i]);
    }
    free(targs.primes);
    free(targs.primesFound);
    free(threads);
      
    return;
}


/*
 * The Ruby binding
 */
static VALUE prime_generate(VALUE self, VALUE ruby_number) {
  int32_t i = 0;
  int32_t nPrimes = 0;
  int32_t* primes;

  // handle input argument
  // we only have to check the type since our ruby part
  // does only accept positve integers
  Check_Type(ruby_number, T_FIXNUM);
  nPrimes = NUM2INT(ruby_number);
  
  if(nPrimes < 2) { 
      rb_raise(rb_eArgError, "primes.c: invalid argument, minimum the first 2 primes are computed.");
  }
  
  primes = malloc(nPrimes * sizeof(int32_t));
  generatePrimes(nPrimes, primes);
  
  VALUE retArray = rb_ary_new2(nPrimes);

  for(i = 0; i < nPrimes; i ++) {
      rb_ary_store(retArray, i, INT2NUM(primes[i]));
  }

  free(primes);

  return( retArray );
}

VALUE klass;

/* ruby calls this to load the extension */
void Init_primetable(void) {
  /* assume we haven't yet defined the class Prime */
  klass = rb_define_class("Prime", rb_cObject);

  /* the primes_generate function can be called
   * from ruby as "Prime.generate" with 1 argument*/
  rb_define_method(klass, "generate", prime_generate, 1);
}



