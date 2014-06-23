class RightsTable
  attr_accessor :rights_table

  def compare_header_row_values (specified_values)
    row_values = @rights_table.row_values(1)
    row_values[1..row_values.length].sort.should == specified_values.split(', ').sort
  end

   def data_rows
    @rights_table.row_count-1
  end
end

class ClearancesTable < RightsTable

  attr_accessor :clearances

  def initialize (browser)
    @browser = browser
    @rights_table = browser.table(:id,/clearances/)
    @clearances = {}
    load_clearances()
  end


  def compare(rights_type,territory,term,notes,description)
    clearance = @clearances["#{rights_type}"]
	
	puts "THIS IS THE COMPARE METHOD CALL"
    puts "I'M COMPARING TERRITORY"
    clearance.territory.should == territory
	puts "I'M COMPARING TERM"
    clearance.term.should == term
	puts "I'M COMPARING NOTES"
    clearance.notes.should == notes
	puts "I'M COMPARING DESCRIPTION"
    clearance.description.should == description
  end

  def load_clearances()
    (2..@rights_table.row_count).each do |row_index|
      rights_type = (@rights_table[row_index][1]).text
      territory = (@rights_table[row_index][2]).text
      description = (@rights_table[row_index][3]).text
      term = (@rights_table[row_index][4]).text
      notes = (@rights_table[row_index][5]).text

      clearance = Clearances.new(rights_type,territory,notes,term,description,false)

      @clearances["#{clearance.rights_type}"] = clearance
    end
  end

end

class RightsOnOfferTable < RightsTable

  attr_accessor :rights_on_offer

  def initialize (browser)
    @browser = browser
    @rights_table = browser.table(:id,/rightsOnOffer/)
    @rights_on_offer = {}
    load_rights_on_offer()
  end


  def compare(rights_type,territory,term,notes)
    right = @rights_on_offer["#{rights_type}"]
    right.territory.should == territory
    right.term.should == term
    right.notes.should == notes
  end

  def load_rights_on_offer()
    (2..@rights_table.row_count).each do |row_index|
      rights_type = (@rights_table[row_index][1]).text
      territory = (@rights_table[row_index][2]).text
      term = (@rights_table[row_index][3]).text
      notes = (@rights_table[row_index][4]).text
      right = RightsOnOffer.new(rights_type,territory,notes,term,10,false)
      
      @rights_on_offer["#{right.rights_type}"] = right
    end
  end

end

class RightsNotOnOfferTable < RightsTable

  attr_accessor :rights_on_offer

  def initialize (browser)
    @browser = browser
    @rights_table = browser.table(:id,/rightsNotOnOffer/)
    @rights_not_on_offer = {}
    load_rights_not_on_offer()
  end


  def compare(rights_type,territory,term,notes)
    right = @rights_not_on_offer["#{rights_type}"]
    right.territory.should == territory
	right.term.should == term
    right.notes.should == notes
  end

  def load_rights_not_on_offer()
    for row_index in 2..@rights_table.row_count
      rights_type = (@rights_table[row_index][1]).text
      territory = (@rights_table[row_index][2]).text
      term = (@rights_table[row_index][3]).text
      notes = (@rights_table[row_index][4]).text
      right = RightNotOnOfferBid.new(rights_type,territory,notes,term,false)

      @rights_not_on_offer["#{right.rights_type}"] = right
    end
  end

end