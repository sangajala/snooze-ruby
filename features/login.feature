Feature:  Login authorisation for the Sales projection web site

@smoke@in-progress
Scenario: As an authorised Sales Projections Content User I want to see my user name displayed on the front page of the Sales Projections web site
	  Given I am logged into Snooze as an authorised 'Admin' user
	  Then I can see the 'Campaign' link
#      And my user name is displayed on the IC Date List page

@smoke @in-progress
Scenario: An unauthorised Sales Projections Content user navigates to the Sales Projections web site
      Given I am not a SPIN user
      And I navigate to SPIN
	  Then I am directed to a custom error page

