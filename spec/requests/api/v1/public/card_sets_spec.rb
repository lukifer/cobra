# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API CardSets' do
  let!(:card_set) { create(:card_set, name: 'System Gateway') }

  describe 'GET /api/v1/public/card_sets' do
    it 'returns a successful 200 response with all card sets and correct meta count' do
      json = api_num_results('/api/v1/public/card_sets', 1)
      has_stats_total_count(json, 1)
    end
  end

  describe 'GET /api/v1/public/card_sets/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/card_sets/#{card_set.id}", card_set.id, name: 'System Gateway')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/card_sets/#{card_set.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/card_sets/missing')
    end
  end
end
