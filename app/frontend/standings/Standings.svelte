<script lang="ts">
  import { onMount } from "svelte";
  import DoubleElimStandings from "./DoubleElimStandings.svelte";
  import type {
    CutStage,
    Stage,
    StandingsData,
    SwissStage,
  } from "./StandingsData";
  import HalfDeckStandings from "./HalfDeckStandings.svelte";
  import { loadStandings } from "./StandingsData";
  import SwissStandings from "./SwissStandings.svelte";

  let { tournamentId }: { tournamentId: number } = $props();
  let data = $state<StandingsData | undefined>(undefined);

  onMount(async () => {
    data = await loadStandings(tournamentId);
  });

  function cutStage(stage: Stage): CutStage {
    return stage as CutStage;
  }

  function swissStage(stage: Stage): SwissStage {
    return stage as SwissStage;
  }

  function maxRoundsComplete(stages: Stage[]): number {
    return stages.reduce(
      (max, stage) => Math.max(max, stage.rounds_complete),
      0,
    );
  }
</script>

<h2>Standings</h2>

{#if data}
  {#each data.stages as stage (stage.format)}
    {#if stage.format === "single_elim" || stage.format === "double_elim"}
      <DoubleElimStandings stage={cutStage(stage)} />
    {:else}
      <SwissStandings
        stage={swissStage(stage)}
        manual_seed={data.manual_seed}
      />
    {/if}
  {/each}

  {#if data.smashup && data.half_deck_standings.length > 0}
    <HalfDeckStandings
      standings={data.half_deck_standings.filter(x => x.side === 'corp')}
      rounds_complete={maxRoundsComplete(data.stages)}
      title="Corp Half-Deck Standings"
    />
    <HalfDeckStandings
      standings={data.half_deck_standings.filter(x => x.side === 'runner')}
      rounds_complete={maxRoundsComplete(data.stages)}
      title="Runner Half-Deck Standings"
    />
    <HalfDeckStandings
      standings={data.half_deck_standings}
      rounds_complete={maxRoundsComplete(data.stages)}
      title="Combined Half-Deck Standings"
      combined={true}
    />
  {/if}
{:else}
  <div class="d-flex align-items-center m-2">
    <div class="spinner-border m-auto"></div>
  </div>
{/if}
