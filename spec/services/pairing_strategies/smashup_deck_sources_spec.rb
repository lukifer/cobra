# frozen_string_literal: true

RSpec.describe PairingStrategies::SmashupDeckSources do
  let(:tournament) { create(:tournament, swiss_format: :single_sided) }
  let(:corp_a) { create(:id_etf) }
  let(:corp_b) { create(:id_pd) }
  let(:runner_x) { create(:id_az) }
  let(:runner_y) { create(:id_sable) }

  let!(:p1) { create(:player, tournament:, corp_identity_ref: corp_a, runner_identity_ref: runner_x) }
  let!(:p2) { create(:player, tournament:, corp_identity_ref: corp_b, runner_identity_ref: runner_y) }
  let!(:p3) { create(:player, tournament:, corp_identity_ref: corp_b, runner_identity_ref: runner_x) }
  let!(:p4) { create(:player, tournament:, corp_identity_ref: corp_a, runner_identity_ref: runner_y) }

  let(:players_by_id) { Player.where(id: [p1, p2, p3, p4].map(&:id)).includes(:corp_identity_ref, :runner_identity_ref).index_by(&:id) }

  it 'picks two distinct corp factions for the corp-sided player when possible' do
    plain1 = PairingStrategies::PlainPlayer.new(p1.id, p1.name, true, false)
    plain2 = PairingStrategies::PlainPlayer.new(p2.id, p2.name, true, false)
    pp = PairingStrategies::PlainPairing.new(plain1, 0, plain2, 0)
    pp.player1_side = 'corp'

    attrs = described_class.attributes_for_plain_pairing(
      pp,
      [p1.id, p2.id, p3.id, p4.id],
      players_by_id,
      random: Random.new(99)
    )

    corp_sources = [attrs[:player1_deck1_player_id], attrs[:player1_deck2_player_id]].compact.sort
    expect(corp_sources).to eq([p3.id, p4.id].sort)

    runner_sources = [attrs[:player2_deck1_player_id], attrs[:player2_deck2_player_id]].compact.sort
    expect(runner_sources).to eq([p3.id, p4.id].sort)
  end

  it 'returns empty attrs for byes' do
    plain = PairingStrategies::PlainPlayer.new(p1.id, p1.name, true, false)
    bye_pp = PairingStrategies::PlainPairing.new(plain, 3, nil, 0)
    expect(described_class.attributes_for_plain_pairing(bye_pp, [p1.id], players_by_id, random: Random.new)).to eq({})
  end
end
