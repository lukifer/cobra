# frozen_string_literal: true

# Public resource for Identity objects.
class IdentityResource < ApplicationResource
  primary_endpoint '/identities', %i[index show]

  self.default_page_size = 250

  attribute :id, :integer
  attribute :name, :string
  attribute :autocomplete, :string
  attribute :faction, :string
  attribute :nrdb_code, :string
  attribute :side, :string
end
