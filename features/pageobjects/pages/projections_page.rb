class ProjectionsPage < SpinPage
  def initialize(browser,lookup = {})
    @browser = browser
    @lookup = lookup
    @browser.link(:text,'Projections').exists?.should == true
  end

end