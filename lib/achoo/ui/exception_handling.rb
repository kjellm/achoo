require 'achoo/term'
require 'achoo/ui'

module Achoo
  module UI
    module ExceptionHandling

      def handle_exception(user_message, e)
        Term::warn(user_message) + get_exception_reason(e)
      end

      def handle_fatal_exception(user_message, e)
        abort Term::fatal(user_message) + get_exception_reason(e)
      end

      def get_exception_reason(e)
        "\nReason: \n\t" + e.message.gsub("\n", "\n\t") + "\n---\n\t" + e.backtrace.join("\n\t")
      end

    end
  end
end
