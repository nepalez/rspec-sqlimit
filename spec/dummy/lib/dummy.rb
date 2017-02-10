require "active_record"
require "bundler/setup"

module Dummy
  require_relative "dummy/application"
  require_relative "../config/environment"
  require_relative "../app/models/user.rb"
  require_relative "../app/models/post.rb"
end
