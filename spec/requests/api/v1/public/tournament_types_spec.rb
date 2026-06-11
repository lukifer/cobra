# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Tournament Types' do
  let!(:tournament_type) { create(:tournament_type, name: 'Megacity Championship') }

  describe 'GET /api/v1/public/tournament_types/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/tournament_types/#{tournament_type.id}", tournament_type.id,
                     name: 'Megacity Championship')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/tournament_types/#{tournament_type.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/tournament_types/999999')
    end
  end
end
