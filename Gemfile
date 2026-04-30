source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 7.1.6"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

gem "devise"
gem "devise-i18n"

gem "image_processing", "~> 1.2"
gem "jbuilder"
gem "ostruct"

gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "propshaft", "~> 1.3"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

gem "faker", group: [:development, :test]
gem "simplecov", require: false, group: :test

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

group :development, :test do
  gem "dotenv-rails"
end
