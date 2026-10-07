<script lang="ts">
  import { getFaction } from "../utils/factions";

  let { name, suffix }: { name: string, suffix?: string } = $props();
</script>

{#if name}
  <div class={name}>
    <i class="fa icon icon-{name}"></i>
    {getFaction(name).displayName}
    {suffix ?? ''}
  </div>
{/if}
