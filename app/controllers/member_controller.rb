class MemberController < ApplicationController
  def index
    @members = Member.all
  end

  def show
    @member = Member.find(params[:id])
  end

  def search
    @electoral_district = ElectoralDistrict.find_district_by_postal_code(params[:postal_code])
    @member = @electoral_district.member
    redirect_to @member
  end
end
  
