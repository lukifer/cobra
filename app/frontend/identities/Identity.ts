declare const Routes: {
  beta_identities_path: () => string;
};

export async function loadIdentityNames() {
  const response = await fetch(Routes.beta_identities_path(), {
    method: "GET",
  });

  return (await response.json()) as IdentityNames;
}

export interface IdentityName {
  label: string;
  value: string;
}

export interface IdentityNames {
  corp: IdentityName[];
  runner: IdentityName[];
}

export class Identity {
  name = "";
  faction: string | null = null;
  side?: "corp" | "runner";
}
