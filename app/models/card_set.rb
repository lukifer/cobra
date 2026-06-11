# frozen_string_literal: true

# Mode for CardSet, used by "cards up to" in tournament settings.
class CardSet < ApplicationRecord
  has_many :tournaments
end
