class Todo < ApplicationRecord
  validates_presence_of :title
  belongs_to :user
  has_many :tasks, dependent: :destroy
end
