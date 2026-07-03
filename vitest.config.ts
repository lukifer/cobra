import { defineConfig } from "vitest/config";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { svelteTesting } from "@testing-library/svelte/vite";

export default defineConfig({
  test: {
    clearMocks: true,
    projects: [
      {
        plugins: [svelte(), svelteTesting()],
        test: {
          environment: "jsdom",
          setupFiles: ["./vitest-setup.svelte.ts"],
          globals: true,
          include: ["app/**/*.svelte-test.ts"],
          clearMocks: true,
        },
      },
      {
        test: {
          environment: "node",
          setupFiles: ["./vitest-setup.msw.ts"],
          include: ["app/**/*.msw-test.ts"],
          clearMocks: true,
        },
      },
      {
        test: {
          environment: "node",
          include: ["app/**/*.test.ts"],
          clearMocks: true,
        },
      },
    ],
  },
});
