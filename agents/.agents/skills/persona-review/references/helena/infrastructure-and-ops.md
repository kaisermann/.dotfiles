# Infrastructure and Ops

Terraform idioms, Kubernetes deployment awareness, Cloud Armor configuration, IAM security boundaries, Pub/Sub settings, and operational correctness. Drawn primarily from Helena's infra repo review corpus.

## Terraform

**What to look for:**

- `terraform refresh` used directly — should be `terraform apply -refresh-only` (the former is deprecated and bypasses the plan/apply workflow).
- Resources that should use `lifecycle { prevent_destroy = true }` for stateful infrastructure.
- Missing `depends_on` for implicit dependencies between resources.
- Hard-coded values that should be variables for environment portability.

**Severity:** Warning for deprecated commands. Info for style improvements.

**Corpus examples:**

- _"Use `terraform apply -refresh-only` instead of `terraform refresh`"_ (infra)

## Cloud Armor and WAF

**What to look for:**

- Rule ordering issues — Cloud Armor evaluates rules by priority number, and misordered rules can bypass intended protections.
- Per-key throttling configuration that doesn't account for NAT or shared IP scenarios.
- Missing reCAPTCHA validation on public-facing endpoints.
- Overly broad allowlists that weaken the security posture.

**Severity:** Critical for rule ordering that could bypass protection. Warning for throttling configuration issues.

## IAM and Security Boundaries

**What to look for:**

- IAM policy CEL conditions with caveats that aren't documented (e.g., conditions that don't apply to all resource types).
- Workload identity misconfiguration — K8s service accounts mapped to wrong GCP service accounts.
- Staging secrets or service accounts referenced in production configuration.
- Overly permissive IAM roles where a more specific role exists.
- Missing principal distinction between environments.

**Severity:** Critical for staging/prod secret leaks. Warning for overly permissive roles.

**Corpus examples:**

- _"This workload identity binding maps to the wrong service account"_ (infra)
- _"Staging secrets should never appear in production configuration"_ (infra)

## Kubernetes and Helm

**What to look for:**

- Deployment assumptions that old and new pods won't coexist — they always do during rollout.
- Missing readiness/liveness probes or probes with incorrect thresholds.
- Helm chart organization issues — values that should be parameterized but are hard-coded.
- Resource requests/limits that don't match observed usage patterns.

**Severity:** Warning for deployment safety assumptions. Info for Helm organization.

## Pub/Sub and Messaging

**What to look for:**

- Subscription acknowledgment deadlines that are too short for the processing time.
- Missing dead-letter topic configuration for subscriptions that process fallible messages.
- At-least-once delivery not accounted for — handlers must be idempotent.
- Message ordering assumptions without ordering keys configured.

**Severity:** Warning for missing idempotency awareness. Info for configuration tuning.

## Istio and Networking

**What to look for:**

- Routing rules that could cause traffic splits during rollout.
- Missing access log configuration for debugging.
- Telemetry configuration that doesn't match the observability requirements.

**Severity:** Info for most networking suggestions.

## AI-Generated Documentation Skepticism

Helena is notably skeptical of AI-generated infrastructure documentation, flagging potential hallucinations and inaccuracies.

**What to look for:**

- Documentation that reads like AI-generated content — generic descriptions, plausible-sounding but unverified claims.
- Infrastructure docs that don't match the actual resource configuration.

**Severity:** Warning for documentation that may contain hallucinations.

## Anti-Patterns

1. **`terraform refresh` directly** — Use `terraform apply -refresh-only` instead.
2. **Cloud Armor rule misordering** — Priority numbers must be carefully ordered to avoid bypass.
3. **Staging secrets in prod** — Environment-specific secrets must never cross boundaries.
4. **Non-idempotent Pub/Sub handlers** — At-least-once delivery means handlers must tolerate duplicates.
5. **Atomic deployment assumptions** — K8s rollouts always have a window where old and new pods coexist.
6. **AI-generated infra docs** — Must be verified against actual resource configuration before merging.
