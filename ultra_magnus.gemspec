# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ultra_magnus/version'

Gem::Specification.new do |spec|
  spec.name          = "ultra_magnus"
  spec.version       = UltraMagnus::VERSION
  spec.authors       = ["Aaron Dufall"]
  spec.email         = ["aald212@gmail.com"]
  spec.summary       = %q{Transforms data structures}
  spec.description   = %q{Task a collection of data a rebuilds is with a clean DSL}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
