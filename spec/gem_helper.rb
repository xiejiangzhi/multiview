require "bundler/setup"

require 'rails'
require 'action_controller/railtie'

require 'pry'
require 'logger'

require "spec_helper"
require "multiview"


Dir[File.expand_path('../support/**/*.rb', __FILE__)].each {|f| require f }

Rails.logger = Logger.new('/dev/null')

RSpec.configure do |config|

end

