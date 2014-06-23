#require_relative 'spin_page'
#require 'rspec-expectations'

class DVDEditTable < BaseTable
  attr_accessor :saved_path

  def initialize(browser,territory)
    @browser = browser
    @tableId = 'audit'
    #@dcf_table = DCFTable.new(@browser)
    @columns  = ['Changed date', 'Territory', 'Format', 'TX year', 'User','Change type','Old value','New value']
    @columnIds = ['dateOfChange','territory','format','financialYear','user','typeOfChange','oldValue','newValue']
    super(@browser)
    index = (territory=='UK'? 0:1)
    @table = browser.table(:index=>index)
  end

  def get_cell_element(row,column)
    cell_element = @table.row(:index,row).cell(:index,column-1).text_field(:index,0)
    cell_element.exists?.should == true
    cell_element
  end

  def get_cell_data(row,column)
    cell_element = @table.row(:index,row).cell(:index,column-1)
    cell_element.exists?.should == true
    cell_element
  end

  def table_exists
    @browser.table(:id,@tableId).exists?.should == true
  end

  def displays_dcf
    @browser.title.should.match /sales review/i
    @browser.span(:id, /budget/i).should.match /^\&pound;?(?:\d+|\d{1,3}(?:,\d{3})*)(?:\.\d{1,2}){0,1}$/
  end

  def verify_projections_are_comma_thousand_separated(input_data)
     @dcf_table.verify_projections_are_comma_thousand_separated(input_data, @territory)
  end

  def verify_dcf_total_amounts(input_data)
    @dcf_table.verify_against_sample(input_data, @territory)
  end

  def verify_comments(sample_comment)
    @dcf_table.verify_comments_against_sample(sample_comment, @territory)
  end

  def export_dcf_to_excel
    #@saved_path=nil
    puts 'before clicking the link'
   # RubyUatFramework::FileSaveDialogHandler.new do |handler|
    @browser.link(:id, 'exportToExcel').click
    Timeout::timeout(120){@titlename =   @browser.element(:css=>'dt.green').text.strip}
    #def load_link(waittime)
    #  begin
    #    Timeout::timeout(waittime)  do
    #      yield
    #    end
    #  rescue Timeout::Error => e
    #    puts "Page load timed out: #{e}"
    #    retry
    #  end
    #end
    #!
    #  @saved_path = handler.save_to('DCF_Excel_Export.xls')
   # @titlename =   @browser.element(:css=>'dt.green').when_present.text.strip
    $saved_path = $saved_path+"\\"+(@titlename.gsub(" ","_"))+".xlsx"
      puts "@saved_path|#{$saved_path}|"
    puts 'after clicking the link'
  end

  def check_exported_file_successful
    puts "saved path: #{@saved_path}"
    File.exist?(@saved_path).should == true
  end

  def ensure_territory_does_not_exist(territory_name)
    @browser.title.should.match /sales review/i
    @browser.div(:id, /dcf/i).text.should_not include(territory_name)
  end

  def ensure_territory_exists(territory_name)
    @browser.title.should.match /sales review/i
    @browser.div(:id, /dcf/i).text.should include(territory_name)
  end

  def check_if_rows_exists(rownames,tableid)
   # titles_table = TitleTable.new(@browser.table(:id, /Table1/i))
    titles_table = @browser.table(:id,tableid)
    arActData = remove_header_footer_table(titles_table)
    exprows = Array.new
    exprows = rownames.split("|")
    for i in 0..arActData.length-1
      puts "actual data = "+arActData[i]+" and exp data "+exprows[i]+" with row number "+i.to_s+""
      (arActData[i].include? (exprows[i])).should == true
    end
  end

  def get_all_territories
    terData = Array.new()
    i=0
    @browser.table(:id=>'dcfTable').rows(:class=>'territory').each do |row|
      terData[i] = row.cell(:index=>0).text
      i=i+1
    end
    terData
  end

  def verify_cell_and_text_exists_with_id(id,text)
    row = @browser.table(:id=>'dcfTable').row(:id=>id)
    row.exists?.should == true
    row.cell(:index=>0).text.strip.should == text
  end

  def get_cell_data(column_header, rownumber)
    column_number = 0;
    #get the column number of the header given
    column_number = get_column_number(column_header)
    if(column_number==0)
      return
    end
    #get the cell data
    @browser.table(:id=>@tableId).row(:index,rownumber).cell(:index,column_number-1).text
  end

  def get_column_number(column_header)
    i=1
    #get all column headers
    @browser.table(:id=>@tableId).row(:index,0).cells.each do |cell|

      if(cell.text==column_header)
        return i
      end
      i = i+1
    end
  end

  def get_row_count()
    #i=1
    #get all column headers
    @browser.table(:id=>@tableId).rows.length
    #(:index,0).cells.each do |cell|

    #  if(cell.text==column_header)
    #    return i
    #  end
    #  i = i+1
    #end
  end
end
#Given(/^I want to test$/) do
#  i=1;
#  j = 2-1
#  i.should == j
#end
#Given(/^I have declined a pre-existing sales projection$/) do
#
#  step "a title exists and I navigate to projections for the current title"
#  step "I enter some nonempty sales projections"
#  save_sales_projection()
#  decline_projection(decline_comment, territory)
#end
#Then(/^a table with the Name '(.*)' will be present$/) do |text|
#  @browser.text.should match(/#{text}/i)
#end
#
#When(/^save the data in GBP$/) do
#  @territory = 'France'
#  @dcf_table =  DCFTable.new(@browser)
#  @htmldata = @dcf_table.get_territory_data(@territory)
#end
#
#When(/^save the territory totals data in GBP$/) do
#  @territory = 'France'
#  @dcf_table =  DCFTable.new(@browser)
#  @htmldata = @dcf_table.get_territory_totals(@territory)
#end
#
#  When(/^save the year totals data in GBP$/) do
#  @territory = 'France'
#  @dcf_table =  DCFTable.new(@browser)
#  @htmldata = @dcf_table.get_year_totals(@territory)
#  end
#When(/^the '(.*)' section is displayed$/) do   |value|
#  @dcf_table =  DCFTable.new(@browser)
#  @dcf_table.verify_table_header_contains_text(value)
#end
