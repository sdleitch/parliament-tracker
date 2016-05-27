class Member < ActiveRecord::Base
  belongs_to :party
  belongs_to :electoral_district
  has_many :bills
  has_many :vote_tallies
  has_many :votes

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, uniqueness: true

  attr_reader :headshot_remote_url
  has_attached_file :headshot
  validates_attachment_content_type :headshot, :content_type => /\Aimage\/.*\Z/

  ### START OF CLASS METHODS ###
  class << self

    # Download members xml, convert to Hash
    def scrape_members
      @@members_xml = open('http://www.parl.gc.ca/Parliamentarians/en/members/export?output=XML').read
      members_hash = Hash.from_xml(@@members_xml)['List']['MemberOfParliament']
      return members_hash
    end

    # Update all members at once. Right now is not used anywhere.
    def create_members
      members_hash = scrape_members

      members_hash.each do |member|
        update_or_create_member(
          member["PersonOfficialFirstName"],
          member["PersonOfficialLastName"],
          member["PersonShortHonorific"],
          member["CaucusShortName"]
        )
      end
    end
    handle_asynchronously :create_members

    # Find MP, if doesn't exist build/scrape with various methods.
    # Called when ElectoralDistrict is built.
    # Also used by Member#get_all_members but that is not currently used.
    def update_or_create_member(firstname, lastname, honorific, party_name)
      member = Member.find_or_create_by(
        firstname: firstname,
        lastname: lastname,
      )
      member.honorific = honorific
      member.party = Party.find_or_create_by(name: party_name)
      member.scrape_member_info
      member.save!
      return member
    end

  end

  ### END OF CLASS METHODS###
  ### START OF INSTANCE METHODS ###

  # Method to scrape MP headshots and emails from www.parl.gc.ca in single method
  def scrape_member_info
    if (headshot_file_name == nil) || (email == nil)

      base_uri = URI("http://www.parl.gc.ca/Parliamentarians/en/members/")
      uri_safe_string = I18n.transliterate("#{firstname}-#{lastname}".delete(" .'"))
      bio = Nokogiri::HTML(open(base_uri + uri_safe_string))

      # scrape headshot
      if headshot_file_name == nil
        headshot_url = URI.escape(bio.css('div.profile img.picture')[0].attr('src'))
        headshot_remote_url(headshot_url)
      end

      # scrape email
      if email == nil
        scrape_email(bio)
      end

    end
  end
  handle_asynchronously :scrape_member_info

  # get MP email from www.parl.gc.ca
  def scrape_email(bio)
    attributes = bio.css('.profile.overview.header a')
    attributes.each do |attribute|
      email = attribute.content.downcase if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.ca\z/ =~ attribute.content
    end
  end

  # get MP headshot
  def headshot_remote_url(url_value)
    headshot = URI.parse(url_value)
    @headshot_remote_url = url_value
  end

  # pass true to turn on honorific
  def fullname
    return "#{firstname} #{lastname}"
  end

  # Possible vote % in previous election
  # http://www.elections.ca/Scripts/vis/PastResults?L=e&ED=13002&EV=99&EV_TYPE=6&QID=-1&PAGEID=28
  # ?ED == FEDNUM in electoral_district.geo. Where does this come from?

end
