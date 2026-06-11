# frozen_string_literal: true

# Model for OfficialPrizeKit, referenced in tournament settings.
class OfficialPrizeKit < ApplicationRecord
  has_many :tournaments
end
