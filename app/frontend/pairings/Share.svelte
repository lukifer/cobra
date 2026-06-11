<script lang="ts">
  import { onMount } from "svelte";
  import SharePage from "./SharePage.svelte";
  import FontAwesomeIcon from "../widgets/FontAwesomeIcon.svelte";
  import { loadRound, type RoundData } from "./RoundData";
  import type { Player } from "../players/PlayersData";

  let {
    tournamentId,
    roundId,
  }: {
    tournamentId: number;
    roundId: number;
  } = $props();

  const MAX_MARKDOWN_PAGE_LENGTH = 2000;  // Break things up roughly around the Discord message limit.

  let betaEnabledCookie: CookieListItem | null = $state(null);
  let data: RoundData | undefined = $state();
  let markdownPages: string[] = $state([]);

  onMount(async () => {
    betaEnabledCookie = await cookieStore.get("beta_enabled");
    data = await loadRound(tournamentId, roundId);

    // Build markdown pages
    const pageHeader = `# ${data.stage.format} - Round ${data.round.number} Pairings`;
    let currentPage = pageHeader;
    for (const pairing of data.round.pairings) {
      let tableMarkdown = `\n### Table ${pairing.table_number}`;
      tableMarkdown += `\n- ${pairingPlayerMarkdown(pairing.player1, data.stage.is_single_sided)}`;
      tableMarkdown += `\n- ${pairingPlayerMarkdown(pairing.player2, data.stage.is_single_sided)}`;

      if (
        currentPage.length + tableMarkdown.length >=
        MAX_MARKDOWN_PAGE_LENGTH
      ) {
        markdownPages.push(currentPage);
        currentPage = pageHeader;
      }

      currentPage += tableMarkdown;
    }
    markdownPages.push(currentPage);
  });

  function pairingPlayerMarkdown(player: Player, isSingleSided: boolean) {
    let markdown = `**${player.name_with_pronouns}**`;
    if (isSingleSided) {
      markdown += ` - ${player.side_label}`;
    }
    return markdown;
  }
</script>

<p>
  <a
    href={betaEnabledCookie?.value === "true"
      ? `/beta/tournaments/${tournamentId}/rounds`
      : `/tournaments/${tournamentId}/rounds`}
    class="btn btn-primary"
  >
    <FontAwesomeIcon icon="arrow-left" /> Back to Pairings
  </a>
</p>

{#if data}
  <h2>Export Pairings as Markdown</h2>

  {#each markdownPages as text, i (i)}
    <div style="margin-bottom: 2rem">
      <SharePage {text} page={i + 1} />
    </div>
  {/each}
{:else}
  <div class="d-flex align-items-center m-2">
    <div class="spinner-border m-auto"></div>
  </div>
{/if}
