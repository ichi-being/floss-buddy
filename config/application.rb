require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    config.generators do |g|
      g.helper false
      g.test_framework nil
      g.skip_routes true
    end

    # default localeを日本語に設定
    config.i18n.default_locale = :ja
    # タイムゾーンを東京に設定
    config.time_zone = 'Tokyo'
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
