Given /I navigate to the '(.+)' page/ do |page|
   navigate_to(sales_projections_base_url + "/#{page}")
end

def navigate_to(address)
   browser.goto(address)
end

Then /the '(.+)' span should be '(.*)'/ do | span_id, value|
  span_text_should_include(span_id, value)
end

def span_text_should_include(span_id, value)
   browser.span(:id, /#{span_id}/).text.should include("#{value}")
end

Then /the '(.+)' label should be '(.+)'/ do | label_id, value|
  label_should_include(label_id, value)
end

def label_should_include(label_id, value)
   browser.label(:id, /#{label_id}/).text.should include("#{value}")
end

Then /I click link with text '(.+)'/ do |text|
  click_link_with_text(text)
end

def click_link_with_text(text)
   #if(browser.link(:text, text).exists?)
    browser.link(:text, text).click
  # else
  #   browser.link(:class,'salesProjection').click
  # end
 # sleep(60)
end

def click_link_with_class(text)
#  if(browser.link(:text, text).exists?)
 #   browser.link(:text, text).click
  #else
    browser.link(:class,'salesProjection').click
   # end
end

def refresh_page
 browser.refresh
end

def navigate_to_dcf(title)
  browser.link(:text,title).click
end

def click_on_first_link_in_table(tableid)
  browser.table(:id,tableid).link(:index,0).click
end

Then /I click on the button with value '(.+)'/ do |text|
  click_button_with_value(value)
end

def click_button_with_value(value)
   sleep(30)
   browser.button(:value,value).wait_until_present(60)
   browser.button(:value, value).click
  #
end

def click_button_with_id(id)
  sleep(60)
 # browser.button(:id,id).wait_until_present(60)
  browser.button(:id,id).click
end

Then /I click on the button with name '(.+)'/ do |name|
  click_button_with_name(name)
end

def click_button_with_name(name)
  browser.button(:name, /#{name}/i).click
end

def click_button_with_name_try_multiple(name)
  begin
    browser.button(:name, name).click
    sleep(15)
  rescue Timeout::Error
    #browser.button(:name, /#{name}/i).click
    sleep(15)
  end

end

And /I click on the '(.+)' breadcrumb link/ do  | link_text |
  click_link_with_text(link_text)
end

When /^I navigate to the home page$/ do
  navigate_to(sales_projections_base_url)
end

Given /^I navigate to an (.*) Title '(.*)' as a (.*) for IC date (.*)$/ do |deal_type,title,user,ic_date|
  step "I am logged into SPIN as a '#{user}' user"
  step "I click on the ICDate '#{ic_date}' link"
  step "I click on the Title '#{title}' link"
end