class Member < ActiveRecord::Base
  belongs_to :party
  belongs_to :electoral_district
  has_and_belongs_to_many :parliments
  has_many :bills

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, uniqueness: true

  attr_reader :headshot_remote_url
  has_attached_file :headshot
  validates_attachment_content_type :headshot, :content_type => /\Aimage\/.*\Z/

  def self.get_members
    @@members_xml = open('http://www.parl.gc.ca/Parliamentarians/en/members/export?output=XML').read
    @@members = Hash.from_xml(members_xml)['List']['MemberOfParliament']
  end

  # pass true to turn on honorific
  def fullname(honorific=false)
    if (honorific == true) && (self.honorific != nil)
      return "The #{self.honorific} #{self.firstname} #{self.lastname}"
    else
      return "#{self.firstname} #{self.lastname}"
    end
  end

  # Update all members at once. Right now is not used anywhere.
  def self.create_members(members=@@members)
    members.each do |member|
      Member.update_or_create_member(
        member["PersonOfficialFirstName"],
        member["PersonOfficialLastName"],
        member["PersonShortHonorific"],
        member["CaucusShortName"]
      )
    end
  end

  # Find MP, if doesn't exist build/scrape with various methods.
  # Called when ElectoralDistrict is built.
  # Also used by Member#get_all_members but that is not currently used.
  def self.update_or_create_member(firstname, lastname, honorific, party_name)
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

  # Method to scrape MP headshots and emails from www.parl.gc.ca in single method
  def scrape_member_info
    if (self.headshot_file_name == nil) || (self.email == nil)

      base_uri = URI("http://www.parl.gc.ca/Parliamentarians/en/members/")
      uri_safe_string = I18n.transliterate("#{self.firstname}-#{self.lastname}".delete(" .'"))
      bio = Nokogiri::HTML(open(base_uri + uri_safe_string))

      # scrape headshot
      if self.headshot_file_name == nil
        headshot_url = URI.escape(bio.css('div.profile img.picture')[0].attr('src'))
        self.headshot_remote_url(headshot_url)
      end

      # scrape email
      if self.email == nil
        self.scrape_email(bio)
      end

    end
  end

  # get MP email from www.parl.gc.ca
  def scrape_email(bio)
    attributes = bio.css('.profile.overview.header a')
    attributes.each do |attribute|
      self.email = attribute.content.downcase if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.ca\z/ =~ attribute.content
    end
  end

  # get MP headshot
  def headshot_remote_url(url_value)
    self.headshot = URI.parse(url_value)
    @headshot_remote_url = url_value
  end

end
