class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    @bills = Bill.where("last_event_date >= ? AND prefix = 'C'", 1.week.ago.to_date).order(last_event_date: :desc)
    @vote_tallies = VoteTally.where('date >= ?', 1.week.ago.to_date).order(date: :desc, vote_number: :desc)
  end

end
