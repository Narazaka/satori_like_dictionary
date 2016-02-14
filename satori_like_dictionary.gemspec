# coding: utf-8
lib = File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "satori_like_dictionary"
  spec.version       = "0.0.6"
  spec.authors       = ["Narazaka"]
  spec.email         = ["info@narazaka.net"]

  spec.summary       = %q{Satori like dictionary for Ukagaka SHIORI subsystems}
  spec.description   = %q{Satori like dictionary for Ukagaka SHIORI subsystems}
  spec.homepage      = "https://github.com/Narazaka/satori_like_dictionary"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.7.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "yard", "~> 0.8.7"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "codecov", "~> 0.1"
  spec.add_dependency "nano_template", ">= 0.0.3"
end
