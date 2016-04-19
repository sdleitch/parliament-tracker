class Party < ActiveRecord::Base
  has_many :members
  has_and_belongs_to_many :parliments
end
