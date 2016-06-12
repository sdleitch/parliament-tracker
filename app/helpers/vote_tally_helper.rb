module VoteTallyHelper

  def result(tally)
    if tally.agreed_to == nil
      return 'tied'
    elsif tally.agreed_to == true
      return 'passed'
    elsif tally.agreed_to == false
      return 'failed'
    end
  end

end
