class Parliment < ActiveRecord::Base
  has_and_belongs_to_many :members
  has_and_belongs_to_many :parties
end
