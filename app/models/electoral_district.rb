class ElectoralDistrict < ActiveRecord::Base
  has_one :member

  @@districts_geojson = File.read("public/districts.geojson")

  def self.scrape_districts
    @@districts_xml = open('http://www.parl.gc.ca/Parliamentarians/en/constituencies/export?output=XML').read
    @@districts = Hash.from_xml(@@districts_xml)["List"]["Constituency"]
  end

  def self.create_districts(districts=@@districts, districts_geojson=@@districts_geojson)
    districts.each do |district|
      new_district = ElectoralDistrict.find_or_create_by(
        name: district["Name"],
        province: district["ProvinceTerritoryName"]
      )
      new_district.geo = new_district.get_geography(districts_geojson) if new_district.geo == nil || new_district.geo == "null"

      if new_district.member == nil || new_district.member.lastname != district["CurrentPersonOfficialLastName"]
        unless district["CurrentPersonOfficialLastName"] == nil
          new_district.member =  Member.update_or_create_member(
            district["CurrentPersonOfficialFirstName"],
            district["CurrentPersonOfficialLastName"],
            district["CurrentPersonShortHonorific"],
            district["CurrentCaucusShortName"]
          )
        end
      end

      new_district.save!
    end
  end

  # return GeoJSON string of ElectoralDistrict geometry
  def get_geography(geojson=@@districts_geojson)
    # This taken from: stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
    # to match ASCII-removed districts from GeoJSON to real district names
    encoding_options = {
      :invalid           => :replace,  # Replace invalid byte sequences
      :undef             => :replace,  # Replace anything not defined in ASCII
      :replace           => '',        # Use a blank for those replacements
    }

    geo = JSON.parse(geojson)
    features = geo["features"]
    # This will return the first in a single-element array of hashes of GeoJSON
    feature_geo = features.select { |feature| feature["properties"]["ENNAME"] == self.name.gsub("—", "--").encode(Encoding.find('ASCII'), encoding_options) }.first
    return feature_geo.to_json
  end

  # Possible vote % in previous election
  # http://www.elections.ca/Scripts/vis/PastResults?L=e&ED=13002&EV=99&EV_TYPE=6&QID=-1&PAGEID=28
  # ED=13002 == FEDNUM in geo. Where does this come from?
end
