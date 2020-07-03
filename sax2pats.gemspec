# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sax2pats/version'

Gem::Specification.new do |spec|
  spec.name          = "sax2pats"
  spec.version       = Sax2pats::VERSION
  spec.authors       = ["Alexander Smith"]
  spec.email         = ["saalexantay@gmail.com"]

  spec.summary       = %q{A Ruby SAX parser of USPTO patent XML}
  spec.description   = %q{A SAX parser of USPTO patent XML data using Ruby's Ox gem}
  spec.homepage      = "https://github.com/doublestranded/sax2pats"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "ox"
  spec.add_development_dependency "saxerator"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "redis-namespace"
  spec.add_development_dependency "dotenv"
  spec.add_runtime_dependency "ox"
  spec.add_runtime_dependency "rubyzip"
  spec.add_runtime_dependency "saxerator"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "redis-namespace"
end
