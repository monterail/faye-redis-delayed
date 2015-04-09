# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'faye-redis-delayed'
  spec.version       = '0.0.3'
  spec.authors       = ['Dariusz Gertych']
  spec.email         = ['dariusz.gertych@gmail.com']
  spec.description   = %q{Delayed Redis engine backend for Faye}
  spec.summary       = %q{Delayed Redis engine backend for Faye}
  spec.homepage      = 'https://github.com/monterail/faye-redis-delayed'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'faye'
  spec.add_dependency 'faye-redis', '>= 0.2.0'

  spec.add_dependency 'multi_json', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'thin'
  spec.add_development_dependency 'eventmachine'
end
