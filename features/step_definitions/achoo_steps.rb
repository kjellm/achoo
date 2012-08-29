@announce
Given /^achoo is started$/ do
  rc_file = File.dirname(__FILE__) << '/dot_achoo'
  File.chmod(0600, rc_file)
  cmd = 'achoo --log --rcfile ' << rc_file
  steps %{When I run `#{cmd}` interactively}
end

When /^I choose lock month from the menu$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I type "([^"]*)" to select the month$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I cancel the request$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I quit$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

