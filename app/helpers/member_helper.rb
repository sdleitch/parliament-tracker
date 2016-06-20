module MemberHelper

  def sort_votes_by_date(limit=nil)
    sorted_votes = Vote.where(member_id: @member.id).limit(limit).joins(:vote_tally).order(date: :desc)
  end

  def name_with_honorific
    @member.honorific ? "The #{@member.honorific} #{@member.fullname}" : @member.fullname
  end

  def sort_bills_by_date(limit=nil)
    sorted_bills = Bill.where(member_id: @member.id).limit(limit).joins(:member).order(last_event_date: :desc)
  end

end
