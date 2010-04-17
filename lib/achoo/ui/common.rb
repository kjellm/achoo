require 'achoo/term'
require 'achoo/ui'

module Achoo::UI::Common

  def confirm
    answer = Achoo::Term::ask "Submit? [Y/n]"
    answer.downcase!
    return answer == 'y' || answer == ''
  end

end


