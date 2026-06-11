# frozen_string_literal: true

# Public resource for Format objects.
class FormatResource < ApplicationResource
  primary_endpoint '/formats', %i[index show]

  self.default_page_size = 50

  attribute :id, :integer
  attribute :name, :string
  attribute :position, :integer

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  has_many :tournaments
end
