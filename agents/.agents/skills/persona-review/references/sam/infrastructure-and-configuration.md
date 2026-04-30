# Infrastructure and Configuration

Terraform intent, monitor behavior, environment parity, and whether a config change will actually behave the way the author expects. Sam's infra comments are practical and semantics-driven rather than style-driven.

## Environment Parity

**What to look for:**

- Non-prod config that differs from prod for historical reasons rather than intentional product behavior.
- Terraform values copied forward without re-checking whether the original divergence still matters.
- Follow-up-safe parity cleanups left inline when they are unrelated to the PR's main goal.

**Severity:** Info when the mismatch is low risk and can be split out. Warning when the divergence is causing incorrect behavior.

**Corpus examples:**

- _"We can almost certainly change these to use the same config as prod. I think the only reason they are different is that we never bothered changing them in dev because it didn't affect much"_ (infra #473)

## Monitor and Config Semantics

**What to look for:**

- Status page or monitoring config copied from another check without updating the real target.
- Health or degradation thresholds whose meaning does not match the intended alerting behavior.
- Config that looks valid syntactically but would never report the desired state.

**Severity:** Warning when monitoring would silently misreport health. Info for cleanup or rebrand alignment.

**Corpus examples:**

- _"I think this was just copied from the uptime check, I've created a new one for api.spoke.com. Seems we just forgot to do it during the rebrand"_ (infra #482)
- _"Does this mean it's never considered degraded?"_ (infra #485)

## Anti-Patterns

1. **Historical drift in env config** - Dev/staging values left divergent with no current reason.
2. **Copy-pasted monitor config** - Reusing a check without changing the target or semantics.
3. **Thresholds that never trigger** - Config that cannot express degraded state the way the team expects.
