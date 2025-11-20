class Day < ApplicationRecord

    has_many :turns, dependent: :destroy

    enum :status, {
        pending: 0,
        active: 1,
        finished: 2
    }
end
