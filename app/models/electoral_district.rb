class ElectoralDistrict < ActiveRecord::Base
  has_one :member

  def get_member(member_array)
  end

end
