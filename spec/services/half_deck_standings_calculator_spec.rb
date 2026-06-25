# frozen_string_literal: true

RSpec.describe HalfDeckStandingsCalculator do
  let(:smashup_format) { Format.find_or_create_by!(name: 'Smashup') { |f| f.position = 98 } }
  let(:tournament) { create(:tournament, swiss_format: :single_sided, format: smashup_format) }
  let(:stage) { tournament.current_stage }
  let(:round) { create(:round, stage:, tournament:, completed: true) }
  let!(:snap) { create(:player, tournament:) }
  let!(:crackle) { create(:player, tournament:) }
  let!(:pop) { create(:player, tournament:) }
  let!(:other) { create(:player, tournament:) }
  let(:results) { described_class.calculate!(tournament) }

  def standing_for(player, side)
    results.find { |s| s.player == player && s.side == side }
  end

  context 'with a single reported pairing' do
    before do
      create(:pairing, round:, player1: snap, player2: crackle, side: :player1_is_corp,
                       score1: 6, score2: 0,
                       player1_deck1_player_id: pop.id, player1_deck2_player_id: other.id,
                       player2_deck1_player_id: pop.id, player2_deck2_player_id: other.id)
    end

    it 'creates separate corp and runner half-deck standings for the same contributors' do
      expect(results.map { |standing| [standing.player, standing.side] }).to contain_exactly(
        [pop, :corp],
        [other, :corp],
        [pop, :runner],
        [other, :runner]
      )
    end

    it 'awards each half-deck the score earned by the seated player using it' do
      aggregate_failures do
        expect(standing_for(pop, :corp).points).to eq(6)
        expect(standing_for(other, :corp).points).to eq(6)
        expect(standing_for(pop, :runner).points).to eq(0)
        expect(standing_for(other, :runner).points).to eq(0)
      end
    end

    it 'calculates sos and extended sos from opposing half-deck results' do
      aggregate_failures do
        expect(standing_for(pop, :corp).sos).to eq(0.0)
        expect(standing_for(pop, :corp).extended_sos).to eq(6.0)
        expect(standing_for(pop, :runner).sos).to eq(6.0)
        expect(standing_for(pop, :runner).extended_sos).to eq(0.0)
      end
    end
  end

  context 'with multiple pairings' do
    before do
      create(:pairing, round:, player1: snap, player2: crackle, side: :player1_is_corp,
                       score1: 6, score2: 0,
                       player1_deck1_player_id: pop.id, player1_deck2_player_id: other.id,
                       player2_deck1_player_id: pop.id, player2_deck2_player_id: other.id)
      create(:pairing, round:, player1: pop, player2: other, side: :player1_is_runner,
                       score1: 3, score2: 3,
                       player1_deck1_player_id: snap.id, player1_deck2_player_id: crackle.id,
                       player2_deck1_player_id: snap.id, player2_deck2_player_id: crackle.id)
    end

    it 'orders half-decks by points, then sos, then extended sos' do
      expect(results.map(&:points)).to eq([6, 6, 3, 3, 3, 3, 0, 0])
    end

    it 'keeps a contributor corp half-deck separate from their runner half-deck' do
      aggregate_failures do
        expect(standing_for(pop, :corp).points).to eq(6)
        expect(standing_for(pop, :runner).points).to eq(0)
        expect(standing_for(snap, :corp).points).to eq(3)
        expect(standing_for(snap, :runner).points).to eq(3)
      end
    end
  end

  context 'when a half-deck contributor only receives byes' do
    before do
      create(:pairing, round:, player1: snap, player2: nil, side: :player1_is_corp,
                       score1: 6, score2: 0,
                       player1_deck1_player_id: pop.id, player1_deck2_player_id: other.id,
                       player2_deck1_player_id: nil, player2_deck2_player_id: nil)
    end

    it 'includes points but zero sos values' do
      aggregate_failures do
        expect(standing_for(pop, :corp).points).to eq(6)
        expect(standing_for(pop, :corp).sos).to eq(0.0)
        expect(standing_for(pop, :corp).extended_sos).to eq(0.0)
      end
    end
  end

  context 'when no half-decks have been used' do
    before do
      create(:pairing, round:, player1: snap, player2: crackle, score1: 3, score2: 0)
    end

    it 'returns an empty list' do
      expect(results).to eq([])
    end
  end
end
