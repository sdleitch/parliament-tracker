class Bill < ActiveRecord::Base
  include ActiveModel::Dirty

  belongs_to :member
  has_many :vote_tallies, dependent: :destroy

  ### START OF CLASS METHODS ###
  class << self

    # Download bills xml, convert to Hash
    def scrape_bills
      @@bills_xml = open(BASE_PARLIAMENT_URI + "/LEGISInfo/Home.aspx?language=E&ParliamentSession=42-1&Mode=1&download=xml").read
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

    scrape_bill_page if changed?
    save! if changed?
  end

  def scrape_bill_page
    bill_uri = BASE_PARLIAMENT_URI + "/LEGISInfo/BillDetails.aspx?Language=E&Mode=1&billId=#{parliament_number}&View=5"
    bill_page = Nokogiri::HTML(open(bill_uri))

    get_vote_tallies(bill_page)
    get_latest_publication(bill_page)
  end

  def get_vote_tallies(bill_page)
    vote_links = bill_page.css(".VoteLink").select { |vote| vote.attr("href") }

    if vote_links.length > self.vote_tallies.length
      vote_links.each do |vote_link|
        new_tally = VoteTally.create_vote_tally(BASE_PARLIAMENT_URI + vote_link.attr("href"))
        self.vote_tallies << new_tally
      end
    end
  end
  handle_asynchronously :get_vote_tallies

  def get_latest_publication(bill_page)
    begin
      latest_publication_uri = bill_page.at_css(".BillPublicationMenu > a:nth-child(1)").attr("href")
      doc_id = CGI::parse(latest_publication_uri)["DocId"][0].to_i
      publication_xml = open(BASE_PARLIAMENT_URI + "/HousePublications/Publication.aspx?Language=E&Mode=1&DocId=#{doc_id}&xml=true").read
      publication_hash = Hash.from_xml(publication_xml)["Bill"]
      self.summary = publication_hash["Introduction"]["Summary"]["Provision"]["Text"]
    rescue
      self.summary = "The electronic version of the bill is currently not available."
    end
  end
  handle_asynchronously :get_latest_publication

  def bill_number
    return "#{prefix}-#{number}"
  end

end
