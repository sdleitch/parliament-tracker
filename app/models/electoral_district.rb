class ElectoralDistrict < ActiveRecord::Base
  include ActiveModel::Dirty

  has_one :member

  # This taken from: stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
  # to match ASCII-removed districts from GeoJSON to real district names
  @@encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => ''        # Use a blank for those replacements
  }

  ### START OF CLASS METHODS ###
  class << self

    # Download districts xml, convert to Hash
    def scrape_districts
      @@districts_xml = open(BASE_PARLIAMENT_URI + '/Parliamentarians/en/constituencies/export?output=XML').read
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
        new_district.geo, new_district.fednum = new_district.get_geography

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

        new_district.save!
      end
    end
    handle_asynchronously :create_districts

    def parse_geojson(geojson=@@districts_geojson)
      geo = JSON.parse(geojson)
      return geo["features"]
    end

    # Method to find which ElectoralDistrict a postal code is in
    def find_district_by_postal_code(postal_code)
      postal_code.downcase!.gsub!(/(\W|_)/, "") # Downcase and strip any character
                                                # which is not alphanumeric
      postal_code_url = "http://elections.ca/scripts/vis/FindED?L=e&PC=" + postal_code
      page = open(postal_code_url) # Open url, will automatically follow redirect
      district_uri = URI(page.base_uri.to_s) # Get the uri string from redirect
      queries = CGI.parse(district_uri.query) # Parse the URI for queries (one is fednum)
      fednum = queries["ED"].first.to_i # Find the fednum
      return electoral_district = ElectoralDistrict.where(fednum: fednum).first # return ElectoralDistrict
    end

  end

  ### END OF CLASS METHODS###
  ### START OF INSTANCE METHODS ###

  def get_geography(geojson=@@districts_geojson)
    geo = JSON.parse(geojson)
    features = geo["features"]
    feature_geo = features.select { |feature| feature["properties"]["ENNAME"] == self.name.gsub("—", "--").encode(Encoding.find('ASCII'), @@encoding_options) }.first
    # return feature_geo.to_json, feature_geo["properties"]["FEDNUM"]
    feature_geo != nil ? [feature_geo.to_json, feature_geo["properties"]["FEDNUM"]] : ["null", nil]
  end

  # Possible vote % in previous election
  # http://www.elections.ca/Scripts/vis/PastResults?L=e&ED=13002&EV=99&EV_TYPE=6&QID=-1&PAGEID=28
  # ED=13002 == FEDNUM in geo. Where does this come from?
end
