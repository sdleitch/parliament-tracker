class Party < ActiveRecord::Base
  has_many :members

  # Will gather votes from the passed VoteTally from Party Members
  # and compare yeas to nays, returning true of false
  # if either are over 90% of party votes, indicating if the vote was tightly whipped
  def party_vote(vote_tally)
    party_votes = Vote.where('vote_tally_id = ? AND member_id IN (?)', vote_tally.id, self.members.pluck(:id))
    yeas = party_votes.where(vote_decision: true)
    nays = party_votes.where(vote_decision: false)
    if yeas.length.to_f / party_votes.length > 0.8
      return true
    elsif nays.length.to_f / party_votes.length > 0.8
      return false
    end
  end

end
