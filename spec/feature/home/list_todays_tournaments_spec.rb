# frozen_string_literal: true

RSpec.describe "list today's tournaments", type: :feature do
  let!(:today) do
    create(:tournament, date: Date.current.beginning_of_day, name: 'TodayGNK', slug: 'TEST')
  end

  before do
    create(:tournament, date: Date.yesterday.beginning_of_day, name: 'YesterdayGNK', slug: '1234')
    create(:tournament, date: Date.tomorrow.beginning_of_day, name: 'TomorrowGNK', slug: '5678')
    create(:tournament, date: Date.current.beginning_of_day, name: 'PrivateGNK', private: true)

    visit root_path
  end

  it "only shows today's tournaments" do
    aggregate_failures do
      expect(page).to have_no_text('YesterdayGNK')
      expect(page).to have_text('TodayGNK')
      expect(page).to have_no_text('TomorrowGNK')
    end
  end

  it 'does not show private tournaments' do
    expect(page).to have_no_text('PrivateGNK')
  end

  it 'links to more tournaments' do
    click_link 'More tournaments'

    aggregate_failures do
      expect(page).to have_text('YesterdayGNK')
      expect(page).to have_text('TodayGNK')
      expect(page).to have_text('TomorrowGNK')
    end
  end

  describe 'shortcode form' do
    it 'redirects to tournament page' do
      fill_in :slug, with: 'TEST'
      click_button 'Go to tournament'

      expect(page).to have_current_path(tournament_path(today), ignore_query: true)
    end

    it 'handles invalid shortcode' do
      fill_in :slug, with: 'NOSUCH'
      click_button 'Go to tournament'

      expect(page).to have_text("Couldn't find that tournament")
    end
  end
end
