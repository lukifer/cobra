# frozen_string_literal: true

# Public resource for CardSet objects.
class CardSetResource < ApplicationResource
  primary_endpoint '/card_sets', %i[index show]

  self.default_page_size = 250

  attribute :id, :string
  attribute :name, :string
  attribute :date_release, :date

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  has_many :tournaments
end
