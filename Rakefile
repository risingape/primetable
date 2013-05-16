require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rake/testtask'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

spec = Gem::Specification.load('primetable.gemspec')

Bundler::GemHelper.install_tasks

desc "Build the native extension. Please be patient."
Rake::ExtensionTask.new('primetable', spec) do |ext|
  ext.lib_dir = 'lib/primetable'
end

desc "Run the unit tests"
RSpec::Core::RakeTask.new

desc "Run the behaviour tests"
CUKE_RESULTS = 'results.html'
CLEAN << CUKE_RESULTS
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format html -o #{CUKE_RESULTS} --format pretty --no-source -x"
  t.fork = false
end

desc "Generate man page from README.md"
task :man do
  cp 'README.md', 'man/primetable.1.ronn'
  system "ronn --organization='Guido Klingbeil' man/primetable.1.ronn"
  rm 'man/primetable.1.ronn'
end

desc "Generate rdoc documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc","lib/**/*.rb","bin/**/*")
  rd.title = 'primetable - a simple command line tool to compute prime number multiplication tables'
end

task :default => [:compile, :man, :rdoc, :spec, :features]
