class SalesProjectionsLookup
  def SalesProjectionsLookup.create(browser, base_url)
    @lookups = Hash.new
    @lookups[/^#{base_url}\/Projection\/Show\?title=/i] = {
        /Title/i => lambda{ browser.h2(:id, /title/i) } ,
        /Genre/i => lambda{ browser.div(:id, /genre/i) }  ,
        /Episodes/i => lambda{ browser.div(:id, /episodes/i) } 
    }
    @lookups
  end
end
