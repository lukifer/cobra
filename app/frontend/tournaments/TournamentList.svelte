<script lang="ts">
  import { onMount } from "svelte";
  import type {
    TournamentInfo,
    TournamentsResponse,
    TournamentTypesResponse,
  } from "../lib/api_types";
  import GlobalMessages from "../widgets/GlobalMessages.svelte";
  import PagingRow from "../widgets/PagingRow.svelte";
  import TournamentRow from "../widgets/TournamentRow.svelte";
  import { globalMessages } from "../utils/GlobalMessageState.svelte";

  let { typeId, userId }: { typeId: string | null; userId: number | null } =
    $props();

  let tournaments: TournamentInfo[] = $state([]);
  let tournamentTypes: Record<string, string> = $state({});
  let loading = $state(true);
  let prevLink: string | null = $state(null);
  let nextLink: string | null = $state(null);
  let tournamentTypeName: string | null = $state(null);
  let heading = $derived(
    !typeId
      ? "Recent Tournaments"
      : tournamentTypeName
        ? `Tournaments: ${tournamentTypeName}`
        : "Tournaments",
  );

  function tournamentsApiUrl(
    tournamentTypeId: string | null | undefined,
  ): string {
    const query = [
      "/api/v1/public/tournaments?page[size]=10",
      "include=tournament_type",
      "sort=-date,name",
    ];

    if (tournamentTypeId && tournamentTypeId.length > 0) {
      query.push(`filter[tournament_type_id]=${tournamentTypeId}`);
    }

    return query.join("&");
  }

  const fetchTournamentsUrl = $derived(tournamentsApiUrl(typeId));

  async function loadTournaments(url: string): Promise<void> {
    loading = true;

    try {
      const response = await fetch(url, {
        headers: {
          Accept: "application/vnd.api+json",
          "Content-Type": "application/vnd.api+json",
        },
      });
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      const data = (await response.json()) as TournamentsResponse;
      tournaments = data.data;

      if (data.included) {
        let newTypes: Record<string, string> = {};
        for (const included of data.included) {
          if (included.type === "tournament_types") {
            newTypes[included.id.toString()] = included.attributes.name;
          }
        }
        tournamentTypes = newTypes;
      }

      prevLink = data.links?.prev ?? null;
      nextLink = data.links?.next ?? null;
    } catch (e) {
      const err = e as Error;
      globalMessages.errors.push(`Failed to load tournaments: ${err.message}`);
    } finally {
      loading = false;
    }
  }

  async function loadTournamentTypeName(): Promise<void> {
    if (!typeId) {
      tournamentTypeName = null;
      return;
    }

    try {
      const response = await fetch("/api/v1/public/tournament_types", {
        headers: {
          Accept: "application/vnd.api+json",
          "Content-Type": "application/vnd.api+json",
        },
      });
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = (await response.json()) as TournamentTypesResponse;
      const matchingType = data.data.find(
        (tournamentType) => String(tournamentType.id) === typeId,
      );
      tournamentTypeName = matchingType?.attributes.name ?? null;
    } catch {
      tournamentTypeName = null;
    }
  }

  async function goToPreviousPage(): Promise<void> {
    if (!prevLink || loading) return;

    await loadTournaments(prevLink);
  }

  async function goToNextPage(): Promise<void> {
    if (!nextLink || loading) return;

    await loadTournaments(nextLink);
  }

  onMount(async () => {
    if (typeId) {
      await Promise.all([
        loadTournaments(fetchTournamentsUrl),
        loadTournamentTypeName(),
      ]);
      return;
    }

    await loadTournaments(fetchTournamentsUrl);
  });
</script>

<div>
  <GlobalMessages />

  <h1>{heading}</h1>

  <div>
    <PagingRow
      {loading}
      canGoBack={!!prevLink}
      canGoNext={!!nextLink}
      onBack={goToPreviousPage}
      onNext={goToNextPage}
    />

    {#if tournaments.length === 0 && !loading}
      <div class="m-3">No tournaments found for this type.</div>
    {:else}
      {#each tournaments as tournament (tournament.id)}
        <TournamentRow
          showDelete={true}
          {tournament}
          {userId}
          tournamentTypeName={tournament.attributes.tournament_type_id
            ? tournamentTypes[
                tournament.attributes.tournament_type_id.toString()
              ]
            : null}
        />
      {/each}
    {/if}

    <PagingRow
      {loading}
      canGoBack={!!prevLink}
      canGoNext={!!nextLink}
      onBack={goToPreviousPage}
      onNext={goToNextPage}
    />
  </div>
</div>
