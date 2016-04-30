class Bill < ActiveRecord::Base
  belongs_to :member
  has_many :vote_tallies


  def bill_number
    return "#{self.prefix}-#{self.number}"
  end

  # Download bills xml, convert to Hash
  def self.get_bills
    @@bills_xml = open("http://www.parl.gc.ca/LEGISInfo/Home.aspx?language=E&ParliamentSession=42-1&Mode=1&download=xml").read
    @@bills = Hash.from_xml(@@bills_xml)['Bills']['Bill'] # Scraped Array of bills
  end

  def self.create_bills(bills=@@bills)
    bills.each do |bill|
      new_bill = Bill.find_or_create_by(parliament_number: bill["id"])

      new_bill.prefix = bill["BillNumber"]["prefix"] if new_bill.prefix == nil
      new_bill.number = bill["BillNumber"]["number"] if new_bill.number == nil
      new_bill.date_introduced = bill["BillIntroducedDate"].to_date if new_bill.date_introduced == nil
      new_bill.bill_type = bill["BillType"]["Title"][0] if new_bill.bill_type == nil
      new_bill.title_long = bill["BillTitle"]["Title"][0] if new_bill.title_long == nil
      if (new_bill.title_short == nil) && (bill["ShortTitle"]["Title"][0].class == String)
        new_bill.title_short = bill["ShortTitle"]["Title"][0]
      end

      new_bill.member = Member.find_by(
        firstname: bill["SponsorAffiliation"]["Person"]["FirstName"],
        lastname: bill["SponsorAffiliation"]["Person"]["LastName"]
      )

      new_bill.save!
    end
  end

  # def get_vote_tallies
  # end
end
