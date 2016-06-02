module MemberHelper

  def sort_votes_by_date
    sorted_votes = Vote.where(member_id: @member.id).limit(5).joins(:vote_tally).order('vote_tallies.date DESC')
  end

  def name_with_honorific
    @member.honorific ? "#{@member.honorific} #{@member.fullname}" : @member.fullname
  end

end
