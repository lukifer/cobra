# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Users' do
  let!(:user) { create(:user, nrdb_username: 'plural') }

  describe 'GET /api/v1/public/users/:id' do
    it 'matches existing record' do
      matches_record("/api/v1/public/users/#{user.id}", user.id, nrdb_username: 'plural')
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v1/public/users/#{user.id}",
        tournaments: '/api/v1/public/tournaments'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v1/public/users/999999')
    end
  end
end
