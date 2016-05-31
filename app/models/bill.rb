class Bill < ActiveRecord::Base
  include ActiveModel::Dirty

  belongs_to :member
  has_many :vote_tallies, dependent: :destroy

  ### START OF CLASS METHODS ###
  class << self

    # Download bills xml, convert to Hash
    def scrape_bills
      @@bills_xml = open("http://www.parl.gc.ca/LEGISInfo/Home.aspx?language=E&ParliamentSession=42-1&Mode=1&download=xml").read
      bills_hash = Hash.from_xml(@@bills_xml)['Bills']['Bill'] # Scraped Array of bills
      return bills_hash
    end

    def create_bills
      bills_hash = scrape_bills

      bills_hash.each do |bill|
        new_bill = Bill.find_or_create_by(parliament_number: bill["id"])
        new_bill.update_or_create_bill(bill)
      end

    end
    handle_asynchronously :create_bills

  end

  ### END OF CLASS METHODS###
  ### START OF INSTANCE METHODS ###

  def update_or_create_bill(bill)
    self.prefix = bill["BillNumber"]["prefix"] if self.prefix == nil
    self.number = bill["BillNumber"]["number"] if self.number == nil
    self.date_introduced = bill["BillIntroducedDate"].to_date if self.date_introduced == nil
    self.bill_type = bill["BillType"]["Title"][0] if self.bill_type == nil
    self.title_long = bill["BillTitle"]["Title"][0] if self.title_long == nil
    if (self.title_short == nil) && (bill["ShortTitle"]["Title"][0].class == String)
      self.title_short = bill["ShortTitle"]["Title"][0]
    end
    self.last_event = bill["Events"]["LastMajorStageEvent"]["Event"]["Status"]["Title"][0]
    self.last_event_date = bill["Events"]["LastMajorStageEvent"]["Event"]["date"].to_date

    self.member = Member.find_by(
      firstname: bill["SponsorAffiliation"]["Person"]["FirstName"],
      lastname: bill["SponsorAffiliation"]["Person"]["LastName"]
    ) if self.member == nil

    if changed?
      get_vote_tallies
      save!
    end
  end

  def get_vote_tallies
    base_uri = "http://www.parl.gc.ca"
    votes_uri = base_uri + "/LEGISInfo/BillDetails.aspx?Language=E&Mode=1&billId=#{parliament_number}&View=5"
    votes_page = Nokogiri::HTML(open(votes_uri))
    vote_links = votes_page.css(".VoteLink").select { |vote| vote.attr('href') }

    if vote_links.length > vote_tallies.length
      vote_links.each do |vote_link|
        new_tally = VoteTally.create_vote_tally(base_uri + vote_link.attr('href'))
        vote_tallies << new_tally
      end
    end
  end
  handle_asynchronously :get_vote_tallies

  def bill_number
    return "#{prefix}-#{number}"
  end

end
