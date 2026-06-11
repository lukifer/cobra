# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Formats' do
  let!(:format) { create(:format, name: 'Standard') }

  describe 'GET /api/v1/public/formats' do
    it 'returns a successful 200 response with all formats and correct meta count' do
      json = api_num_results('/api/v1/public/formats', 1)
      has_stats_total_count(json, 1)
    end
  end

  describe 'GET /api/v1/public/formats/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/formats/#{format.id}", format.id, name: 'Standard')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/formats/#{format.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/formats/999999')
    end
  end
end
