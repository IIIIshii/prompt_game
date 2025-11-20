class Day < ApplicationRecord
  has_many :turns, dependent: :destroy

  enum :status, {
    active: 0,
    inactive: 1
  }
end
