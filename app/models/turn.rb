class Turn < ApplicationRecord
  belongs_to :day

  has_one_attached :image

  validates :prompt, presence: true
end
