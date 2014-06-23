#require_relative 'spin_page'
#require 'rspec-expectations'

class BaseTable < SpinPage
  attr_accessor :saved_path

  def initialize(browser,tableid=nil, territory=nil)
    @browser = browser
    @tableId = tableid
    @dcf_table = DCFTable.new(@browser)
    lookup={}
    super(@browser,lookup)
    @browser.table(:id,@tableId)
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

  def get_all_rows
    terData = Array.new()
    i=0
    @browser.table(:id=>@tableId).rows.each do |row|
      terData[i] = row.cell(:index=>0).text
      i=i+1
    end
    terData
  end

  def verify_cell_and_text_exists_with_id(id,text)
    row = @browser.table(:id=>@tableid).row(:id=>id)
    row.exists?.should == true
    row.cell(:index=>0).text.strip.should == text
  end

  def getdata(tableid,browser)
    ar = Array.new();
    correction = 1;
    row_count = browser.table(:id=>tableid).rows.length-1
    column_count = browser.table(:id=>tableid).row.cells.length-1

    if(row_count>20)
      row_count=20
    end

    for rowindex in 1..row_count#browser.table(:id=>tableid).rows.length-1#starts from 0
      ar[rowindex-1] = Hash.new

      for colindex in 0..column_count#browser.table(:id=>tableid).row.cells.length-1
        #ar[k][j] = Hash.new
        # if(page.main.table(:id=>tableid).row(:index=>rowindex-1).cell(:index=>colindex-1).exists?)
        header = browser.table(:id=>tableid).row(:index=>0).cell(:index=>colindex).text
        ar[rowindex-1][header] =  browser.table(:id=>tableid).row(:index=>rowindex).cell(:index=>colindex).text
        #replace the decimals
        #ar[rowindex][colindex] = ar[rowindex][colindex].gsub(".00","").gsub(",","")
        # else
        #   ar[rowindex][colindex] = ""
        # end
        puts "row index ="+rowindex.to_s+" col index ="+colindex.to_s+" header :"+header+" Data is:"+ar[rowindex-1][header]
      end
    end
    ar
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
