class PartyController < ApplicationController
  def index
  end

  def show
    @party = Party.find(params[:id])
  end
end
