import type { Plugin } from "@opencode-ai/plugin"

const personalBeadsDir = "/Users/kaisermann/.beads"

export const BeadsGlobalPlugin: Plugin = async ({ $ }) => {
  try {
    await $`BEADS_DIR=${personalBeadsDir} bd where`.quiet()
  } catch {
    console.warn(`[beads-global] personal beads store unavailable at ${personalBeadsDir}`)
    return {}
  }

  return {
    "shell.env": async (_input, output) => {
      output.env.BEADS_DIR = personalBeadsDir
    },
  }
}
