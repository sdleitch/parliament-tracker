module ParliamentScraper
  def self.scrape
    Member.create_members
    Bill.create_bills
    ElectoralDistrict.create_districts
    delay(run_at: Date.today + 1.day).scrape
  end
end
