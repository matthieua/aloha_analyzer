# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aloha_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "aloha_analyzer"
  spec.version       = AlohaAnalyzer::VERSION
  spec.authors       = ["Matthieu Aussaguel"]
  spec.email         = ["matthieu.aussaguel@gmail.com"]
  spec.description   = %q{Analyze twitter followers languages}
  spec.summary       = %q{Analyze twitter followers languages}
  spec.homepage      = "https://github.com/matthieua/aloha_analyzer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'webmock', '~> 1.17'
  spec.add_development_dependency 'debugger', '~> 1.6'
  spec.add_dependency 'twitter', '~> 5.6'
end
