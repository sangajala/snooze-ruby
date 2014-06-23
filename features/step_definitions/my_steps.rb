#Given(/^I am logged into SPIN as an authorised 'Sales' user$/) do
#
#end
#Then(/^I can see the 'IC Date List' page$/) do
#
#end
#When(/^my user name is displayed on the IC Date List page$/) do
#
#end
Then(/^I can see the 'Campaign' link$/) do
  sleep 5
  browser.link(:text=>"Campagn").exists?
end