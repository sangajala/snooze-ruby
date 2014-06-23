When /^I click the '(.+)' button$/i do |button_id|
	browser.button(button_id).click
end

Then /^I should see the validation error '(.+)'$/i do |error_msg|
	browser.text.should.match(/error_msg/i)
end

Then /^I should see the '(.+)' page$/ do |page_text|
	browser.text.should.match(/page_text/i)
end

When /^I type '(.+)' into the '(.+)' field$/i do |text, field|
	browser.text_field(:id, field).set(text)
end

When /^I select '(.+)' in the '(.+)' dropdown list$/i do |selectedText, dropDownlistID|
	browser.select_list(:name, dropDownlistID).select(selectedText)	
end

When /^I check the '(.+)' checkbox$/ do |checkboxID|
	browser.checkbox(:id, checkboxID).set
end