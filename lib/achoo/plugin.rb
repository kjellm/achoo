# encoding: utf-8

require 'achoo'

module Achoo
  class Plugin

    def self.manager=(obj)
      @@manager = obj
    end

    def self.inherited(c)
      @@manager.register_plugin(c)
    end

    def state_ok?; true; end

  end
end
