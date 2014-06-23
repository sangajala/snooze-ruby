Given(/^I am logged into Snooze(?: as an authorised '(.+)' user)?$/) do |user_type|
  login_as(user_type)
end

Given /I am logged into SPIN as a '(.+)' user$/ do |user_type|
  login_as(user_type)
end

def login_as(user_type=nil)
#  browser.speed = :zippy
  navigate_to(snooze_base_url)
  p browser.title
  #browser.text.should contain("Get Ready to kill boredom")
  browser.link(:text=>"Sign in").click
  browser.text_field(:id => "adminname").set("Admin")
  browser.text_field(:id => "password").set("Admin")
  browser.button(:value=>"Sign in").click

  #browser.(:id,"adminname").type "Admin"
  #browser.link(:text, text).click
end

Given /I am not a SPIN user/ do
  #TO DO
end

And /my user name is displayed on the IC Date List page/ do
   puts "username:" + current_user_name
    browser.text.should match(/#{current_user_name}/i)
end

And /I navigate to SPIN and enter user name '(.+)' and password '(.+)'/ do  |user_name, password|
  @exception_was_thrown = false
  begin
    RubyUatFramework::UnauthorisedDialogHandler.new(30) do |handler|
      handler.navigate browser, sales_projections_base_url
      handler.enter_credentials(user_name, password)
    end
    browser.url.should == sales_projections_base_url + '/Errors/Unauthorised'

  rescue RubyUatFramework::DialogNotHandledException
    @exception_was_thrown = true
  end
end

And /I navigate to SPIN and click '(.+)' when I am prompted to enter my credentials/ do  |button_name|
  @exception_was_thrown = false
  begin
    RubyUatFramework::UnauthorisedDialogHandler.new(30) do |handler|
      handler.navigate browser, sales_projections_base_url
      handler.cancel(sales_projections_qualified_server, sales_projections_server)
    end
    browser.url.should == sales_projections_base_url + '/Errors/Unauthorised'

  rescue RubyUatFramework::DialogNotHandledException
    @exception_was_thrown = true
  end
end

Then /I am directed to a custom error page/ do
  browser.text.should include('Unauthorised')
end


When /^I navigate to SPIN$/ do
  navigate_to(sales_projections_base_url)
  #login_as(user_type)
end
#Given(/^I am logged into SPIN as an authorised 'Sales' user$/) do
#
#end
