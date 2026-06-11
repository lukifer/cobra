import { Identity } from "../identities/Identity";
import {
  type Pairing,
  type PairingsData,
  type Round,
  type RoundTimer,
  type Stage,
} from "../pairings/PairingsData";
import type { ScoreReport } from "../pairings/SelfReport";
import type { Player } from "../players/PlayersData";
import { MockTournament } from "./TournamentTestData";

export const MockPlayerAlice: Player = {
  id: 1,
  name: "Alice",
  pronouns: "she/her",
  name_with_pronouns: "Alice (she/her)",
  side: null,
  user_id: 1,
  side_label: null,
  corp_id: new Identity(),
  runner_id: new Identity(),
  registration_locked: false,
  include_in_stream: false,
  active: null,
  first_round_bye: false,
  manual_seed: null,
  fixed_table_number: null,
};

export const MockPlayerBob: Player = {
  id: 2,
  name: "Bob",
  pronouns: "he/him",
  name_with_pronouns: "Bob (he/him)",
  side: null,
  user_id: 2,
  side_label: null,
  corp_id: {
    name: "BANGUN: When Disaster Strikes",
    faction: "weyland-consortium",
  },
  runner_id: {
    name: "Barry “Baz” Wong: Tri-Maf Veteran",
    faction: "criminal",
  },
  registration_locked: false,
  include_in_stream: false,
  active: null,
  first_round_bye: false,
  manual_seed: null,
  fixed_table_number: null,
};

export const MockPairing1: Pairing = {
  id: 1,
  table_number: 1,
  table_label: "Table 1",
  policy: {
    self_report: false,
  },
  player1: MockPlayerAlice,
  player2: MockPlayerBob,
  score1: 0,
  score1_corp: 0,
  score1_runner: 0,
  score2: 0,
  score2_corp: 0,
  score2_runner: 0,
  score_label: "",
  intentional_draw: false,
  two_for_one: false,
  self_reports: null,
  reported: false,
  winner_game: null,
  loser_game: null,
  bracket_type: null,
  ui_metadata: {
    row_highlighted: false,
  },
};

export const MockRound1Timer: RoundTimer = {
  running: false,
  paused: false,
  started: false,
};

export const MockRound1: Round = {
  id: 1,
  number: 1,
  completed: false,
  pairings: [MockPairing1],
  pairings_reported: 0,
  length_minutes: 65,
  timer: MockRound1Timer,
  unpaired_players: [],
};

export const MockRound2: Round = {
  id: 2,
  number: 2,
  completed: false,
  pairings: [MockPairing1],
  pairings_reported: 0,
  length_minutes: 0,
  timer: {
    running: false,
    paused: false,
    started: false,
  },
  unpaired_players: [],
};

export const MockSwissStage: Stage = {
  id: 1,
  name: "Swiss",
  format: "swiss",
  is_single_sided: false,
  is_elimination: false,
  view_decks: false,
  rounds: [MockRound1],
};

export const MockSingleElimCutStage: Stage = {
  id: 2,
  name: "Single Elim",
  format: "single_elim",
  is_single_sided: false,
  is_elimination: true,
  view_decks: false,
  rounds: [],
};

export const MockDoubleElimCutStage: Stage = {
  id: 2,
  name: "Double Elim",
  format: "double_elim",
  is_single_sided: false,
  is_elimination: true,
  view_decks: false,
  rounds: [],
};

export const MockPairingsData: PairingsData = {
  tournament: MockTournament,
  policy: { update: true, custom_table_numbering: false },
  stages: [MockSwissStage],
};

export const MockSelfReportPlayer1Sweep: ScoreReport = {
  report_player_id: 1,
  score1: 6,
  score2: 0,
  intentional_draw: false,
  label: "6 - 0",
  score1_corp: 3,
  score2_corp: null,
  score1_runner: 3,
  score2_runner: null,
};

export const MockSelfReportCorpSplit: ScoreReport = {
  report_player_id: 1,
  score1: 3,
  score2: 3,
  intentional_draw: false,
  label: "3 - 3 (C)",
  score1_corp: 3,
  score2_corp: 3,
  score1_runner: null,
  score2_runner: null,
};

export const MockSelfReportRunnerSplit: ScoreReport = {
  report_player_id: 1,
  score1: 3,
  score2: 3,
  intentional_draw: false,
  label: "3 - 3 (R)",
  score1_corp: null,
  score2_corp: null,
  score1_runner: 3,
  score2_runner: 3,
};

export const MockSelfReportPlayer2Sweep: ScoreReport = {
  report_player_id: 1,
  score1: 0,
  score2: 6,
  intentional_draw: false,
  label: "0 - 6",
  score1_corp: null,
  score2_corp: 3,
  score1_runner: null,
  score2_runner: 3,
};
