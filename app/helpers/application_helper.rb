module ApplicationHelper

  # Returns a <title> for each page
  def page_title
    case
    when @member
      @member.fullname
    when @bill
      @bill.bill_number
    when @vote_tally
      "Vote No. " + @vote_tally.vote_number.to_s
    else
      "Parliament Tracker"
    end
  end

  # Builds a geoJSON string to pass into browser as
  # geo attribute on the map div. Skips "null" values
  def all_party_geo
    geo = "{ \"type\": \"FeatureCollection\", \"features\": ["
    ElectoralDistrict.all.each do |district|
      unless district.geo == "null"
        geo += district.geo + ", "
      end
    end
    geo = geo[0..-3] + "] }"
  end

end
