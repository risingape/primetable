
require 'mkmf'
$CFLAGS += ' -msse4'
$libdir += '/primetable'
create_makefile('primetable/primetable')

