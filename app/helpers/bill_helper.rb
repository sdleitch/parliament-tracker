module BillHelper

  def sort_votes_tallies_by_date(limit=nil)
    sorted_votes = VoteTally.where(bill_id: @bill.id).limit(limit).joins(:bill).order(date: :desc, vote_number: :desc)
  end

end
