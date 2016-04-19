class Member < ActiveRecord::Base
  belongs_to :party
  has_and_belongs_to_many :parliments
end
