# rails_trace_panel.gemspec
Gem::Specification.new do |spec|
  spec.name          = "rails_trace_panel"
  spec.version       = "0.1.0"
  spec.authors       = ["Manuel Albarrán"]

  spec.summary       = "Panel HTML local para trazas de Rails usando ddtrace en modo test."
  spec.description   = "Rails engine que muestra las trazas locales capturadas con ddtrace en modo test en /admin/traces."
  spec.homepage      = "https://github.com/weapp/rails_trace_panel"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.add_dependency "datadog", ">= 2.0"
  spec.add_dependency "railties", ">= 5.2"
  spec.add_dependency "sqlite3"


  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir["lib/**/*", "app/**/*", "config/**/*", "README.md"]
end
