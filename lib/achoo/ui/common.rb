require 'achoo/term'

class Achoo; class UI; end; end

module Achoo::UI::Common

  def confirm
    answer = Achoo::Term::ask "Submit? [Y/n]"
    answer.downcase!
    return answer == 'y' || answer == ''
  end

end


