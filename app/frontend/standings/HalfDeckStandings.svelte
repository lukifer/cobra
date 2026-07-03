<script lang="ts">
  import type { HalfDeckStanding, CombinedDeckStanding } from "./StandingsData";
  import Identity from "../identities/Identity.svelte";
  import FontAwesomeIcon from "../widgets/FontAwesomeIcon.svelte";
  import Tooltip from "./Tooltip.svelte";

  let {
    standings,
    rounds_complete,
    combined,
    title
  }: {
    standings: HalfDeckStanding[];
    rounds_complete: number;
    combined?: boolean;
    title?: string;
  } = $props();

  function printSOS(sos: string) {
    return parseFloat(sos).toLocaleString(undefined, {
      minimumFractionDigits: 4,
      maximumFractionDigits: 4,
    });
  }

  function sideLabel(side: string) {
    return side === "corp" ? "Corp" : "Runner";
  }

  function combinedStandings() {
    const standingsByPlayer = standings.reduce<Record<string, HalfDeckStanding[]>>((acc, standing) => {
      const pid = `${standing.player.id}`;
      acc[pid] ??= [];
      acc[pid].push(standing);
      return acc;
    }, {});

    const combinedPlayers: Omit<CombinedDeckStanding, 'position'>[] = Object.keys(standingsByPlayer).map(pid => {
      const playerStanding = standingsByPlayer[pid];
      const playerStanding1 = playerStanding[0];
      const playerStanding2 = playerStanding[1];
      return ({
        sos: `${(parseFloat(playerStanding1.sos) + parseFloat(playerStanding2.sos)) / 2}`,
        extended_sos: `${(parseFloat(playerStanding1.extended_sos) + parseFloat(playerStanding2.extended_sos)) / 2}`,
        points: playerStanding1.points + playerStanding2.points,
        corp_identity: playerStanding.find(x => x.side === "corp")?.identity ?? null,
        runner_identity: playerStanding.find(x => x.side === "runner")?.identity ?? null,
        player: playerStanding[0].player,
      })
    });

    return combinedPlayers.sort((a, b) => {
      if (a.points !== b.points) return a.points > b.points ? -1 : 1;
      if (a.sos !== b.sos) return a.sos > b.sos ? -1 : 1;
      if (a.extended_sos !== b.extended_sos) return a.extended_sos > b.extended_sos ? -1 : 1;
      return 0;
    }).map((x, n) => ({
      ...x,
      position: n+1,
    } as CombinedDeckStanding));
  }
</script>

<h3>{title ?? 'Half-deck standings'}</h3>
<p>After {rounds_complete} rounds</p>

<table class="table table-striped standings">
  <thead>
    <tr>
      <th>Rank</th>
      <th>Contributor</th>
      {#if !combined}
      <th>Side</th>
      {/if}
      <th>ID</th>
      <th>Points</th>
      <th>SoS</th>
      <th>ESoS</th>
    </tr>
  </thead>
  <tbody>
    {#each (combined ? combinedStandings() : standings) as standing (standing.position)}
      <tr>
        <td>{standing.position}</td>
        <td class="d-flex flex-row space-x-2">
          <p class="mr-2">{standing.player.name_with_pronouns}</p>
          {#if !standing.player.active}
            <Tooltip text="(dropped)">
              <FontAwesomeIcon icon="sign-out" />
            </Tooltip>
          {/if}
        </td>
        {#if 'side' in standing}
        <td>{sideLabel(standing.side)}</td>
        {/if}
        {#if 'identity' in standing}
        <td class="ids">
          <Identity
            identity={standing.identity ?? undefined}
            name_if_missing={sideLabel(standing.side)}
          />
        </td>
        {:else}
          <td class="ids">
          {#if 'corp_identity' in standing && standing.corp_identity}
            <Identity
              identity={standing.corp_identity}
            />
          {/if}
          {#if 'runner_identity' in standing && standing.runner_identity}
            <Identity
              identity={standing.runner_identity}
            />
          {/if}
          </td>
        {/if}
        <td>{standing.points}</td>
        <td>{printSOS(standing.sos)}</td>
        <td>{printSOS(standing.extended_sos)}</td>
      </tr>
    {/each}
  </tbody>
</table>
