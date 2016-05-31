module ParliamentScraper
  def self.scrape
    Member.create_members
    ElectoralDistrict.create_districts
    Bill.create_bills
    delay(run_at: Date.today + 1.day).scrape
  end
end
