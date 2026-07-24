source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Postgres as the primary database for Active Record
gem "pg", "~> 1.5"
# Solid Queue/Cache/Cable still use sqlite3 databases even in an API app
gem "sqlite3", ">= 2.1"

# Token-based authentication [https://github.com/heartcombo/devise]
gem "devise"
gem "devise-jwt"
# Authorization policies [https://github.com/varvet/pundit]
gem "pundit"
# CORS for the React frontend [https://github.com/cyu/rack-cors]
gem "rack-cors"
# Pagination [https://github.com/kaminari/kaminari]
gem "kaminari"
# Rate limiting / throttling [https://github.com/rack/rack-attack]
gem "rack-attack"
# Serve the OpenAPI spec + Swagger UI at /api-docs [https://github.com/rswag/rswag]
gem "rswag-api"
gem "rswag-ui"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec for unit/request/policy specs [https://github.com/rspec/rspec-rails]
  gem "rspec-rails"

  # Generate the OpenAPI spec from RSpec doc specs [https://github.com/rswag/rswag]
  gem "rswag-specs"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Preview sent emails in the browser instead of actually delivering them [https://github.com/ryanb/letter_opener]
  gem "letter_opener"
end
