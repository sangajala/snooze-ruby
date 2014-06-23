#require 'rspec-expectations'
class DCFTable
  def initialize(browser)
    @raw_html_table = Nokogiri::HTML(browser.html).css('#dcfTable')
    @browser = browser
    @tx_years = ['2010', '2011', '2012', '2013', '2014', '2015', '2016','2017']
    @formats = ['FreeTV', 'PayTV', 'GlobalChannels', 'VOD', 'Format','DVDLicensing','EST']
  end

  def verify_comments_against_sample(sample_comment, territory)
    @formats.each do |format|
      element_key = territory + format + 'Comment'
      @raw_html_table.css('#'+element_key).text.include? (sample_comment)
    end
  end

  def valid_territory_id(territory)
    territory.gsub(/\s+/, "").gsub(/\//, "")
  end

  def verify_format_is_thousand_separated(string_value)
    string_value.should == DCFTable.add_thousand_separators(DCFTable.get_amount(string_value))
  end

  def verify_projections_are_comma_thousand_separated(input_data, territory)
    territory_id = valid_territory_id(territory)
    verify_txyear_territory_total(territory_id){|txyear_territory_total| verify_format_is_thousand_separated(txyear_territory_total)}
    verify_territory_total(territory_id){|territory_total| verify_format_is_thousand_separated(territory_total)}
    verify_format_projections(input_data, territory_id) { |projection, expected_projection| projection.should == DCFTable.add_thousand_separators(expected_projection) }
    verify_format_total(input_data, territory_id) { |total, expected_total| verify_format_is_thousand_separated(total) }
  end

  def verify_table_header_contains_text(value)
    @browser.table(:id=>'dcfTable').row(:index,0).text.include? (value)
  end

  def verify_against_sample(input_data, territory)
    territory_id = valid_territory_id(territory)
   # verify_format_projections(input_data, territory_id) { |projection, expected_projection| DCFTable.get_amount(projection).should == expected_projection.round.to_i }
   # verify_format_total(input_data, territory_id) { |total, expected_total| (DCFTable.get_amount(total) - expected_total).abs.should < 5; }
  end


  def verify_territory_total(territory_id)
    territory_total_key = territory_id + 'Total'
    territory_total = @raw_html_table.css('#'+territory_total_key).text
    yield(territory_total)
  end

  def verify_txyear_territory_total(territory_id)
    for j in (0..(@tx_years.length()-1))
      txyear_territory_total_key = territory_id + @tx_years[j]+'Total'
      txyear_territory_total = @raw_html_table.css('#'+txyear_territory_total_key).text
      yield(txyear_territory_total)
    end
   end

  def verify_format_total(input_data, territory_id)
    for i in (0..(@formats.length() -1))
      format = @formats[i]
      total_key = territory_id + format+'Total'
      total = @raw_html_table.css('#'+total_key).text
      yield(total, input_data[i].get_sum())
    end
  end

  def verify_format_projections(input_data, territory_id)
    for i in (0..(@formats.length() -1))
      format = @formats[i]
      for j in (0..(@tx_years.length()-1))
        tx_year = @tx_years[j]
        element_key = territory_id + format + tx_year
        projection = @raw_html_table.css('#'+element_key).text
        yield(projection, input_data[i][j])
      end
    end
  end

  def get_territory_data(territory_id)
   input_data = [[]]

    for i in (0..(@formats.length() -1))
      format = @formats[i]
      input_data[i] = Array.new
      for j in (0..(@tx_years.length()-1))
        tx_year = @tx_years[j]
        element_key = territory_id + format + tx_year
        input_data[i][j] = @raw_html_table.css('#'+element_key).text.strip.gsub(',','').to_s
       # yield(projection, input_data[i][j])
      end
    end
    return input_data
  end

  def get_year_totals(territory_id)
    input_data = Array.new

   # for i in (0..(@formats.length() -1))
     # format = @formats[i]
     # input_data[i] = Array.new
      for j in (0..(@tx_years.length()-1))
        tx_year = @tx_years[j]
       # element_key = territory_id + format + tx_year border_bottom
        input_data[j] = @browser.table(:id,'dcfTable').row(:class,'border_bottom').cell(:index,j+1).text.strip.gsub(',','').to_s

        # yield(projection, input_data[i][j])
      end
   # end
    return input_data
  end

  def get_territory_totals(territory_id)
    input_data = Array.new
    for i in (0..(@formats.length() -1))
      format = @formats[i]
      element_key = territory_id + format + 'Total'
      input_data[i] = @raw_html_table.css('#'+element_key).text.strip.gsub(',','').to_s
      # yield(projection, input_data[i][j])
    end
    return input_data
  end

  def DCFTable.get_amount(string_value)
    string_value.gsub(',', '').to_i
  end

  def DCFTable.add_thousand_separators(number)
    number.to_s =~ /([^\.]*)(\..*)?/
    int, dec = $1.reverse, $2 ? $2 : ""
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end


end

class DCFRow
  attr_accessor :projections, :row_total

  def initialize
    @projections = []
  end

  def load_projections(row)
    (2..row.column_count-1).each do |projection_cell_index|
      @projections.push(DCFTable.get_amount(row[projection_cell_index].text))
    end

    @row_total = DCFTable.get_amount(row[row.column_count].text)
  end

end
