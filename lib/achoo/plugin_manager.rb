# encoding: utf-8

require 'achoo'
require 'achoo/plugin'
require 'rubygems';

module Achoo
  class PluginManager

    @@hooks = [
        :before_register_hour_remark,
        :before_register_hour_hours,
        :at_startup,
    ]

    @@hooks.each do |hook|
      define_method("send_#{hook}") do
        instance_variable_get("@can_#{hook}").each do |plugin|
          plugin.send(hook)
        end
      end
    end

    def load_plugins
      plugins = Gem.find_files("achoo/plugin/*", true)
      Achoo::Plugin.manager = self
      plugins.each do |p|
        require p
      end

      # All plugins are now registered. Loading the plugins will
      # magically call Achoo::Plugin::inherited for each
      # plugin. inherited() will in turn call register_plugin()

      @@hooks.each do |hook|
        instance_variable_set("@can_#{hook}", @plugins.find_all do |obj|
                                obj.respond_to?(hook)
                              end)
      end
      
      self
    end

    def register_plugin(klass)
      puts "New plugin found: #{klass}"
      @plugins ||= []
      @plugins.push(klass.new)
    end

  end
end
