# encoding: utf-8

require 'achoo'
require 'achoo/plugin'
require 'rubygems';
require 'singleton'

module Achoo
  class PluginManager

    include Singleton

    @@hooks = [
        :before_register_hour_remark,
        :before_register_hour_hours,
        :at_startup,
    ]

    @@hooks.each do |hook|
      define_method("send_#{hook}") do |*args|
        instance_variable_get("@can_#{hook}").each do |plugin|
          plugin.send(hook, *args)
        end
      end
    end

    def initialize
      @plugin_glob = 'achoo/plugin/*'
      @plugins     = []
    end

    def load_plugins
      plugins = Gem.find_files(@plugin_glob, true) # FIX assuming here that array is sorted correctly. Assumption correct?
      Achoo::Plugin.manager = self
      seen = {}
      plugins.each do |p|
        name = File.basename(p)
        require p unless seen[name]
        seen[name] = true
      end

      # All plugins are now registered. Loading the plugins will
      # magically call Achoo::Plugin::inherited for each
      # plugin. inherited() will in turn call register_plugin()

      @plugins = @plugins.select {|p| p.state_ok?; p }

      @@hooks.each do |hook|
        instance_variable_set("@can_#{hook}", @plugins.find_all do |obj|
                                obj.respond_to?(hook)
                              end)
      end
      
      self
    end

    def register_plugin(klass)
      @plugins.push(klass.new)
    end

  end
end
