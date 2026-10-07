<script lang="ts">
  import Svelecte from "svelecte";
  // import Identity from "../identities/Identity.svelte";
  import type { IdentityName } from "../identities/Identity";
  import type { IdentityCount } from "../tournaments/TournamentSettings";

  let {
    id,
    identityNames,
    value = $bindable(),
    cssClass = "",
    placeholder = "Search for ID",
    enabled = true,
    duplicateWarning,
  }: {
    id: string;
    identityNames: IdentityName[];
    value?: string;
    cssClass?: string;
    placeholder?: string;
    enabled?: boolean;
    duplicateWarning?: IdentityCount[]
  } = $props();

  let selectedValue = $derived.by(() => {
    const id = identityNames.find((id) => id.value === value);
    return id ? id.label : null;
  });

  let showDupeWarning = (identity: string) => 
    (duplicateWarning ?? []).findIndex(({ identity_name }) => identity_name === identity) >= 0
  ;

  // We save the display name instead of the searchable text so we need to
  // manually set the value since we can't bind to the display text with
  // Svelecte.
  function idChanged(selected: IdentityName | null) {
    value = selected ? selected.value : "";
  }
</script>

<div>
<Svelecte
  name={id}
  inputId={id}
  controlClass={cssClass}
  disabled={!enabled}
  {placeholder}
  options={identityNames}
  labelField="value"
  valueField="label"
  bind:value={selectedValue}
  onChange={idChanged}
/>
<!-- selectedValue: {selectedValue} {`${showDupeWarning(selectedValue ?? 'nope')}`} -->
{#if showDupeWarning(selectedValue ?? '')}
  <div class="alert alert-danger">
    <!-- <b>Warning:</b> There is already a player registered using <Identity identity={selectedValue} />. It is strongly encouraged that every participant use unique identities. Please talk to the organizer before registering. -->
    <b>Warning:</b> There is already a player registered with this identity. It is strongly encouraged that every participant use unique identities. Please talk to the organizer before registering.
  </div>
{/if}
</div>
