<script lang="ts">
  import { getContext } from "svelte";
  import {
    type Pairing,
    type PairingsContext,
    type Round,
    type Stage,
  } from "./PairingsData";
  import {
    type ScoreReport,
    readableReportScore,
    reportsMatch,
  } from "./SelfReport";
  import FontAwesomeIcon from "../widgets/FontAwesomeIcon.svelte";
  import SelfReportOptions from "./SelfReportOptions.svelte";
  import ModalDialog from "../widgets/ModalDialog.svelte";
  import PlayerDisplay from "./PlayerDisplay.svelte";
  import AdminReportOptions from "./AdminReportOptions.svelte";
  import type { Player } from "../players/PlayersData";
  import type { Tournament } from "../tournaments/TournamentSettings";

  let {
    tournament,
    stage,
    round,
    pairing,
    deleteCallback,
    changePlayerSideCallback,
    reportScoreCallback,
    resetReportsCallback,
  }: {
    tournament: Tournament;
    stage: Stage;
    round: Round;
    pairing: Pairing;
    deleteCallback?: (pairingId: number) => void;
    changePlayerSideCallback?: (pairingId: number, side: string) => void;
    reportScoreCallback?: (
      pairingId: number,
      report: ScoreReport,
      selfReport: boolean,
    ) => void;
    resetReportsCallback?: (pairingId: number) => void;
  } = $props();

  const pairingsContext: PairingsContext = getContext("pairingsContext");

  let leftPlayer = $derived(
    stage.is_single_sided && pairing.player2.side == "corp"
      ? pairing.player2
      : pairing.player1,
  );
  let rightPlayer = $derived(
    stage.is_single_sided && pairing.player2.side == "corp"
      ? pairing.player1
      : pairing.player2,
  );
  let leftPlayerReport = $derived(
    pairing.self_reports?.find(
      (r) => r.report_player_id === leftPlayer.user_id,
    ),
  );
  let rightPlayerReport = $derived(
    pairing.self_reports?.find(
      (r) => r.report_player_id === rightPlayer.user_id,
    ),
  );
  let playersReported = $derived(
    leftPlayerReport !== undefined && rightPlayerReport !== undefined,
  );
  let selfReportsMatch = $derived(
    leftPlayerReport?.score1 === rightPlayerReport?.score1 &&
      leftPlayerReport?.score2 === rightPlayerReport?.score2 &&
      leftPlayerReport?.score1_corp === rightPlayerReport?.score1_corp &&
      leftPlayerReport?.score2_corp === rightPlayerReport?.score2_corp &&
      leftPlayerReport?.score1_runner === rightPlayerReport?.score1_runner &&
      leftPlayerReport?.score2_runner === rightPlayerReport?.score2_runner,
  );

  function changePlayerSide(player: Player, side: string) {
    if (
      !changePlayerSideCallback ||
      !confirm(`Are you sure you want to switch ${player.name} to ${side}?`)
    ) {
      return;
    }

    let adjSide = side;
    if (player !== pairing.player1) {
      adjSide = side === "corp" ? "runner" : "corp";
    }

    changePlayerSideCallback(pairing.id, adjSide);
  }
</script>

<div
  class="row m-1 round_pairing align-items-center table_{pairing.table_number} {pairing
    .ui_metadata.row_highlighted
    ? 'current_user_row'
    : ''}"
>
  <!-- Table label -->
  <div
    class="col-sm-2 {pairing.ui_metadata.row_highlighted
      ? 'font-weight-bold'
      : ''}"
  >
    {pairing.table_label}

    {#if pairingsContext.showOrganizerView && tournament.allow_streaming_opt_out}
      {#if pairing.player1.include_in_stream && pairing.player2.include_in_stream}
        <span title="May be included in video coverage.">
          <FontAwesomeIcon icon="video-camera" cssClass="text-success" />
        </span>
      {:else if stage.is_elimination}
        <span
          title="One or both players request not to be included in video coverage, but were informed this may not be possible in the cut."
        >
          <FontAwesomeIcon icon="video-camera" cssClass="text-warning" />
        </span>
      {:else}
        <span
          title="One or both players request not to not be included in video coverage."
        >
          <FontAwesomeIcon icon="video-camera" cssClass="text-secondary" />
          <FontAwesomeIcon icon="ban" cssClass="text-danger" />
        </span>
      {/if}
    {/if}
  </div>

  <!-- Player 1 -->
  {#if stage.view_decks}
    {#if pairingsContext.showOrganizerView}
      {#if stage.is_single_sided}
        <a
          href="/tournaments/{tournament.id}/rounds/{round.id}/pairings/{pairing.id}/view_decks?back_to=rounds"
        >
          <FontAwesomeIcon icon="eye" /> View decks
        </a>
      {/if}
    {:else if pairing.player1.side}
      <a
        href="/tournaments/{tournament.id}/rounds/{round.id}/pairings/{pairing.id}/view_decks?back_to=pairings"
      >
        <FontAwesomeIcon icon="eye" /> View decks
      </a>
    {:else}
      <a href="../players/{pairing.player1.id}/view_decks?back_to=pairings">
        <FontAwesomeIcon icon="eye" /> View decks
      </a>
    {/if}
  {/if}
  <PlayerDisplay
    player={leftPlayer}
    {pairing}
    left_or_right="left"
    is_single_sided={stage.is_single_sided}
    {changePlayerSide}
    show_ids={!stage.is_single_sided || pairing.player1.side !== null}
  />

  <!-- Score -->
  {#if pairingsContext.showOrganizerView && (!stage.is_single_sided || pairing.player1.side)}
    <AdminReportOptions {stage} {pairing} {reportScoreCallback} />
  {:else}
    <!-- Player view -->
    <div class="col-sm-2 centre_score">
      {pairing.score_label}
      {#if pairing.intentional_draw}
        <span class="badge badge-pill badge-secondary score-badge">ID</span>
      {/if}
      {#if pairing.two_for_one}
        <span class="badge badge-pill badge-secondary score-badge">2 for 1</span
        >
      {/if}
    </div>
  {/if}

  <!-- Player 2 -->
  <PlayerDisplay
    player={rightPlayer}
    {pairing}
    left_or_right="right"
    is_single_sided={stage.is_single_sided}
    {changePlayerSide}
    show_ids={!stage.is_single_sided || pairing.player2.side !== null}
  />
  {#if !pairingsContext.showOrganizerView && stage.view_decks && !pairing.player1.side && pairing.player2.id}
    <a href="../players/{pairing.player2.id}/view_decks?back_to=pairings">
      <FontAwesomeIcon icon="eye" /> View decks
    </a>
  {/if}

  <!-- Self-reporting -->
  {#if pairingsContext.showOrganizerView}
    <div class="row-sm1 mr-3">
      <button
        type="button"
        class="btn btn-primary mr-2"
        data-toggle="modal"
        data-target="#reports{pairing.id}"
      >
        Reports
        {#if !pairing.reported && pairing.self_reports?.length == 2 && !reportsMatch(pairing.self_reports[0], pairing.self_reports[1])}
          <FontAwesomeIcon
            icon="exclamation-triangle"
            dataTestId="reportConflict"
          />
        {/if}
      </button>
      <button
        class="btn btn-danger"
        onclick={() => {
          deleteCallback?.(pairing.id);
        }}
        aria-label="delete"
      >
        <FontAwesomeIcon icon="trash" />
      </button>
    </div>
  {:else}
    <div class="col-sm-2">
      {#if pairing.policy.self_report}
        <SelfReportOptions {stage} {pairing} {reportScoreCallback} />
      {/if}
      {#if pairing.self_reports && pairing.self_reports.length !== 0}
        Report: {readableReportScore(
          pairing.self_reports[0],
          pairing.player1.side,
          stage.is_single_sided,
        )}
      {/if}
    </div>
  {/if}

  {#snippet playerReport(player: Player, report: ScoreReport | undefined)}
    {player.name} reported:
    {#if report}
      {readableReportScore(report, pairing.player1.side, stage.is_single_sided)}
      {#if playersReported && !selfReportsMatch}
        <FontAwesomeIcon icon="times" />
      {/if}
    {:else}
      <FontAwesomeIcon icon="hourglass" />
    {/if}
  {/snippet}

  {#snippet acceptPlayerReportButton(player: Player, report: ScoreReport)}
    <button
      type="button"
      class="btn btn-primary"
      data-dismiss="modal"
      onclick={() => {
        reportScoreCallback?.(pairing.id, report, false);
      }}
      disabled={pairing.reported}
    >
      <FontAwesomeIcon icon="check" /> Accept {player.name}
    </button>
  {/snippet}

  <ModalDialog id="reports{pairing.id}" headerText="Player Self Reports">
    <p>
      <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -->
      {@render playerReport(leftPlayer, leftPlayerReport)}
    </p>
    <p>
      <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -->
      {@render playerReport(rightPlayer, rightPlayerReport)}
    </p>

    {#snippet footer()}
      {#if leftPlayerReport}
        <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -->
        {@render acceptPlayerReportButton(leftPlayer, leftPlayerReport)}
      {/if}
      {#if rightPlayerReport}
        <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -->
        {@render acceptPlayerReportButton(rightPlayer, rightPlayerReport)}
      {/if}
      {#if playersReported && !selfReportsMatch}
        <button
          type="button"
          class="btn btn-primary"
          onclick={() => {
            resetReportsCallback?.(pairing.id);
          }}
          title="Reset self reports of pairing"
        >
          <FontAwesomeIcon icon="undo" /> Reset
        </button>
      {/if}
    {/snippet}
  </ModalDialog>
</div>
