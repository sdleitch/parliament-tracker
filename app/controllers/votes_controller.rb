class VotesController < ApplicationController

  def show
    @member = Member.find(params[:id])
    @votes = Vote.where(member_id: params[:id])
  end

end
