require 'enumerator'

class SearchResultsTable
  include Enumerable
    def initialize(table)
        @table = table
    end

   def each
      first = true
      @table.each do |result_row|
        if(first)
          first = false
          next
        end
        yield SearchResult.new(result_row)
      end
    end

  class SearchResult
      def initialize(row)
        @row = row
      end

      def ic_date
        @row[2].text
      end

     def title_name
        @row[1].link(:index,1).text
      end

  end


end