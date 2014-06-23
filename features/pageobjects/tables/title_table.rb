require 'enumerator'

class TitleTable
  include Enumerable
    def initialize(table)
      @table = table
    end

    def count
        @table.row_count
    end

   def first_row
      TitleResult.new(@table.rows[1])
    end

    def eachrow
      first = true
      @table.rows.each do |result_row|
        if(first)
          first = false
          next
        end
        yield TitleResult.new(result_row)
      end
    end

  def first
    self.each do |row|
      return row
    end
  end

    class TitleResult
      def initialize(row)
        @row = row
      end

      def name
        @row[0].link(:index,0).text
      end

      def sales_link
        @row[0].link(:class,'salesProjection')
      end

      def investment_link
        @row[0].link(:class,'investmentDCF')
      end

      def genre
        @row[1].text
      end

      def proposal_type
        @row[2].text
      end

      def channel
        @row[3].text
      end

      def tranmission_year
        @row[4].text
      end

       def status
        @row[5].element(:index=>0).attribute('alt')
    end
  end
  end
