module PartyHelper

  # Builds a geoJSON string to pass into browser as
  # geo attribute on the map div. Skips "null" values
  def party_geo
    geo = "{ \"type\": \"FeatureCollection\", \"features\": ["
    @party.electoral_districts.each do |district|
      unless district.geo == "null"
        geo += district.geo + ", "
      end
    end
    geo = geo[0..-3] + "] }"
  end

end
