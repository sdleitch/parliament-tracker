class VoteTallyController < ApplicationController
  def show
    @vote_tally = VoteTally.find(params[:id])
  end
end
