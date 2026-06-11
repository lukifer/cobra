# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Stages' do
  let!(:tournament) { create(:tournament, private: false) }
  let!(:stage) { create(:stage, tournament: tournament, number: 1, format: :swiss) }

  describe 'GET /api/v1/public/stages/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/stages/#{stage.id}", stage.id, number: 1, format: 'swiss')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/stages/#{stage.id}",
        tournament: '/api/v1/public/tournaments/',
        rounds: '/api/v1/public/rounds'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/stages/999999')
    end
  end
end
