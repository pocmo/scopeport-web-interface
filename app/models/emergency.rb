class Emergency < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :severity

  belongs_to :user
  has_many :emergencychatmessages
end
