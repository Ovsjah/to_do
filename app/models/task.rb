class Task < ApplicationRecord
  validates_presence_of :description
  belongs_to :todo
end
