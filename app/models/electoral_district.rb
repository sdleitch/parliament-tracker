class ElectoralDistrict < ActiveRecord::Base
  include ActiveModel::Dirty

  has_one :member

  # This taken from: stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
  # to match ASCII-removed districts from GeoJSON to real district names
  # This will return the first in a single-element array of hashes of GeoJSON
  @@encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
  }

  ### START OF CLASS METHODS ###
  class << self

    # Download districts xml, convert to Hash
    def scrape_districts
      @@districts_xml = open('http://www.parl.gc.ca/Parliamentarians/en/constituencies/export?output=XML').read
      districts_hash = Hash.from_xml(@@districts_xml)["List"]["Constituency"]
      return districts_hash
    end

    def create_districts
      @@districts_geojson = File.read("public/districts.geojson")
      @@features = parse_geojson
      districts_hash = scrape_districts

      districts_hash.each do |district|
        new_district = ElectoralDistrict.find_or_create_by(
          name: district["Name"],
          province: district["ProvinceTerritoryName"]
        )
        begin
          feature = @@features.select { |feature| feature["properties"]["ENNAME"] == self.name.gsub("—", "--").encode(Encoding.find('ASCII'), @@encoding_options) }.first
          new_district.geo = feature.to_json if new_district.geo == nil
          new_district.fednum = feature["properties"]["FEDNUM"] if new_district.fednum == nil
        rescue
          puts "Could not find FEDNUM for #{self.name}"
          nil
        end

        # Find or create Member and associate, unless nil (vacant)
        ## This needs to be updated to NOT RUN EVERY NIGHT, but
                          ## still run IF THERE IS A NEW MEMBER
        if district["CurrentPersonOfficialLastName"] == nil
          new_district.member = nil
        elsif (new_district.member == nil) || (new_district.member.lastname != district["CurrentPersonOfficialLastName"])
          new_district.member = Member.find_by(
            firstname: district["CurrentPersonOfficialFirstName"],
            lastname: district["CurrentPersonOfficialLastName"]
          )
        end

        new_district.save! if new_district.changed?
      end
    end
    handle_asynchronously :create_districts

    def parse_geojson(geojson=@@districts_geojson)

      geo = JSON.parse(geojson)
      return geo["features"]
    end

  end

  ### END OF CLASS METHODS###
  ### START OF INSTANCE METHODS ###


  # Possible vote % in previous election
  # http://www.elections.ca/Scripts/vis/PastResults?L=e&ED=13002&EV=99&EV_TYPE=6&QID=-1&PAGEID=28
  # ED=13002 == FEDNUM in geo. Where does this come from?
end
