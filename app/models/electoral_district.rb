class ElectoralDistrict < ActiveRecord::Base
  has_one :member

  @@districts_geojson = File.read("public/districts.geojson")

  def self.get_districts
    @@districts_xml = open('http://www.parl.gc.ca/Parliamentarians/en/constituencies/export?output=XML').read
    @@districts = Hash.from_xml(@@districts_xml)["List"]["Constituency"]
  end

  def self.create_districts(districts=@@districts, districts_geojson=@@districts_geojson)
    districts.each do |district|
      new_district = ElectoralDistrict.find_or_create_by(
        name: district["Name"],
        province: district["ProvinceTerritoryName"]
      )
      new_district.geo = new_district.get_geography(districts_geojson) if new_district.geo == nil

      # Find or create Member and associate, unless nil (vacant)
      unless district["CurrentPersonOfficialLastName"] == nil
        new_district.member =  Member.update_or_create_member(
          district["CurrentPersonOfficialFirstName"],
          district["CurrentPersonOfficialLastName"],
          district["CurrentPersonShortHonorific"],
          district["CurrentCaucusShortName"]
        )
      end

      new_district.save!
    end
  end

  # return GeoJSON string of ElectoralDistrict geometry
  def get_geography(geojson=@@districts_geojson)
    geo = JSON.parse(geojson)
    features = geo["features"]
    feature_geo = features.select { |feature| feature["properties"]["ENNAME"] == self.name.gsub("—", "--") }.first
    return feature_geo.to_json
  end

end
