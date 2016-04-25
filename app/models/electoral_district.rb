class ElectoralDistrict < ActiveRecord::Base
  has_one :member

  def self.get_districts
    districts_xml = open('http://www.parl.gc.ca/Parliamentarians/en/constituencies/export?output=XML').read
    districts = Hash.from_xml(districts_xml)
    districts = districts["List"]["Constituency"]

    geojson = File.read("public/districts.geojson")

    districts.each do |district|
      new_district = ElectoralDistrict.find_or_create_by(name: district["Name"])
      new_district.province = district["ProvinceTerritoryName"] if new_district.province == nil
      new_district.geo = new_district.get_geography(geojson) if new_district.geo == nil
      new_district.member = Member.find_by(
        firstname: district["CurrentPersonOfficialFirstName"],
        lastname: district["CurrentPersonOfficialLastName"]
      ) if new_district.member == nil
      new_district.save!
    end
  end

  # return GeoJSON string of ElectoralDistrict geometry
  def get_geography(geojson)
    geo = JSON.parse(geojson)
    features = geo["features"]
    feature_geo = features.select { |feature| feature["properties"]["ENNAME"] == self.name.gsub("—", "--") }.first
    return feature_geo.to_json
  end

end
