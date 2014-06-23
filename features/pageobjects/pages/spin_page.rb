class SpinPage

   def initialize(browser,lookup = {})
    @browser = browser
     @lookup = lookup
  end

  def click_on_image(id)
    @browser.element(:id, @lookup[id]).click
  end

  def isTabPresent(tabName)
    @browser.link(:text,tabName).exists?.should == true
  end

   def set_select_list(label, value)
       @browser.select_list(:id => @lookup[label]).select(value)
   end

   def set_text_field_name(label, value)
       @browser.text_field(:name => @lookup[label]).set(value)
   end

   def set_text_field(label, value)
     @browser.text_field(:id => @lookup[label]).set(value)
   end

end
