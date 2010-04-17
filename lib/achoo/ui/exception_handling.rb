require 'achoo/term'
require 'achoo/ui'

module Achoo::UI::ExceptionHandling

  def handle_exception(user_message, e)
    Achoo::Term::warn(user_message) + get_exception_reason(e)
  end

  def handle_fatal_exception(user_message, e)
    abort Achoo::Term::fatal(user_message) + get_exception_reason(e)
  end

  def get_exception_reason(e)
    "\nReason: \n\t" + e.message.gsub("\n", "\n\t") + "\n---\n\t" + e.backtrace.join("\n\t")
  end

end
