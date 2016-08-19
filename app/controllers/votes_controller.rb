class VotesController < ApplicationController

  # Shows all votes by certain member
  def show_member
    @member = Member.find(params[:id])
    @votes = Vote.where(member_id: params[:id])
  end

  # Shows all votes by party
  def show_party
    @party = Party.find(params[:id])
    @votes = Vote.where(party_id: params[:id])
  end

end
