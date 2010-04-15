require 'achoo/achievo'

module Achoo::Achievo::LoginForm

  def self.login(agent)
    puts "Fetching data ..."
    page = agent.get(RC[:url])

    return if page.forms.empty? # already logged in

    puts "Logging in ..."

    form = page.forms.first
    form.auth_user = RC[:user]
    form.auth_pw   = RC[:password]
    page = agent.submit(form, form.buttons.first)

    if page.body.match(/Username and\/or password are incorrect. Please try again./)
      raise "Username and/or password are incorrect."
    end
  end

end
