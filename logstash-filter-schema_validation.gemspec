Gem::Specification.new do |s|
  s.name          = 'logstash-filter-schema_validation'
  s.version       = '0.2.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Validate event schema with JSON Schema.'
  s.description   = 'Validate event schema with JSON Schema with json-schema ruby library.'
  s.homepage      = 'https://github.com/ebuildy/logstash-filter-schema_validation'
  s.authors       = ['Thomas Decaux']
  s.email         = 't.decaux@qwant.com'
  s.require_paths = ["lib", "vendor/jar-dependencies"]

  # Files
  s.files = Dir["lib/**/*","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "vendor/jar-dependencies/**/*.jar", "vendor/jar-dependencies/**/*.rb", "VERSION", "docs/**/*"]
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'jar-dependencies', '~> 0.3.4'
  s.add_development_dependency 'logstash-devutils'

  s.platform = "java"
end
