class VoteTally < ActiveRecord::Base
  belongs_to :bill
  belongs_to :member
  has_many :votes, dependent: :destroy

  def self.create_vote_tally(vote_page_uri)
    page = Nokogiri::HTML(open(vote_page_uri))
    vote_details = page.at_css('#VoteDetailsHeader')
    vote_number = vote_details.at_css('div div').content.strip[/\d+/].to_i
    date = vote_details.at_css('div div:nth-child(3)').content.to_date
    para = vote_details.at_css('.voteContextArea').content.strip if vote_details.at_css('.voteContextArea')

    new_tally = VoteTally.find_or_create_by(
      vote_number: vote_number,
      date: date,
      para: para,
    )

    if new_tally.member == nil
      link_nodes = page.css("#VoteDetailsHeader > div:nth-child(2) a.WebOption")
      member_link_node = link_nodes.find { |node| node.attr('onclick') =~ /'Affiliation',\d{6},/ }
      redirect_id = member_link_node.attr('onclick').match(/\d{6}/).to_s
      member_page_uri = "http://www.parl.gc.ca/parliamentarians/en/members/profileredirect?affiliationId=#{redirect_id}"
      new_tally.member = new_tally.get_vote_sponsor(member_page_uri)
    end

    votes_xml = open(vote_page_uri.to_s + "&xml=True").read
    votes_hash = Hash.from_xml(votes_xml)["Vote"]["Participant"]
    new_tally.get_votes(votes_hash) if new_tally.votes.length != votes_hash.length
    new_tally.agreed_to = new_tally.tally_votes if new_tally.agreed_to == nil
    new_tally.save!
    return new_tally
  end

  def get_votes(votes_hash)
    votes_hash.each do |vote|
      member = Member.find_by(firstname: vote["FirstName"], lastname: vote["LastName"])
      if (!member) || ((votes & member.votes).empty?)
        new_vote = Vote.new
        new_vote.member = member if member
        new_vote.vote_decision = vote["RecordedVote"]["Yea"] == "1" ? true : false
        votes << new_vote
      end
    end
  end

  def get_vote_sponsor(member_page_uri)
    response = open(member_page_uri) rescue nil
    unless response == nil
      member_page = Nokogiri::HTML(response)
      scraped_name = member_page.at_css("div.profile > h2").content
      member = Member.where(
        # SQL LIKE match the find firstname AND lastname
        # in the name scraped (scraped_name) from parliament profile.
        "'#{scraped_name}' LIKE '%'||firstname||'%'
        AND '#{scraped_name}' LIKE '%'||lastname||'%'"
      ).first
      return member
    end
  end

  def tally_votes
    return yeas > nays ? true : false
  end

  def yeas
    count = 0
    votes.each { |vote| count += 1 if vote.vote_decision == true }
    return count
  end

  def nays
    count = 0
    votes.each { |vote| count += 1 if vote.vote_decision == false }
    return count
  end

end
