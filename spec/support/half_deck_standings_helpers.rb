# frozen_string_literal: true

module HalfDeckStandingsHelpers
  def expected_standings_identity(identity)
    return nil unless identity

    {
      'name' => identity.name,
      'faction' => identity.faction,
      'side' => identity.side
    }
  end

  def expect_half_deck_standing_identities(standings, contributors:)
    contributors_by_name = contributors.index_by(&:name_with_pronouns)

    standings.each do |standing|
      contributor = contributors_by_name.fetch(standing['player']['name_with_pronouns'])
      side = standing['side']

      expected_ref =
        if side == 'corp'
          contributor.corp_identity_ref
        else
          contributor.runner_identity_ref
        end

      expect(standing['identity']).to eq(expected_standings_identity(expected_ref))
      expect(standing['player']['corp_id']).to eq(expected_standings_identity(contributor.corp_identity_ref))
      expect(standing['player']['runner_id']).to eq(expected_standings_identity(contributor.runner_identity_ref))

      next unless standing['identity']

      expect(standing['identity']['side']).to eq(side)
    end
  end

  def find_half_deck_standing(standings, contributor:, side:)
    standings.find do |standing|
      standing['player']['name_with_pronouns'] == contributor.name_with_pronouns &&
        standing['side'] == side
    end
  end
end

RSpec.configure do |config|
  config.include HalfDeckStandingsHelpers
end
