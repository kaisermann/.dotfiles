---
name: spoke-systems-investigation
description: Investigate Spoke runtime symptoms using runbooks and infra surfaces. Use when alerts, odd behavior, or hard-to-explain failures need structured investigation across systems.
---

Investigation workflow for Spoke combines engineering operations runbooks from the knowledge base (`~/.spoke-knowledge/`) with direct runtime surfaces such as GCP, Kubernetes, ArgoCD, queues, and logs.

Use `spoke-knowledge` or `spoke-ask` only when the investigation needs them.

When runtime evidence points toward a likely implementation fault, continue into the active local codebase and any relevant supporting codebases available on the machine to inspect code, reproduce the behavior, or write a focused failing test.

## Before You Investigate

Treat missing runtime tools as a capability constraint, not a gate. They narrow which debugging paths are available; they do not make the workflow unusable.

Run `bash scripts/validate.sh` to check which runtime tools (`jq`, `curl`, `gcloud`, `kubectl`, Argo rollouts) are available.

When the investigation needs Twist history, run `spoke-ask` and let it handle its own runtime checks.

## When To Use

- an alert fires and you need to triage whether it is real, noisy, or rollout-related
- something in production or staging feels wrong, but the failure mode is still unclear
- a customer report or internal observation points to backend, infra, async, or rollout problems
- you need a repeatable debugging flow across multiple Spoke systems and tools

## When Not To Use

- the problem is clearly code-level in one codebase, has a direct reproduction path, and does not need live-system investigation
- you only need background context or architecture understanding: use `spoke-knowledge`
- you only need historical Twist context: use `spoke-ask`

## Investigation Flow

### 1. Classify the weirdness first

Start by deciding which shape you are in:

- active incident or customer-facing outage
- noisy alert or degraded rollout
- async, trigger, queue, or deadletter problem
- customer-specific or data-specific weirdness
- performance or latency degradation
- bad result quality, especially optimization or sync behavior

Do not jump into random logs before deciding the likely system boundary.

### 2. Pull the smallest stable identifiers

Get exact identifiers early. Prefer:

- trace ID
- request path
- pod name
- namespace or service name
- team, route, stop, plan, or operation ID
- deadletter subscription, topic, or queue name
- rollout name, ReplicaSet name, or app name

At Spoke, investigations move much faster once the exact object is known.

### 3. Route to the right runbook

Start with the smallest runbook that matches the failure shape:

- incident handling and containment: `content/engineering/_how-to/incident-response.md`
- choosing logs vs metrics vs traces: `content/engineering/infra/_how-to/monitoring-investigation.md`
- where to look in GCP, GKE, ArgoCD, Pub/Sub, or Cloud Tasks: `content/engineering/infra/_how-to/gcp-debugging-navigation.md`
- pod restarts, OOMs, CrashLoopBackOff, or rollout health: `content/engineering/infra/_how-to/k8s-alert-triage.md`
- deadletters, replay, or drop-vs-replay decisions: `content/engineering/infra/_how-to/deadletter-queue-triage.md`
- optimization failures or suspicious route quality: `content/engineering/_how-to/optimization-investigation.md`

If the issue is broad and the right runbook is unclear, start from `content/engineering/infra/_index.md`.

### 4. Prefer hosted surfaces before pod-level digging

Default order:

1. ArgoCD or rollout state for deployment questions
2. Metrics and logs for blast radius and raw failure signals
3. Traces when request-level or job-level timing matters
4. Queue and deadletter state for async systems
5. Direct pod inspection only when the hosted surfaces stop being enough

Recurring Spoke heuristic: suspect deploy drift, env mismatch, old ReplicaSets, or publisher/subscriber version skew earlier than deep code-path theories.

If one surface is unavailable in the current environment, continue with the others instead of stopping the investigation. For example:

- no `kubectl` context: continue with GCP logs, Argo UI, runbooks, and Ask Spoke
- no `gcloud` auth: continue with Argo, runbooks, local code, supporting codebases on the machine, and Ask Spoke
- no direct runtime access at all: focus on runbook routing, historical context, and the next concrete check for someone with access

### 5. Use Ask Spoke deliberately

When the current weirdness might have happened before, query `spoke-ask` for:

- similar alerts or bug threads
- prior incidents with the same service, symptom, or error string
- known rollout pitfalls, replay steps, or debugging commands
- who previously debugged this class of problem

Prompt shape to prefer:

```text
Search Twist for prior incidents or weirdness involving <service/symptom>. Summarize the investigation order, tools used, exact identifiers that mattered, and whether the fix was code, config, rollout, or replay.
```

Treat Ask Spoke results as leads, not ground truth. Check recency and current system shape before acting on them.

### 6. Return a debugging brief

Do not force a rigid output format by default. Match the response to the investigation state and the user's need.

Use `assets/debug-brief-template.md` only when a compact internal handoff or status snapshot would help.

The important thing is to leave the user with:

- what seems wrong
- where it most likely lives
- what signals already support that view
- the next 1-3 checks that reduce uncertainty fastest
- any likely containment or rollback path
- whether this seems like a recurring gap in runbooks or telemetry

## Guardrails

- Start with containment when there is real customer impact.
- Do not assume an alert is actionable until you verify whether it is noise, transient, or rollout-related.
- Prefer exact identifiers over broad keyword searches.
- Prefer hosted observability surfaces before direct pod or container access.
- Missing local access to one surface should degrade the workflow, not block it outright.
- Do not treat stale Twist guidance as current truth without checking dates and current docs.
- If direct reproduction becomes the fastest path, switch to the active local codebase, any relevant supporting codebases on the machine, and a reproducing test rather than forcing everything through live systems.
- Keep the investigation focused on runtime weirdness and cross-system debugging. Do not turn it into a generic code-debugging flow.

## See Also

- `spoke-knowledge` for durable context and runbook routing
- `spoke-ask` for Twist history and prior incident search
- `content/company/_reference/internal-tools.md` for related internal tool entrypoints
