<script lang="ts">
  import { onMount } from "svelte";
  import {
    createTournament,
    emptyTournamentOptions,
    type Errors,
    type FeatureFlags,
    loadNewTournament,
    Tournament,
    type TournamentOptions,
    ValidationError,
  } from "./TournamentSettings";
  import TournamentSettingsForm from "./TournamentSettingsForm.svelte";

  let tournament = $state<Tournament | undefined>(undefined);
  let options = $state<TournamentOptions>(emptyTournamentOptions());
  let featureFlags = $state<FeatureFlags>({});
  let csrfToken = "";
  let errors = $state<Errors>({});

  onMount(async () => {
    // Fetch any initial data needed for the form (like available options)
    const data = await loadNewTournament();
    tournament = data.tournament;
    options = data.options;
    featureFlags = data.feature_flags;
    csrfToken = data.csrf_token;
  });

  async function submitNewTournament(tournament: Tournament) {
    errors = {};

    try {
      const response = await createTournament(csrfToken, tournament);
      window.location.href = response.url;
    } catch (error) {
      if (error instanceof ValidationError) {
        errors = error.errors;
      } else {
        errors = { base: ["An unexpected error occurred. Please try again."] };
      }

      return false;
    }

    return true;
  }
</script>

<div class="row">
  <div class="col-12">
    <h1>Create a tournament</h1>

    {#if errors.base}
      <div class="alert alert-danger">{errors.base}</div>
    {:else if tournament}
      <TournamentSettingsForm
        {tournament}
        {options}
        {featureFlags}
        onSubmitCallback={submitNewTournament}
        submitLabel="Create"
        submitIcon="plus"
        {errors}
      />
    {:else}
      <div class="d-flex align-items-center m-2" data-testid="loading-spinner">
        <div class="spinner-border m-auto"></div>
      </div>
    {/if}
  </div>
</div>
