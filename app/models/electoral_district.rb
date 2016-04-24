class ElectoralDistrict < ActiveRecord::Base
  has_one :member

  def self.get_districts
    districts_xml = open('http://www.parl.gc.ca/Parliamentarians/en/constituencies/export?output=XML').read
    districts = Hash.from_xml(districts_xml)
    districts = districts["List"]["Constituency"]

    districts.each do |district|
      new_district = ElectoralDistrict.find_or_create_by(name: district["Name"])
      new_district.province = district["ProvinceTerritoryName"]
      new_district.member = Member.find_by(
        firstname: district["CurrentPersonOfficialFirstName"],
        lastname: district["CurrentPersonOfficialLastName"]
      )
    end
  end

end
