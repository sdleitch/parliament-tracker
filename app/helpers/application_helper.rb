module ApplicationHelper

  def page_title
    case
    when @member
      @member.fullname
    when @bill
      @bill.bill_number
    when @vote_tally
      "Vote No. " + @vote_tally.vote_number.to_s
    else
      "Parliament Tracker"
    end
  end

end
