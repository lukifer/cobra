# frozen_string_literal: true

RSpec.describe 'view help page', type: :feature do
  before do
    visit help_path
  end

  it 'displays help content' do
    expect(page).to have_text('How to use Cobra')
  end
end
