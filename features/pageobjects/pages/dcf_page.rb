require_relative 'spin_page'
#require 'rspec-expectations'

class DCFPage < SpinPage
  attr_accessor :saved_path

  def initialize(browser, territory=nil)
    @browser = browser
    @territory = Territory.new(territory).territory
    @dcf_table = DCFTable.new(@browser)
    lookup =
        {
         'Expand All'=> 'on',
         'Collapse All'=> 'off'
        }
    super(@browser,lookup)
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
    #sleep(30)
   # RubyUatFramework::FileSaveDialogHandler.new do |handler|
    begin
      @browser.link(:id, 'exportToExcel').click
    rescue Timeout::Error
      sleep(60)
    end
    sleep(90)
    #Timeout::timeout(120){@titlename =   @browser.element(:css=>'dt.green').text.strip}
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
    @titlename =   @browser.element(:css=>'dt.green').text.strip
    $saved_path = $saved_path+"\\"+(@titlename.gsub(" ","_"))+".xlsx"
      puts "@saved_path|#{$saved_path}|"
    puts 'after clicking the link'
  end


  def check_exported_file_successful
    puts "saved path: #{$saved_path}"
    File.exist?($saved_path).should == true
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

end
