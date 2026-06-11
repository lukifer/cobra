# frozen_string_literal: true

# Public resource for Stage objects.
class StageResource < ApplicationResource
  primary_endpoint '/stages', %i[index show]

  self.default_page_size = 50

  attribute :id, :integer
  attribute :tournament_id, :integer
  attribute :number, :integer
  attribute :format, :string

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  belongs_to :tournament
  has_many :rounds
end
