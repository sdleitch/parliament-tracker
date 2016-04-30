class VoteTally < ActiveRecord::Base
  belongs_to :bill
  belongs_to :member
  has_many :votes, dependent: :destroy

  def self.create_vote_tally(vote_page_uri)
    page = Nokogiri::HTML(open(vote_page_uri))
    vote_details = page.at_css('#VoteDetailsHeader')
    vote_number = vote_details.at_css('div div').content.strip
    date = vote_details.at_css('div div:nth-child(3)').content.to_date
    para = vote_details.at_css('.voteContextArea').content.strip

    new_tally = VoteTally.find_or_create_by(
      vote_number: vote_number,
      date: date,
      para: para
    )

    votes_xml = open(vote_page_uri.to_s + "&xml=True").read
    votes = Hash.from_xml(votes_xml)["Vote"]["Participant"]
    new_tally.get_votes(votes)

  end

  def get_votes(votes)
    votes.each do |vote|
      # unless self.votes & Votes.where(member: Member.where(firstname: vote["FirstName"], lastname: vote["LastName"])) != nil
        new_vote = Vote.new
        new_vote.member = Member.find_by(firstname: vote["FirstName"], lastname: vote["LastName"])
        new_vote.vote_tally = self
        new_vote.save!
        self.votes << new_vote
      # end
    end

    # if vote["RecordedVote"]["Yea"] == 1
    #   new_vote.vote_decision = true
    # elsif vote["RecordedVote"]["Nay"] == 1
    #   new_vote.vote_decision = false
    # end

  end

  def get_member(member_page_uri)
    # fuck this the parl website is shitty to scrape
  end

end
