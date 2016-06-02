require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'open-uri'

# to turn accented names into uri-safe Strings
require 'i18n'
I18n.config.available_locales = :en

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ParliamentTracker
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    env_file = File.join(Rails.root, 'config', 'local_env.yml')
    YAML.load(File.open(env_file)).each do |key, value|
      ENV[key.to_s] = value
    end

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :delayed_job

    config.paperclip_defaults = {
      storage: :s3,
      url: ':s3_domain_url',
      path: '/:class/:attachment/:id_partition/:style/:filename',
      s3_credentials: {
        access_key_id: ENV["S3_KEY_ID"],
        secret_access_key: ENV["S3_ACCESS_KEY"],
        bucket: "parliament-tracker-storage"
      }
    }
  end
end
