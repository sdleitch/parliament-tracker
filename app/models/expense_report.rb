class ExpenseReport < ActiveRecord::Base
  include ActiveModel::Dirty

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
      quarter = expenses_hash["id"]

      reports = expenses_hash["Report"]

      reports.each do |report|
        total = report['ExpenditureTotals']['Total']['value'].to_i

        member = Member.find_by(
          firstname: report["Member"]["firstName"],
          lastname: report["Member"]["lastName"]
        )

        member_report = ExpenseReport.find_or_create_by(
          member: member,
          quarter: quarter,
          total: total,
          start_date: start_date,
          end_date: end_date
        )

        member_report.save! if member_report.changed?
      end

    end

  end
end
