class DVDPage < SpinPage
  def initialize(browser, territory=nil)
    @browser = browser
    @territory = Territory.new(territory).territory

    lookup =
        {
            'Product Format'=> 'saveRequest_DvdProjections_0__FormatProjections_1__Format',
            'Price Point'=> 'saveRequest.DvdProjections[0].FormatProjections[0].PricePoint',
            'Marketing'=> 'saveRequest.DvdProjections[0].FormatProjections[0].Marketing',
            'First_text' => 'saveRequest.DvdProjections[0].FormatProjections[0].Values[0].Value',
            'First_comment'=>'saveRequest.DvdProjections_0_.FormatProjections_0_.Comment'
        }
    super(@browser,lookup)
  end

  def verify_drop_down_values(id,values, header)
    i = 0
    @browser.select_list(:id,id).options.each do |option|
      if(i!=0)
      option.value.should == values[i-1][header]
      end
      i=i+1
    end
  end

  def verify_excel_link_exists()
    @browser.link(:text,'Export to Excel').exists?.should == true
  end

  def verify_countries(args)
    i=0
      @browser.elements(:class,'projectionInformation').each do |element|
        args[i].should == element.text
        i=i+1
      end
  end

  def verify_table_count(q)
    get_table_count('datesTable').to_s.should == q
  end

  def get_table_count(classname)
  @browser.tables(:class,classname).length
  end

  def verify_table_headers(expdata, actualdata)
    counter = 0
    expdata.each do |row|
      k=0
      row.each do |cell|
        if(cell!='Units by Delivery Year'&&k!=0)
          #ignore
          puts "exp data:"+cell
          actualdata[counter].include?(cell).should == true
        end
       k=k+1
        #if(cell==)
        #row
        #end
        #counter=counter+1

      end
      counter=counter+1
    end
  end
end