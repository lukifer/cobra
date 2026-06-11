# frozen_string_literal: true

# Public resource for DeckbuildingRestriction objects.
class DeckbuildingRestrictionResource < ApplicationResource
  primary_endpoint '/deckbuilding_restrictions', %i[index show]

  self.default_page_size = 250

  attribute :id, :string
  attribute :name, :string
  attribute :date_start, :date
  attribute :play_format_id, :string

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  has_many :tournaments
end
