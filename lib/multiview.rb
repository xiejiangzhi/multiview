require "multiview/version"

require 'active_support'
require 'active_support/core_ext/module/remove_method'
require 'active_support/core_ext'

module Multiview
  require 'multiview/manager'

  class << self
    def manager
      @manager ||= Manager.new({})
    end

    %w{dispatch redispatch}.each do |m|
      define_method m do |*args|
        manager.send(m, *args)
      end
    end
  end
end

