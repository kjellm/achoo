require 'achoo/temporal'

module Achoo
  module Temporal
    class OpenTimespan < Timespan

      def to_s
        s = super
        s.sub!(/^\([^)]+\)/, '(?+??:??)')
        s.sub!(/- .*$/, '- ?')
        s
      end

    end
  end
end
