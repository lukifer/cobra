# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API OfficialPrizeKits' do
  let!(:kit) { create(:official_prize_kit, name: 'GNK 2026') }

  describe 'GET /api/v1/public/official_prize_kits' do
    it 'returns a successful 200 response with all prize kits and correct meta count' do
      json = api_num_results('/api/v1/public/official_prize_kits', 1)
      has_stats_total_count(json, 1)
    end
  end

  describe 'GET /api/v1/public/official_prize_kits/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/official_prize_kits/#{kit.id}", kit.id, name: 'GNK 2026')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/official_prize_kits/#{kit.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/official_prize_kits/999999')
    end
  end
end
