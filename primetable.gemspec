# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
bin = File.expand_path('../bin', __FILE__)
$LOAD_PATH.unshift(bin) unless $LOAD_PATH.include?(bin)
ext = File.expand_path('../ext', __FILE__)
$LOAD_PATH.unshift(ext) unless $LOAD_PATH.include?(ext)
test = File.expand_path('../test', __FILE__)
$LOAD_PATH.unshift(test) unless $LOAD_PATH.include?(test)

require 'primetable/version'

Gem::Specification.new do |spec|
  spec.name          = "primetable"
  spec.version       = Primetable::VERSION
  spec.authors       = ["Guido Klingbeil"]
  spec.description   = %q{"Prime number multiplication table"}
  spec.summary       = %q{"Simple command line tool computing prime number multiplication tables of the first n primes"}
  spec.homepage      = ""
  spec.license       = "GPL v3 or later"

  spec.files = Dir.glob("ext/**/*.{c,rb}") + Dir.glob("lib/**/*.rb") + Dir.glob("bin/**/*") + Dir.glob("man/**/*") + Dir.glob("[A-Z]*") + Dir.glob("html/**/*")
  spec.extensions << "ext/primetable/extconf.rb"
  spec.executables << "primetable"

  spec.test_files = ["spec"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "ronn"
  spec.add_development_dependency "gem-man"
  spec.add_development_dependency "rspec-expectations"

  spec.add_dependency "rainbow"
  spec.add_dependency "methadone"
  spec.add_dependency "terminal-table"
end
