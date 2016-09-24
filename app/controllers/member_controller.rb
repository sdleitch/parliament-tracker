class MemberController < ApplicationController
  def index
    @members = Member.all
  end

  def show
    @member = Member.find(params[:id])
  end

  def search
    @electoral_district = ElectoralDistrict.find_district_by_postal_code(params[:postal_code])
    if @electoral_district != nil
      @member = @electoral_district.member
      redirect_to @member
    else
      flash[:notice] = "Sorry! We were unable to find that postal code. It is possibly not represented in Parliament right now."
      redirect_to member_index_path
    end
  end
end
