module ParliamentScraper
  def self.scrape
    Member.create_members
    ElectoralDistrict.create_districts
    Bill.create_bills
    ExpenseReport.create_reports if Date.today.wday == 7
    delay(run_at: Date.today + 1.day).scrape
  end
end
