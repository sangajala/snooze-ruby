module Watir
  class Table2
     def rows()
        first = true
        self.each do |result_row|
          if(first)
            first = false
            next
          end
          yield result_row
        end
     end
   end
end