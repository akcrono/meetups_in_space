class Meetup < ActiveRecord::Base
  has_many :signups
  has_many :users, through: :signups
  has_many :comments
end
