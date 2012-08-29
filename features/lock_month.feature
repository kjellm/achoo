Feature: lock month
  As a consultant
  I need to put a lock on a month
  So that my boss sees that I am done registring hours for that month
  
  Scenario: lock month
    Given achoo is started
     When I choose lock month from the menu
      And I type "201003" to select the month
      And I cancel the request
      And I quit
     Then I should see "Cancelled"