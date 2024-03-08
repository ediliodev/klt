require_relative 'boot'
require 'rails/all'



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)



module Kollector
  class Application < Rails::Application
  	
  	#config.middleware.delete ActionDispatch::RequestId 

    config.time_zone = 'La Paz' # Ted Timezona ok. manual.
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.x.colours.default = 'Admin2020'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

