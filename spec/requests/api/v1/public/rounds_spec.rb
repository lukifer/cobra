# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Rounds' do
  let!(:tournament) { create(:tournament, private: false) }
  let!(:stage) { create(:stage, tournament: tournament) }
  let!(:round) { create(:round, tournament: tournament, stage: stage, number: 1, completed: false) }

  describe 'GET /api/v1/public/rounds/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/rounds/#{round.id}", round.id, number: 1, completed: false)
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/rounds/#{round.id}",
        stage: '/api/v1/public/stages/',
        tournament: '/api/v1/public/tournaments/'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/rounds/999999')
    end
  end
end
