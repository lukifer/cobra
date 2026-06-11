# frozen_string_literal: true

# Public resource for Round objects.
class RoundResource < ApplicationResource
  primary_endpoint '/rounds', %i[index show]

  self.default_page_size = 50

  attribute :id, :integer
  attribute :stage_id, :integer
  attribute :tournament_id, :integer
  attribute :number, :integer
  attribute :completed, :boolean
  attribute :length_minutes, :integer
  attribute :weight, :float

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  belongs_to :stage
  belongs_to :tournament
end
