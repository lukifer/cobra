# frozen_string_literal: true

# Public resource for OfficialPrizeKit objects.
class OfficialPrizeKitResource < ApplicationResource
  primary_endpoint '/official_prize_kits', %i[index show]

  self.default_page_size = 50

  attribute :id, :integer
  attribute :name, :string
  attribute :description, :string
  attribute :image_url, :string
  attribute :link, :string
  attribute :position, :integer

  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  has_many :tournaments
end
