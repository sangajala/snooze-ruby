require 'enumerator'

class WebTable
  include Enumerable
    def initialize(browser,tableid)
      @browser = browser
      #check if the table object exists
      @browser.table(:id,tableid).exists?.should == true
      #get the table object
      @table = @browser.table(:id,tableid)
    end

    def count
        @table.row_count
    end

    def first_row
      @table.rows[1]
    end

    def first
     self.each do |row|
      return row
     end
    end

    def get_col_count_exec_ends
      @table.row(:index=>0).cells.count-2
    end

  def get_col_count
    @table.row(:index=>0).cells.count
  end

  def get_row_count
    count = @table.rows.count-2
  end

  def get_rows_exclude_headers
    i=0
    j=0
    arData = Array.new()
    count = @table.rows.count
    @table.rows.each do |row|
      if((i!=0)&&(i!=count-1))
        arData[j] = row.text
        j=j+1
      end
      i=i+1
    end
    arData
  end

  def get_row_titles_exclude_headers
    i=0
    j=0
    arData = Array.new()
    count = @table.rows.count
    @table.rows.each do |row|
      if((i!=0)&&(i!=count-1))
        arData[j] = row.cell(:index=>0).text
        j=j+1
      end
      i=i+1
    end
    arData
  end

  def get_col_titles_exclude_ends
    i=0
    j=0
    arData = Array.new()
    firstRow = @table.row(:index=>0).cells

    firstRow.each do |cell|
      if((i!=0)&&(i!=firstRow.count-1))
        arData[j] = cell.text.strip
        j=j+1
      end
      i=i+1
    end
    arData
  end
  def set_projections_in_table(data)
      #get the row number and column number from the array given
      rowscount = data.length
      colcount = data[0].length
      for i in 0...rowscount
       for j in 0...colcount
         puts "Entering the data in row "+i+" and column "+j+" with data "+data[i][j]
         @table.row(:index=>i).cell(:index=>j).set(data[i][j])
       end
     end
  end
    #class TitleResult
    #  def initialize(row)
    #    @row = row
    #  end
    #
    #  def name
    #    @row[1].link(:index,1).text
    #  end
    #
    #  def sales_link
    #    @row[1].link(:class,'salesProjection')
    #  end
    #
    #  def investment_link
    #    @row[0].link(:class,'investmentDCF')
    #  end
    #
    #  def genre
    #    @row[2].text
    #  end
    #
    #  def proposal_type
    #    @row[3].text
    #  end
    #
    #  def channel
    #    @row[4].text
    #  end
    #
    #  def tranmission_year
    #    @row[5].text
    #  end
    #
    #   def status
    #    @row[6].text
    #end

  def get_col_title_by_index(index)
    get_col_titles[index]
  end

  def get_col_titles
    i=0
    j=0
    arData = Array.new()
    firstRow = @table.row(:index=>0).cells
      firstRow.each do |cell|
        arData[j] = cell.text.strip
        j=j+1
      end
     arData
    end
end

