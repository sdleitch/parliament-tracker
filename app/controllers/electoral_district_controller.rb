class ElectoralDistrictController < ApplicationController

  def show
    @district = ElectoralDistrict.find_by(fednum: params[:fednum].to_i)
    @member = Member.find_by(electoral_district: @district)
    redirect_to @member
  end

end
