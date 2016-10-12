module BillHelper

  def summary_helper(bill)
    if bill.summary.include?("  ") && /the [A-Z].+Act/.match(bill.title_long)
      return bill.summary.gsub("  ", " " + /the [A-Z].+Act/.match(bill.title_long).to_s[4..-1] + " ")
    end
  end

end
