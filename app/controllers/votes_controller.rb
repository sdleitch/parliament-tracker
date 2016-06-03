class VotesController < ApplicationController

  def show
    @votes = Vote.where(member_id: params[:id])
  end

end
