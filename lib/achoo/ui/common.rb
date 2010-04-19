require 'achoo/term'
require 'achoo/ui'

module Achoo
  module UI
    module Common

      def confirm
        answer = Term::ask "Submit? [Y/n]"
        answer.downcase!
        return answer == 'y' || answer == ''
      end

    end
  end
end


