class Member < ActiveRecord::Base
  belongs_to :party
  belongs_to :electoral_district
  has_and_belongs_to_many :parliments

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, uniqueness: true

  # pass true to turn on honorific
  def fullname(honorific=false)
    if (honorific == true) && (self.honorific != nil)
      return "#{self.honorific} #{self.firstname} #{self.lastname}"
    else
      return "#{self.firstname} #{self.lastname}"
    end
  end

  # Update
  def self.get_members
    members_xml = open('http://www.parl.gc.ca/Parliamentarians/en/members/export?output=XML').read
    members = Hash.from_xml(members_xml)
    members = members['List']['MemberOfParliament']

    members.each do |member|
      new_member = Member.find_or_create_by(
        firstname: member["PersonOfficialFirstName"],
        lastname: member["PersonOfficialLastName"],
      )
      new_member.honorific = member["PersonShortHonorific"]
      new_member.scrape_member_info
      new_member.party = Party.find_by(name: member["CaucusShortName"])
    end
  end

  # Scrape MP headshots and emails from www.parl.gc.ca
  def scrape_member_info
    if (self.img_filename == nil) || (self.email == nil)

      base_uri = URI("http://www.parl.gc.ca/Parliamentarians/en/members/")
      uri_safe_string = I18n.transliterate("#{self.firstname}-#{self.lastname}".delete(" .'"))
      bio = Nokogiri::HTML(open(base_uri + uri_safe_string))

      # scrape headshot
      if self.img_filename == nil
        self.scrape_headshot_image(bio, uri_safe_string)
      end

      # scrape email
      if self.email == nil
        self.scrape_email(bio)
      end

    self.save!
    end
  end

  def scrape_headshot_image(bio, filename_without_ext)
    headshot_url = URI.escape(bio.css('div.profile img.picture')[0].attr('src'))
    open("public/headshots/#{filename_without_ext}.jpg", 'wb') do |img|
      img << open(headshot_url).read
      self.img_filename = "#{filename_without_ext}.jpg"
    end
  end

  def scrape_email(bio)
    attributes = bio.css('.profile.overview.header a')
    attributes.each do |attribute|
      self.email = attribute.content.downcase if /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.ca\z/ =~ attribute.content
    end
  end

end
