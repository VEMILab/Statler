require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/cors'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DartmouthTest
  class Application < Rails::Application
    
    config.web_console.whitelisted_ips = '192.168.1.52'
    
    
    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end


	# www.rubydoc.info/gems/rack-cors/0.2.9 used for reference
	
	
	#config.middleware.use Rack::Cors do
	config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
		allow do
			# We want to allow all origins to access the backend right now, but this can be configured;
			# regular expressions can be used to specify origins and multiple origins can be separated by commas.
			# Recommend: individual institutions limit origins to domains where they are using the plugin.
			origins '*' 
			#origins '141.114.251.243'
			#origins '192.168.1.52', 'www.maine.edu/semantic-annotation-tool' -- etc.
			
			# For development we want to allow all resources to be shared, but can be configured using
			# filepaths and directory names; /etc/filedump/*
			# Recommend: tailor paths to allow access to API files alone.
			resource '/annotators',
				:headers => 'any',
				:methods => [:get, :post]
				
			resource '*', 
				:methods => [:get, :post], #perhaps :options as well?
				:headers => 'any'#,
				#:expose  => ['Our-custom-response-header'],
				#:max_age => 600
		end
	end
				


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
