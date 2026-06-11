# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API DeckbuildingRestrictions' do
  let!(:restriction) { create(:deckbuilding_restriction, name: 'Standard Banned List') }

  describe 'GET /api/v1/public/deckbuilding_restrictions' do
    it 'returns a successful 200 response with all restrictions and correct meta count' do
      json = api_num_results('/api/v1/public/deckbuilding_restrictions', 1)
      has_stats_total_count(json, 1)
    end
  end

  describe 'GET /api/v1/public/deckbuilding_restrictions/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/deckbuilding_restrictions/#{restriction.id}",
                     restriction.id, name: 'Standard Banned List')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/deckbuilding_restrictions/#{restriction.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/deckbuilding_restrictions/missing')
    end
  end
end
