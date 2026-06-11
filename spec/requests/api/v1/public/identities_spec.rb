# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Identities' do
  let!(:catalyst_original) { create(:catalyst_original) }

  describe 'GET /api/v1/public/identities' do
    it 'returns deduplicated identities based on name, returning only the one with the highest nrdb_code' do
      create(:catalyst_reprint)
      create(:id_ampere)
      json = api_num_results('/api/v1/public/identities', 2)
      has_stats_total_count(json, 2)

      # The Catalyst was deduplicated: only the one with highest nrdb_code (35000) should be returned.
      # So we expect exactly 2 identities in the list: the deduplicated Catalyst (35000) and Ampere (33128).
      returned_nrdb_codes = json['data'].map { |item| item['attributes']['nrdb_code'] }
      expect(returned_nrdb_codes).to contain_exactly('35000', '33128')
    end
  end

  describe 'GET /api/v1/public/identities/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/identities/#{catalyst_original.id}", catalyst_original.id,
                     name: 'The Catalyst: Convention Breaker')
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/identities/999999')
    end
  end
end
