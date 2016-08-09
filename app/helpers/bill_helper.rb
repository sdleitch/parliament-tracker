module BillHelper

  def sort_vote_tallies_by_date(limit=nil)
    if @bill
      sorted_votes = VoteTally.where(bill_id: @bill.id).limit(limit).joins(:bill).order(date: :desc, vote_number: :desc)
    else
      sorted_votes = VoteTally.all.limit(limit).order(date: :desc, vote_number: :desc)
    end
    # raise 'hell'
    return sorted_votes
  end

end
