require "active_record/railtie"

module Dummy
  class Application < Rails::Application
    config.api_only = true
    config.eager_load = false
    config.enable_reloading = false
    config.cache_store = :null_store
  end
end
