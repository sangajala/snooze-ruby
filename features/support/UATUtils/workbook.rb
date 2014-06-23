require 'roo'

module RubyUatFramework

  class Workbook
    def initialize (file_name)
      #@workbook = Spreadsheet::ParseExcel.parse(file_name)
      #@workbook = Spreadsheet::ParseExcel.Parser.parse(file_name)#::XLSX.new(file_name)#, \%options);
      #my $excel = Spreadsheet::XLSX.new(file_name);
      @workbook = Roo::Spreadsheet.open(file_name)
    end

    def self.get_cell_from_file(file_name, row, col, worksheet = 0 )
      Workbook.new(file_name).get_cell_from_workbook(row, col, worksheet = 0 )
    end

    def get_cell_from_workbook(row, col, worksheet = 0 )
      contents = nil
      worksheet = @workbook.sheets[worksheet]
      cell = @workbook.cell(row, col)
      if cell != nil
        contents = cell.to_s#('latin1')
      end
      contents
    end

    def get_formated_cell_from_workbook(row, col, worksheet = 0 )
      contents = nil
      worksheet = @workbook.sheets[worksheet]
      cell = @workbook.cell(row, col)
      if cell != nil
        contents = cell.to_s.gsub(".0","")#('latin1')
      else cell==nil
        contents = ''
      end
      contents
    end

    def get_row_num_from_rowindex(rowindex)
      for i in 1...355
        if(@workbook.cell(i, 1)==rowindex)
          return i
        end
      end
    end

    def read_all
      worksheet = @workbook.sheets[0]
      #cycle over every row
      worksheet.each { |row|
        j=0
        i=0
        if row != nil
          #cycle over each cell in this row if it's not an empty row
          row.each { |cell|
            if cell != nil
              #Get the contents of the cell as a string
              contents = cell.to_s#('latin1')
              puts "Row: #{j} Cell: #{i}> #{contents}"
            end
            i = i+1
          }
        end
      }
    end

	def get_row_from_spread_sheet(search_data)
        worksheet = @workbook.sheets[0]
        worksheet.each do |row|
            if row.map {|cell| cell.to_s rescue nil} == search_data#('latin1')
             return row
            end
        end
        nil
    end

  def get_range_of_values(row_start, row_range, column_start, column_range)
    retdata = [[]]
    k=0;
    l=0;
    for i in row_start...row_start+row_range
      retdata[k] = Array.new
        for j in column_start...column_start+column_range
          retdata[k][l] = get_cell_from_workbook(i,j)
          l=l+1
        end
       l=0;
       k=k+1;
    end
    retdata
  end

  end


end