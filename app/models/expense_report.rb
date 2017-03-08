class ExpenseReport < ActiveRecord::Base
  belongs_to :member

  class << self

    def scrape_expense_reports
      @@expense_reports_xml = open('http://www.parl.gc.ca/PublicDisclosure/MemberExpenditures.aspx?FormatType=XML').read
      expenses_hash = Hash.from_xml(@@expense_reports_xml)["MemberExpenditureReports"]
    end

    def create_reports
      expenses_hash = scrape_expense_reports

      start_date = expenses_hash["startDate"]
      end_date = expenses_hash["endDate"]

      reports = expenses_hash["Report"]

      reports.each do |report|
        member = Member.find_by(
        firstname: report["Member"]["firstName"],
        lastname: report["Member"]["lastName"]
        )
        p member
      end
    end

  end
end
