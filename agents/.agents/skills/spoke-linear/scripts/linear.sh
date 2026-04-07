#!/bin/bash

# Linear GraphQL API wrapper for agentic workflows
set +H  # Disable history expansion
set -o posix  # Enable POSIX mode for better compatibility
set -euo pipefail  # Prevents errors in a pipeline from being masked

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" != "help" && "${1:-}" != "--help" && "${1:-}" != "-h" && -n "${1:-}" ]]; then
    "$SCRIPT_DIR/validate.sh" >/dev/null
fi

LINEAR_API_URL="https://api.linear.app/graphql"
DEBUG="${DEBUG:-0}"
PRODUCT_TEAM_ID="ec9bb50d-cb17-458e-8368-0e2d99f2bba0"

if [ -z "${LINEAR_API_KEY:-}" ]; then
    [ -f "$HOME/.spoke-env" ] && source "$HOME/.spoke-env"
fi

if [ -z "${LINEAR_API_KEY:-}" ]; then
    echo "Error: LINEAR_API_KEY not configured" >&2
    echo "Generate a key at: https://linear.app/getcircuit/settings/account/security" >&2
    echo "Add to ~/.spoke-env: LINEAR_API_KEY=your_token_here" >&2
    exit 1
fi

linear_query() {
    local query="$1"
    local variables="${2:-}"
    if [ -z "$variables" ]; then
        variables="{}"
    fi

    local payload=$(jq -n -c \
        --arg query "$query" \
        --argjson variables "$variables" \
        '{"query": $query, "variables": $variables}')

    if [ "$DEBUG" = "1" ]; then
        echo "Query: $query" >&2
        echo "Variables: $variables" >&2
    fi

    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: $LINEAR_API_KEY" \
        --data "$payload" \
        "$LINEAR_API_URL" \
        --fail-with-body 2>&1)

    if [ $? -ne 0 ]; then
        echo "Error: Failed to connect to Linear API" >&2
        echo "Details: $response" >&2
        exit 1
    fi

    if printf '%s\n' "$response" | jq -e '.errors' > /dev/null 2>&1; then
        local error_message=$(printf '%s\n' "$response" | jq -r '.errors[0].message // "Unknown error"')
        local error_code=$(printf '%s\n' "$response" | jq -r '.errors[0].extensions.code // "UNKNOWN"')

        case "$error_code" in
            RATELIMITED)
                echo "Error: Rate limit exceeded. Try again later." >&2
                ;;
            UNAUTHORIZED)
                echo "Error: Invalid API key. Check LINEAR_API_KEY in ~/.spoke-env" >&2
                ;;
            *)
                echo "Error: $error_message" >&2
                ;;
        esac

        if [ "$DEBUG" = "1" ]; then
            echo "Full error response:" >&2
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi

    printf '%s\n' "$response"
}

cmd_issue_get() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Issue identifier required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    local issue_id="$identifier"
    local query='query($id: String!) { issue(id: $id) { id identifier title description priority state { name } assignee { name } creator { name } parent { identifier title } children { nodes { identifier title state { name } } } relations { nodes { type relatedIssue { identifier title state { name } } } } inverseRelations { nodes { type issue { identifier title state { name } } } } project { name } labels { nodes { name } } attachments { nodes { title subtitle url sourceType } } documents { nodes { slugId title url } } branchName createdAt updatedAt url } }'
    local variables=$(jq -n -c --arg id "$issue_id" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")

    printf '%s\n' "$response" | jq '.data.issue | {
        identifier,
        title,
        description,
        priority,
        state: .state.name,
        assignee: .assignee.name,
        creator: .creator.name,
        parent: (if .parent.identifier then {identifier: .parent.identifier, title: .parent.title} else null end),
        children: [.children.nodes[] | {identifier, title, state: .state.name}],
        relations: [.relations.nodes[] | {type, issue: {identifier: .relatedIssue.identifier, title: .relatedIssue.title, state: .relatedIssue.state.name}}],
        inverseRelations: [.inverseRelations.nodes[] | {type, issue: {identifier: .issue.identifier, title: .issue.title, state: .issue.state.name}}],
        project: .project.name,
        labels: [.labels.nodes[].name],
        attachments: [.attachments.nodes[] | {title, subtitle, url, sourceType}],
        documents: [.documents.nodes[] | {slugId, title, url}],
        branchName,
        createdAt,
        updatedAt,
        url
    }'
}

cmd_issue_list() {
    local query_text=""
    local limit=5
    local after_cursor=""
    local state_filter=""
    local assignee_filter=""
    local label_filters=()
    local project_filter=""
    local updated_after=""
    local created_after=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --query)
                query_text="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            --after)
                after_cursor="$2"
                shift 2
                ;;
            --state)
                state_filter="$2"
                shift 2
                ;;
            --assignee)
                assignee_filter="$2"
                shift 2
                ;;
            --label)
                label_filters+=("$2")
                shift 2
                ;;
            --project)
                project_filter="$2"
                shift 2
                ;;
            --updated-after)
                updated_after="$2"
                shift 2
                ;;
            --created-after)
                created_after="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh help' for usage information" >&2
                exit 1
                ;;
        esac
    done

    if [ "$limit" -gt 250 ]; then
        limit=250
    fi

    local and_conditions=()
    and_conditions+=("{ team: { id: { eq: \"$PRODUCT_TEAM_ID\" } } }")

    if [ -n "$state_filter" ]; then
        and_conditions+=("{ state: { name: { containsIgnoreCase: \"$state_filter\" } } }")
    fi

    if [ -n "$assignee_filter" ]; then
        if [[ "$assignee_filter" == *"@"* ]]; then
            and_conditions+=("{ assignee: { email: { eq: \"$assignee_filter\" } } }")
        else
            and_conditions+=("{ assignee: { name: { containsIgnoreCase: \"$assignee_filter\" } } }")
        fi
    fi

    if [ ${#label_filters[@]} -gt 0 ]; then
        for label in "${label_filters[@]}"; do
            and_conditions+=("{ labels: { some: { name: { containsIgnoreCase: \"$label\" } } } }")
        done
    fi

    if [ -n "$project_filter" ]; then
        and_conditions+=("{ project: { name: { containsIgnoreCase: \"$project_filter\" } } }")
    fi

    if [ -n "$created_after" ]; then
        and_conditions+=("{ createdAt: { gte: \"$created_after\" } }")
    fi

    if [ -n "$updated_after" ]; then
        and_conditions+=("{ updatedAt: { gte: \"$updated_after\" } }")
    fi

    local filter=""
    if [ ${#and_conditions[@]} -eq 1 ]; then
        filter="${and_conditions[0]#\{}"
        filter="${filter%\}}"
    elif [ ${#and_conditions[@]} -gt 1 ]; then
        local IFS=", "
        filter="and: [${and_conditions[*]}]"
    fi

    local pagination=""
    if [ -n "$after_cursor" ]; then
        pagination=", after: \"$after_cursor\""
    fi

    if [ -n "$query_text" ]; then
        local filter_clause=""
        if [ -n "$filter" ]; then
            filter_clause=", filter: { $filter }"
        fi

        local query="query {
            searchIssues(term: \"$query_text\", teamId: \"$PRODUCT_TEAM_ID\", first: $limit$pagination, orderBy: updatedAt$filter_clause) {
                nodes {
                    identifier
                    title
                    state { name }
                    assignee { name }
                    project { name }
                    labels { nodes { name } }
                    updatedAt
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            issues: .data.searchIssues.nodes | map({
                identifier,
                title,
                state: .state.name,
                assignee: .assignee.name,
                project: .project.name,
                labels: [.labels.nodes[].name]
            }),
            pagination: {
                hasNextPage: .data.searchIssues.pageInfo.hasNextPage,
                endCursor: .data.searchIssues.pageInfo.endCursor
            }
        }'
    else
        local query="query {
            issues(first: $limit$pagination, filter: { $filter }, orderBy: updatedAt) {
                nodes {
                    identifier
                    title
                    state { name }
                    assignee { name }
                    project { name }
                    labels { nodes { name } }
                    updatedAt
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            issues: .data.issues.nodes | map({
                identifier,
                title,
                state: .state.name,
                assignee: .assignee.name,
                project: .project.name,
                labels: [.labels.nodes[].name]
            }),
            pagination: {
                hasNextPage: .data.issues.pageInfo.hasNextPage,
                endCursor: .data.issues.pageInfo.endCursor
            }
        }'
    fi
}

cmd_issue_my() {
    local limit=5
    local after_cursor=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --limit)
                limit="$2"
                shift 2
                ;;
            --after)
                after_cursor="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh help' for usage information" >&2
                exit 1
                ;;
        esac
    done

    local pagination=""
    if [ -n "$after_cursor" ]; then
        pagination=", after: \"$after_cursor\""
    fi

    local query="query {
        viewer {
            assignedIssues(first: $limit$pagination, orderBy: updatedAt) {
                nodes {
                    identifier
                    title
                    state { name }
                    priority
                    project { name }
                    labels { nodes { name } }
                    updatedAt
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
    }"

    local response=$(linear_query "$query")
    printf '%s\n' "$response" | jq '{
        issues: .data.viewer.assignedIssues.nodes | map({
            identifier,
            title,
            state: .state.name,
            priority,
            project: .project.name,
            labels: [.labels.nodes[].name]
        }),
        pagination: {
            hasNextPage: .data.viewer.assignedIssues.pageInfo.hasNextPage,
            endCursor: .data.viewer.assignedIssues.pageInfo.endCursor
        }
    }'
}

cmd_comment_list() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Issue identifier required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    local query='query($id: String!) { issue(id: $id) { identifier comments { nodes { body user { name } createdAt } } } }'
    local variables=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")

    printf '%s\n' "$response" | jq '.data.issue | {
        issue: .identifier,
        comments: [.comments.nodes[] | {
            author: .user.name,
            body,
            createdAt
        }]
    }'
}

cmd_comment_create() {
    local identifier="${1:-}"
    local body="${2:-}"

    if [ -z "$identifier" ] || [ -z "$body" ]; then
        echo "Error: Issue identifier and comment text required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    local query='mutation($issueId: String!, $body: String!) { commentCreate(input: { issueId: $issueId, body: $body }) { success comment { id } } }'
    local variables=$(jq -n -c --arg id "$identifier" --arg body "$body" '{"issueId": $id, "body": $body}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.commentCreate.success')

    if [ "$success" = "true" ]; then
        echo "Comment created successfully"
    else
        echo "Error: Failed to create comment" >&2
        exit 1
    fi
}

cmd_project_get() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Project name or ID required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    if [[ "$identifier" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        local query='query($id: String!) { project(id: $id) { id name description content state startDate targetDate lead { name } url } }'
        local variables=$(jq -n -c --arg id "$identifier" '{"id": $id}')
        local response=$(linear_query "$query" "$variables")
        local project=$(printf '%s\n' "$response" | jq '.data.project // empty')
    else
        local query='query($name: String!) { projects(filter: { name: { containsIgnoreCase: $name } }) { nodes { id name description content state startDate targetDate lead { name } url } } }'
        local variables=$(jq -n -c --arg name "$identifier" '{"name": $name}')
        local response=$(linear_query "$query" "$variables")
        local project=$(printf '%s\n' "$response" | jq '.data.projects.nodes[0] // empty')
    fi

    if [ -z "$project" ] || [ "$project" = "null" ]; then
        echo "Error: Project '$identifier' not found" >&2
        exit 1
    fi

    printf '%s\n' "$project" | jq '{
        id,
        name,
        description: (if .description == "" and .content != null then .content else .description end),
        state,
        startDate,
        targetDate,
        lead: .lead.name,
        url
    }'
}

cmd_project_catalog() {
    local identifier="${1:-}"
    local limit=100
    local after_cursor=""

    if [ -z "$identifier" ]; then
        echo "Error: Project name or ID required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --limit)
                limit="$2"
                if [ "$limit" -gt 250 ]; then
                    limit=250
                fi
                shift 2
                ;;
            --after)
                after_cursor="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh help' for usage information" >&2
                exit 1
                ;;
        esac
    done

    local project_id=""
    if [[ "$identifier" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        project_id="$identifier"
    else
        local lookup_query='query($name: String!) { projects(filter: { name: { containsIgnoreCase: $name } }) { nodes { id } } }'
        local lookup_vars=$(jq -n -c --arg name "$identifier" '{"name": $name}')
        local lookup_response=$(linear_query "$lookup_query" "$lookup_vars")
        project_id=$(printf '%s\n' "$lookup_response" | jq -r '.data.projects.nodes[0].id // empty')

        if [ -z "$project_id" ] || [ "$project_id" = "null" ]; then
            echo "Error: Project '$identifier' not found" >&2
            exit 1
        fi
    fi

    local pagination=""
    if [ -n "$after_cursor" ]; then
        pagination=", after: \"$after_cursor\""
    fi

    local query="query(\$id: String!) {
        project(id: \$id) {
            id
            name
            description
            content
            state
            startDate
            targetDate
            lead { name email }
            url
            currentProgress
            issues(first: $limit$pagination) {
                nodes {
                    identifier
                    title
                    description
                    priority
                    state { name }
                    assignee { name }
                    creator { name }
                    labels { nodes { name } }
                    parent { identifier }
                    children { nodes { identifier } }
                    attachments { nodes { title url sourceType } }
                    documents { nodes { slugId title url } }
                    comments(first: 20) { nodes { body user { name } createdAt } }
                    createdAt
                    updatedAt
                    url
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }
    }"

    local variables=$(jq -n -c --arg id "$project_id" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")
    local project=$(printf '%s\n' "$response" | jq '.data.project // empty')

    if [ -z "$project" ] || [ "$project" = "null" ]; then
        echo "Error: Project '$identifier' not found" >&2
        exit 1
    fi

    printf '%s\n' "$response" | jq '.data.project | {
        project: {
            id,
            name,
            description: (if .description == "" and .content != null then .content else .description end),
            state,
            startDate,
            targetDate,
            lead: (if .lead then {name: .lead.name, email: .lead.email} else null end),
            url
        },
        totalIssueCount: (.currentProgress.scopeCount // (.issues.nodes | length)),
        issuesReturned: (.issues.nodes | length),
        issues: [.issues.nodes[] | {
            identifier,
            title,
            description,
            priority,
            state: .state.name,
            assignee: .assignee.name,
            creator: .creator.name,
            labels: [.labels.nodes[].name],
            parent: .parent.identifier,
            children: [.children.nodes[].identifier],
            attachments: [.attachments.nodes[] | {title, url, sourceType}],
            documents: [.documents.nodes[] | {slugId, title, url}],
            comments: [.comments.nodes[] | {author: .user.name, body, createdAt}],
            createdAt,
            updatedAt,
            url
        }],
        pagination: {
            hasNextPage: .issues.pageInfo.hasNextPage,
            endCursor: .issues.pageInfo.endCursor
        }
    }'
}

cmd_project_list() {
    local limit=5
    local after_cursor=""
    local query_text=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --query)
                query_text="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            --after)
                after_cursor="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh help' for usage information" >&2
                exit 1
                ;;
        esac
    done

    local pagination=""
    if [ -n "$after_cursor" ]; then
        pagination=", after: \"$after_cursor\""
    fi

    if [ -n "$query_text" ]; then
        local query="query {
            searchProjects(term: \"$query_text\", first: $limit$pagination) {
                nodes {
                    id
                    name
                    state
                    startDate
                    targetDate
                    lead { name }
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            projects: .data.searchProjects.nodes | map({
                id,
                name,
                state,
                startDate,
                targetDate,
                lead: .lead.name
            }),
            pagination: {
                hasNextPage: .data.searchProjects.pageInfo.hasNextPage,
                endCursor: .data.searchProjects.pageInfo.endCursor
            }
        }'
    else
        local query="query {
            projects(first: $limit$pagination, orderBy: updatedAt) {
                nodes {
                    id
                    name
                    state
                    startDate
                    targetDate
                    lead { name }
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            projects: .data.projects.nodes | map({
                id,
                name,
                state,
                startDate,
                targetDate,
                lead: .lead.name
            }),
            pagination: {
                hasNextPage: .data.projects.pageInfo.hasNextPage,
                endCursor: .data.projects.pageInfo.endCursor
            }
        }'
    fi
}

cmd_document_get() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Document ID or slug required" >&2
        echo "Run 'linear.sh help' for usage information" >&2
        exit 1
    fi

    local query='query($id: String!) { document(id: $id) { content } }'
    local variables=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")
    local content=$(printf '%s\n' "$response" | jq -r '.data.document.content // empty')

    if [ -z "$content" ]; then
        echo "Error: Document '$identifier' not found" >&2
        exit 1
    fi

    printf '%s\n' "$content"
}

cmd_issue_create() {
    local title=""
    local description=""
    local parent_id=""
    local project_id=""
    local state_id=""
    local priority=""
    local assignee_id=""
    local label_ids=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --title)
                title="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --parent)
                local parent_identifier="$2"
                if [[ "$parent_identifier" =~ ^PRO-[0-9]+$ ]]; then
                    local parent_query='query($id: String!) { issue(id: $id) { id } }'
                    local parent_vars=$(jq -n -c --arg id "$parent_identifier" '{"id": $id}')
                    local parent_response=$(linear_query "$parent_query" "$parent_vars")
                    parent_id=$(printf '%s\n' "$parent_response" | jq -r '.data.issue.id // empty')
                    if [ -z "$parent_id" ]; then
                        echo "Error: Parent issue $parent_identifier not found" >&2
                        exit 1
                    fi
                else
                    parent_id="$parent_identifier"
                fi
                shift 2
                ;;
            --project)
                project_id="$2"
                shift 2
                ;;
            --state)
                state_id="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --assignee)
                assignee_id="$2"
                shift 2
                ;;
            --label)
                label_ids+=("$2")
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "$title" ]; then
        echo "Error: --title is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local input_json=$(jq -n -c \
        --arg title "$title" \
        --arg description "$description" \
        --arg teamId "$PRODUCT_TEAM_ID" \
        --arg parentId "$parent_id" \
        --arg projectId "$project_id" \
        --arg stateId "$state_id" \
        --arg priority "$priority" \
        --arg assigneeId "$assignee_id" \
        --argjson labelIds "$(printf '%s\n' "${label_ids[@]:-}" | jq -R . | jq -s 'map(select(. != ""))')" \
        '{
            title: $title,
            teamId: $teamId
        } + (if $description != "" then {description: $description} else {} end)
          + (if $parentId != "" then {parentId: $parentId} else {} end)
          + (if $projectId != "" then {projectId: $projectId} else {} end)
          + (if $stateId != "" then {stateId: $stateId} else {} end)
          + (if $priority != "" then {priority: ($priority | tonumber)} else {} end)
          + (if $assigneeId != "" then {assigneeId: $assigneeId} else {} end)
          + (if ($labelIds | length) > 0 then {labelIds: $labelIds} else {} end)')

    local query='mutation($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id identifier title url } } }'
    local variables=$(jq -n -c --argjson input "$input_json" '{input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.issueCreate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.issueCreate.issue | {
            identifier,
            title,
            url,
            message: "Issue created successfully"
        }'
    else
        echo "Error: Failed to create issue" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_issue_update() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Issue identifier required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    shift

    local title=""
    local description=""
    local parent_id=""
    local project_id=""
    local state_id=""
    local priority=""
    local assignee_id=""
    local label_ids=()
    local has_label_update=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --title)
                title="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --parent)
                local parent_identifier="$2"
                if [[ "$parent_identifier" =~ ^PRO-[0-9]+$ ]]; then
                    local parent_query='query($id: String!) { issue(id: $id) { id } }'
                    local parent_vars=$(jq -n -c --arg id "$parent_identifier" '{"id": $id}')
                    local parent_response=$(linear_query "$parent_query" "$parent_vars")
                    parent_id=$(printf '%s\n' "$parent_response" | jq -r '.data.issue.id // empty')
                    if [ -z "$parent_id" ]; then
                        echo "Error: Parent issue $parent_identifier not found" >&2
                        exit 1
                    fi
                else
                    parent_id="$parent_identifier"
                fi
                shift 2
                ;;
            --project)
                project_id="$2"
                shift 2
                ;;
            --state)
                state_id="$2"
                shift 2
                ;;
            --priority)
                priority="$2"
                shift 2
                ;;
            --assignee)
                assignee_id="$2"
                shift 2
                ;;
            --label)
                label_ids+=("$2")
                has_label_update=true
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    local input_json=$(jq -n -c \
        --arg title "$title" \
        --arg description "$description" \
        --arg parentId "$parent_id" \
        --arg projectId "$project_id" \
        --arg stateId "$state_id" \
        --arg priority "$priority" \
        --arg assigneeId "$assignee_id" \
        --argjson labelIds "$(printf '%s\n' "${label_ids[@]:-}" | jq -R . | jq -s 'map(select(. != ""))')" \
        --argjson hasLabelUpdate "$has_label_update" \
        '{}
          + (if $title != "" then {title: $title} else {} end)
          + (if $description != "" then {description: $description} else {} end)
          + (if $parentId != "" then {parentId: $parentId} else {} end)
          + (if $projectId != "" then {projectId: $projectId} else {} end)
          + (if $stateId != "" then {stateId: $stateId} else {} end)
          + (if $priority != "" then {priority: ($priority | tonumber)} else {} end)
          + (if $assigneeId != "" then {assigneeId: $assigneeId} else {} end)
          + (if $hasLabelUpdate then {labelIds: $labelIds} else {} end)')

    local query='mutation($id: String!, $input: IssueUpdateInput!) { issueUpdate(id: $id, input: $input) { success issue { id identifier title url } } }'
    local variables=$(jq -n -c --arg id "$identifier" --argjson input "$input_json" '{id: $id, input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.issueUpdate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.issueUpdate.issue | {
            identifier,
            title,
            url,
            message: "Issue updated successfully"
        }'
    else
        echo "Error: Failed to update issue" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_issue_delete() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Issue identifier required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    if [ "${2:-}" != "--force" ]; then
        echo "WARNING: This will permanently delete issue $identifier" >&2
        echo "This action cannot be undone. Type 'DELETE' to confirm:" >&2
        read -r confirmation
        if [ "$confirmation" != "DELETE" ]; then
            echo "Deletion cancelled" >&2
            exit 1
        fi
    fi

    local query='mutation($id: String!) { issueDelete(id: $id) { success } }'
    local variables=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.issueDelete.success')

    if [ "$success" = "true" ]; then
        echo "Issue $identifier deleted successfully"
    else
        echo "Error: Failed to delete issue" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_label_list() {
    local limit=50
    local query="query { team(id: \"$PRODUCT_TEAM_ID\") { labels(first: $limit) { nodes { id name description color } } } }"
    local response=$(linear_query "$query")
    printf '%s\n' "$response" | jq '.data.team.labels.nodes | map({id, name, description, color})'
}

cmd_project_create() {
    local name=""
    local description=""
    local lead_id=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                name="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --lead)
                lead_id="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "$name" ]; then
        echo "Error: --name is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local input_json=$(jq -n -c \
        --arg name "$name" \
        --arg description "$description" \
        --arg leadId "$lead_id" \
        --arg teamId "$PRODUCT_TEAM_ID" \
        '{
            name: $name,
            teamIds: [$teamId]
        } + (if $description != "" then {description: $description} else {} end)
          + (if $leadId != "" then {leadId: $leadId} else {} end)')

    local query='mutation($input: ProjectCreateInput!) { projectCreate(input: $input) { success project { id name url } } }'
    local variables=$(jq -n -c --argjson input "$input_json" '{input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.projectCreate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.projectCreate.project | {
            id,
            name,
            url,
            message: "Project created successfully"
        }'
    else
        echo "Error: Failed to create project" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_project_update() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Project UUID required (use 'project get' or 'project list' to find it)" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    shift

    local name=""
    local description=""
    local lead_id=""
    local state=""
    local start_date=""
    local target_date=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                name="$2"
                shift 2
                ;;
            --description)
                description="$2"
                shift 2
                ;;
            --lead)
                lead_id="$2"
                shift 2
                ;;
            --state)
                state="$2"
                shift 2
                ;;
            --start-date)
                start_date="$2"
                shift 2
                ;;
            --target-date)
                target_date="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    local input_json=$(jq -n -c \
        --arg name "$name" \
        --arg description "$description" \
        --arg leadId "$lead_id" \
        --arg state "$state" \
        --arg startDate "$start_date" \
        --arg targetDate "$target_date" \
        '{}
          + (if $name != "" then {name: $name} else {} end)
          + (if $description != "" then {description: $description} else {} end)
          + (if $leadId != "" then {leadId: $leadId} else {} end)
          + (if $state != "" then {state: $state} else {} end)
          + (if $startDate != "" then {startDate: $startDate} else {} end)
          + (if $targetDate != "" then {targetDate: $targetDate} else {} end)')

    local query='mutation($id: String!, $input: ProjectUpdateInput!) { projectUpdate(id: $id, input: $input) { success project { id name url } } }'
    local variables=$(jq -n -c --arg id "$identifier" --argjson input "$input_json" '{id: $id, input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.projectUpdate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.projectUpdate.project | {
            id,
            name,
            url,
            message: "Project updated successfully"
        }'
    else
        echo "Error: Failed to update project" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_project_delete() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Project UUID required (use 'project get' or 'project list' to find it)" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    if [ "${2:-}" != "--force" ]; then
        echo "WARNING: This will permanently delete project $identifier" >&2
        echo "This action cannot be undone. Type 'DELETE' to confirm:" >&2
        read -r confirmation
        if [ "$confirmation" != "DELETE" ]; then
            echo "Deletion cancelled" >&2
            exit 1
        fi
    fi

    local query='mutation($id: String!) { projectDelete(id: $id) { success } }'
    local variables=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.projectDelete.success')

    if [ "$success" = "true" ]; then
        echo "Project $identifier deleted successfully"
    else
        echo "Error: Failed to delete project" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_state_list() {
    local query="query { team(id: \"$PRODUCT_TEAM_ID\") { states { nodes { id name type position } } } }"
    local response=$(linear_query "$query")
    printf '%s\n' "$response" | jq '.data.team.states.nodes | group_by(.type) | map({
        type: .[0].type,
        states: map({id, name, position}) | sort_by(.position)
    })'
}

cmd_user_me() {
    local query='query { viewer { id name email } }'
    local response=$(linear_query "$query")
    printf '%s\n' "$response" | jq '.data.viewer'
}

cmd_user_list() {
    local query="query { team(id: \"$PRODUCT_TEAM_ID\") { members { nodes { id name email active } } } }"
    local response=$(linear_query "$query")
    printf '%s\n' "$response" | jq '.data.team.members.nodes | map(select(.active == true)) | map({id, name, email})'
}

cmd_mutation_help() {
    echo "WARNING: These commands directly modify Linear."
    echo ""
    echo "ISSUE MUTATIONS:"
    echo "  linear.sh issue create --title TEXT [OPTIONS]"
    echo "    Create new issue (Product team only)"
    echo "    --description TEXT                  Issue description (markdown supported)"
    echo "    --parent PRO-XXXXX                  Parent issue ID for hierarchies"
    echo "    --project PROJECT-ID                Project ID to associate with"
    echo "    --state STATE-ID                    Workflow state ID (use 'state list' to find)"
    echo "    --priority N                        Priority: 0=None, 1=Urgent, 2=High, 3=Normal, 4=Low"
    echo "    --assignee USER-ID                  Assignee user ID"
    echo "    --label LABEL-ID                    Label ID (use 'label list' to find) - can use multiple times"
    echo ""
    echo "  linear.sh issue update PRO-XXXXX [OPTIONS]"
    echo "    Update existing issue (same options as create, all optional)"
    echo ""
    echo "  linear.sh issue delete PRO-XXXXX [--force]"
    echo "    PERMANENTLY delete issue (cannot undo!)"
    echo "    --force                             Skip confirmation prompt"
    echo ""
    echo "PROJECT MUTATIONS:"
    echo "  linear.sh project create --name TEXT [OPTIONS]"
    echo "    Create new project"
    echo "    --description TEXT                  Project description"
    echo "    --lead USER-ID                      Project lead user ID"
    echo ""
    echo "  linear.sh project update PROJECT-ID [OPTIONS]"
    echo "    Update existing project"
    echo "    --name TEXT                         New project name"
    echo "    --description TEXT                  New description"
    echo "    --lead USER-ID                      New project lead"
    echo "    --state STATE                       Project state (planned, started, etc.)"
    echo "    --start-date YYYY-MM-DD             Project start date"
    echo "    --target-date YYYY-MM-DD            Project target date"
    echo ""
    echo "  linear.sh project delete PROJECT-ID [--force]"
    echo "    PERMANENTLY delete project (cannot undo!)"
    echo "    --force                             Skip confirmation prompt"
    echo ""
    echo "DOCUMENT MUTATIONS:"
    echo "  linear.sh document create --title TEXT --file PATH PARENT"
    echo "    Create a document from a markdown file, linked to a parent entity"
    echo "    --title TEXT                         Document title (required)"
    echo "    --file PATH                          Path to markdown file (required)"
    echo "    Exactly one parent link required:"
    echo "    --project PROJECT-UUID               Link to a project"
    echo "    --issue PRO-XXXXX                    Link to an issue"
    echo "    --team TEAM-UUID                     Link to a team"
    echo ""
    echo "    Example: linear.sh document create --title \"...\" --file path/to/report.md --project PROJECT-UUID"
    echo ""
    echo "  linear.sh document update SLUG-ID [OPTIONS]"
    echo "    Update document title or content (at least one option required)"
    echo "    --title TEXT                         New document title"
    echo "    --file PATH                          New content from markdown file"
    echo ""
    echo "  linear.sh document delete SLUG-ID [--force]"
    echo "    PERMANENTLY delete document (cannot undo!)"
    echo "    --force                              Skip confirmation prompt"
    echo ""
    echo "HELPER COMMANDS:"
    echo "  linear.sh label list                  List available labels with IDs"
    echo "  linear.sh state list                  List workflow states with IDs (grouped by type)"
    echo "  linear.sh user list                   List active team members with IDs"
    echo "  linear.sh user me                     Get current authenticated user details"
    echo ""
    echo "NOTES:"
    echo "  - Issue create is restricted to Product team (PRO- tickets)"
    echo "  - IDs not names: Use label/state IDs from helper commands, not names"
    echo "  - Parent-child pattern: Create parent with details + 'Hidden' state, then children"
    echo "  - These commands are primarily for automated ticket creation workflows"
    echo "  - Manual use requires understanding Linear's data model"
    echo ""
    echo "PRIORITY VALUES:"
    echo "  0 = No priority"
    echo "  1 = Urgent"
    echo "  2 = High"
    echo "  3 = Normal"
    echo "  4 = Low"
}

cmd_document_list() {
    local limit=5
    local after_cursor=""
    local query_text=""
    local project_filter=""
    local created_after=""
    local updated_after=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --query)
                query_text="$2"
                shift 2
                ;;
            --project)
                project_filter="$2"
                shift 2
                ;;
            --created-after)
                created_after="$2"
                shift 2
                ;;
            --updated-after)
                updated_after="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            --after)
                after_cursor="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh help' for usage information" >&2
                exit 1
                ;;
        esac
    done

    local filter_parts=()

    if [ -n "$created_after" ]; then
        filter_parts+=("createdAt: { gte: \"$created_after\" }")
    fi

    if [ -n "$updated_after" ]; then
        filter_parts+=("updatedAt: { gte: \"$updated_after\" }")
    fi

    if [ -n "$project_filter" ]; then
        filter_parts+=("project: { name: { containsIgnoreCase: \"$project_filter\" } }")
    fi

    local filter=""
    if [ ${#filter_parts[@]} -gt 0 ]; then
        local IFS=", "
        filter=", filter: { ${filter_parts[*]} }"
    fi

    local pagination=""
    if [ -n "$after_cursor" ]; then
        pagination=", after: \"$after_cursor\""
    fi

    if [ -n "$query_text" ]; then
        local query="query {
            searchDocuments(term: \"$query_text\", first: $limit$pagination$filter) {
                nodes {
                    id
                    slugId
                    title
                    url
                    createdAt
                    updatedAt
                    creator { name }
                    project { name }
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            documents: .data.searchDocuments.nodes | map({
                slugId,
                title,
                project: .project.name,
                creator: .creator.name,
                updatedAt,
                url
            }),
            pagination: {
                hasNextPage: .data.searchDocuments.pageInfo.hasNextPage,
                endCursor: .data.searchDocuments.pageInfo.endCursor
            }
        }'
    else
        local query="query {
            documents(first: $limit$pagination, orderBy: updatedAt$filter) {
                nodes {
                    id
                    slugId
                    title
                    url
                    createdAt
                    updatedAt
                    creator { name }
                    project { name }
                }
                pageInfo {
                    hasNextPage
                    endCursor
                }
            }
        }"

        local response=$(linear_query "$query")
        printf '%s\n' "$response" | jq '{
            documents: .data.documents.nodes | map({
                slugId,
                title,
                project: .project.name,
                creator: .creator.name,
                updatedAt,
                url
            }),
            pagination: {
                hasNextPage: .data.documents.pageInfo.hasNextPage,
                endCursor: .data.documents.pageInfo.endCursor
            }
        }'
    fi
}

cmd_document_create() {
    local title=""
    local file_path=""
    local project_id=""
    local issue_id=""
    local team_id=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --title)
                title="$2"
                shift 2
                ;;
            --file)
                file_path="$2"
                shift 2
                ;;
            --project)
                project_id="$2"
                shift 2
                ;;
            --issue)
                local issue_identifier="$2"
                if [[ "$issue_identifier" =~ ^PRO-[0-9]+$ ]]; then
                    local issue_query='query($id: String!) { issue(id: $id) { id } }'
                    local issue_vars=$(jq -n -c --arg id "$issue_identifier" '{"id": $id}')
                    local issue_response=$(linear_query "$issue_query" "$issue_vars")
                    issue_id=$(printf '%s\n' "$issue_response" | jq -r '.data.issue.id // empty')
                    if [ -z "$issue_id" ]; then
                        echo "Error: Issue $issue_identifier not found" >&2
                        exit 1
                    fi
                else
                    issue_id="$issue_identifier"
                fi
                shift 2
                ;;
            --team)
                team_id="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    if [ -z "$title" ]; then
        echo "Error: --title is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    if [ -z "$file_path" ]; then
        echo "Error: --file is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    if [ ! -f "$file_path" ]; then
        echo "Error: File not found: $file_path" >&2
        exit 1
    fi

    if [ ! -r "$file_path" ]; then
        echo "Error: File not readable: $file_path" >&2
        exit 1
    fi

    local content
    content=$(cat "$file_path") || { echo "Error: Failed to read file: $file_path" >&2; exit 1; }

    local parent_count=0
    [ -n "$project_id" ] && parent_count=$((parent_count + 1))
    [ -n "$issue_id" ] && parent_count=$((parent_count + 1))
    [ -n "$team_id" ] && parent_count=$((parent_count + 1))

    if [ "$parent_count" -eq 0 ]; then
        echo "Error: Exactly one of --project, --issue, or --team is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    if [ "$parent_count" -gt 1 ]; then
        echo "Error: Only one of --project, --issue, or --team can be specified" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local input_json=$(jq -n -c \
        --arg title "$title" \
        --arg content "$content" \
        --arg projectId "$project_id" \
        --arg issueId "$issue_id" \
        --arg teamId "$team_id" \
        '{
            title: $title,
            content: $content
        } + (if $projectId != "" then {projectId: $projectId} else {} end)
          + (if $issueId != "" then {issueId: $issueId} else {} end)
          + (if $teamId != "" then {teamId: $teamId} else {} end)')

    local query='mutation($input: DocumentCreateInput!) { documentCreate(input: $input) { success document { id slugId title url } } }'
    local variables=$(jq -n -c --argjson input "$input_json" '{input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.documentCreate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.documentCreate.document | {
            slugId,
            title,
            url,
            message: "Document created successfully"
        }'
    else
        echo "Error: Failed to create document" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_document_update() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Document slug ID required (use 'document get' or 'document list' to find it)" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local resolve_query='query($id: String!) { document(id: $id) { id } }'
    local resolve_vars=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local resolve_response=$(linear_query "$resolve_query" "$resolve_vars")
    local document_uuid=$(printf '%s\n' "$resolve_response" | jq -r '.data.document.id // empty')

    if [ -z "$document_uuid" ] || [ "$document_uuid" = "null" ]; then
        echo "Error: Document '$identifier' not found" >&2
        exit 1
    fi

    shift

    local title=""
    local file_path=""
    local has_updates=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --title)
                title="$2"
                has_updates=true
                shift 2
                ;;
            --file)
                file_path="$2"
                has_updates=true
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'" >&2
                echo "Run 'linear.sh mutation help' for usage" >&2
                exit 1
                ;;
        esac
    done

    if [ "$has_updates" = false ]; then
        echo "Error: At least one of --title or --file is required" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local content=""
    if [ -n "$file_path" ]; then
        if [ ! -f "$file_path" ]; then
            echo "Error: File not found: $file_path" >&2
            exit 1
        fi

        if [ ! -r "$file_path" ]; then
            echo "Error: File not readable: $file_path" >&2
            exit 1
        fi

        content=$(cat "$file_path") || { echo "Error: Failed to read file: $file_path" >&2; exit 1; }
    fi

    local input_json=$(jq -n -c \
        --arg title "$title" \
        --arg content "$content" \
        '{}
          + (if $title != "" then {title: $title} else {} end)
          + (if $content != "" then {content: $content} else {} end)')

    local query='mutation($id: String!, $input: DocumentUpdateInput!) { documentUpdate(id: $id, input: $input) { success document { id slugId title url } } }'
    local variables=$(jq -n -c --arg id "$document_uuid" --argjson input "$input_json" '{id: $id, input: $input}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.documentUpdate.success')

    if [ "$success" = "true" ]; then
        printf '%s\n' "$response" | jq '.data.documentUpdate.document | {
            slugId,
            title,
            url,
            message: "Document updated successfully"
        }'
    else
        echo "Error: Failed to update document" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

cmd_document_delete() {
    local identifier="${1:-}"

    if [ -z "$identifier" ]; then
        echo "Error: Document slug ID required (use 'document get' or 'document list' to find it)" >&2
        echo "Run 'linear.sh mutation help' for usage" >&2
        exit 1
    fi

    local resolve_query='query($id: String!) { document(id: $id) { id } }'
    local resolve_vars=$(jq -n -c --arg id "$identifier" '{"id": $id}')
    local resolve_response=$(linear_query "$resolve_query" "$resolve_vars")
    local document_uuid=$(printf '%s\n' "$resolve_response" | jq -r '.data.document.id // empty')

    if [ -z "$document_uuid" ] || [ "$document_uuid" = "null" ]; then
        echo "Error: Document '$identifier' not found" >&2
        exit 1
    fi

    if [ "${2:-}" != "--force" ]; then
        echo "WARNING: This will permanently delete document $identifier" >&2
        echo "This action cannot be undone. Type 'DELETE' to confirm:" >&2
        read -r confirmation
        if [ "$confirmation" != "DELETE" ]; then
            echo "Deletion cancelled" >&2
            exit 1
        fi
    fi

    local query='mutation($id: String!) { documentDelete(id: $id) { success } }'
    local variables=$(jq -n -c --arg id "$document_uuid" '{"id": $id}')
    local response=$(linear_query "$query" "$variables")
    local success=$(printf '%s\n' "$response" | jq -r '.data.documentDelete.success')

    if [ "$success" = "true" ]; then
        echo "Document $identifier deleted successfully"
    else
        echo "Error: Failed to delete document" >&2
        if [ "$DEBUG" = "1" ]; then
            printf '%s\n' "$response" | jq '.' >&2
        fi
        exit 1
    fi
}

main() {
    local command="${1:-}"
    local subcommand="${2:-}"

    case "$command" in
        issue)
            case "$subcommand" in
                get) shift 2; cmd_issue_get "$@" ;;
                list) shift 2; cmd_issue_list "$@" ;;
                my) shift 2; cmd_issue_my "$@" ;;
                create) shift 2; cmd_issue_create "$@" ;;
                update) shift 2; cmd_issue_update "$@" ;;
                delete) shift 2; cmd_issue_delete "$@" ;;
                *) echo "Error: Unknown issue subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        comment)
            case "$subcommand" in
                list) shift 2; cmd_comment_list "$@" ;;
                create) shift 2; cmd_comment_create "$@" ;;
                *) echo "Error: Unknown comment subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        project)
            case "$subcommand" in
                get) shift 2; cmd_project_get "$@" ;;
                catalog) shift 2; cmd_project_catalog "$@" ;;
                list) shift 2; cmd_project_list "$@" ;;
                create) shift 2; cmd_project_create "$@" ;;
                update) shift 2; cmd_project_update "$@" ;;
                delete) shift 2; cmd_project_delete "$@" ;;
                *) echo "Error: Unknown project subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        document)
            case "$subcommand" in
                get) shift 2; cmd_document_get "$@" ;;
                list) shift 2; cmd_document_list "$@" ;;
                create) shift 2; cmd_document_create "$@" ;;
                update) shift 2; cmd_document_update "$@" ;;
                delete) shift 2; cmd_document_delete "$@" ;;
                *) echo "Error: Unknown document subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        label)
            case "$subcommand" in
                list) shift 2; cmd_label_list "$@" ;;
                *) echo "Error: Unknown label subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        state)
            case "$subcommand" in
                list) shift 2; cmd_state_list "$@" ;;
                *) echo "Error: Unknown state subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        user)
            case "$subcommand" in
                list) shift 2; cmd_user_list "$@" ;;
                me) shift 2; cmd_user_me "$@" ;;
                *) echo "Error: Unknown user subcommand '$subcommand'" >&2; echo "Run 'linear.sh help' for usage information" >&2; exit 1 ;;
            esac
            ;;
        mutation)
            case "$subcommand" in
                help) shift 2; cmd_mutation_help "$@" ;;
                *) echo "Error: Unknown mutation subcommand '$subcommand'" >&2; echo "Run 'linear.sh mutation help' for usage" >&2; exit 1 ;;
            esac
            ;;
        help|--help|-h)
            echo "Usage: linear.sh <command> <subcommand> [options]"
            echo ""
            echo "ISSUES:"
            echo "  issue get PRO-12345                   Get full issue details"
            echo "  issue list [OPTIONS]                  List/search issues (filtered to Product team)"
            echo "    --query TEXT                        Search in title and description"
            echo "    --state STATE                       Filter by state (see STATES section below)"
            echo "    --assignee USER                     Filter by assignee name or email"
            echo "    --label LABEL                       Filter by label (e.g., 'iOS', 'Android', 'Bug', 'Route Planner', 'Dispatch')"
            echo "    --project PROJECT                   Filter by project name"
            echo "    --created-after DATE                Issues created after ISO date (e.g., '2025-08-01')"
            echo "    --updated-after DATE                Issues updated after ISO date (e.g., '2025-08-01')"
            echo "    --limit N                           Number of results (default: 5, max: 250)"
            echo "    --after CURSOR                      Pagination cursor from previous results"
            echo "  issue my [OPTIONS]                    List issues assigned to API key owner"
            echo "    --limit N                           Number of results (default: 5)"
            echo "    --after CURSOR                      Pagination cursor"
            echo ""
            echo "COMMENTS:"
            echo "  comment list PRO-12345                List all comments on an issue"
            echo "  comment create PRO-12345 \"text\"     Add comment to issue"
            echo ""
            echo "PROJECTS:"
            echo "  project get \"NAME\"                  Get project by name (partial match supported)"
            echo "  project get PROJECT-ID                Get project by UUID"
            echo "  project catalog \"NAME\" [OPTIONS]    Fetch project with all issues in one call"
            echo "  project catalog PROJECT-UUID          Fetch project by UUID with all issues"
            echo "    --limit N                           Issues per page (default: 100, max: 250)"
            echo "    --after CURSOR                      Pagination cursor for large projects"
            echo "  project list [OPTIONS]                List all projects (cross-team)"
            echo "    --query TEXT                        Search in project names (intelligent matching)"
            echo "    --limit N                           Number of results (default: 5)"
            echo "    --after CURSOR                      Pagination cursor"
            echo ""
            echo "DOCUMENTS:"
            echo "  document get SLUG-ID                  Get document content (raw markdown)"
            echo "  document list [OPTIONS]               List Linear documents"
            echo "    --query TEXT                        Search in document titles and content"
            echo "    --project PROJECT                   Filter by project name"
            echo "    --created-after DATE                Documents created after ISO date"
            echo "    --updated-after DATE                Documents updated after ISO date"
            echo "    --limit N                           Number of results (default: 5)"
            echo "    --after CURSOR                      Pagination cursor"
            echo "  document create --title TEXT --file PATH --project|--issue|--team ID"
            echo "    Create a document from a markdown file (see 'mutation help' for details)"
            echo "  document update SLUG-ID [OPTIONS]     Update document title or content"
            echo "  document delete SLUG-ID [--force]     Delete a document"
            echo ""
            echo "COMMON PATTERNS:"
            echo "  # Fetch complete project data"
            echo "  project catalog \"Project Name\" > /tmp/catalog.json"
            echo "  "
            echo "  # Find iOS issues in a specific project"
            echo "  issue list --project \"Project Name\" --label \"iOS\""
            echo "  "
            echo "  # Find issues with multiple labels (AND logic)"
            echo "  issue list --label \"iOS\" --label \"Route Planner\" --state \"Ready for implementation\""
            echo "  "
            echo "  # Get recent activity"
            echo "  issue list --updated-after \"YYYY-MM-DD\" --limit 20"
            echo "  "
            echo "  # Search for specific topics"
            echo "  issue list --query \"search terms\" --state \"Implementing\""
            echo "  "
            echo "  # Navigate issue hierarchy"
            echo "  issue get PRO-XXXXX                   # Get issue details"
            echo "  issue get PRO-YYYYY                   # Get parent issue (from parent field)"
            echo "  project get \"Project Name\"          # Get project (from project field)"
            echo "  "
            echo "  # Find project documentation"
            echo "  document list --project \"Project Name\""
            echo "  document get SLUG-ID"
            echo ""
            echo "COMMON ISSUE STATES:"
            echo "  Planning required                     Issue needs design/planning"
            echo "  Ready for implementation              Ready for developer to start"
            echo "  Implementing                          Currently being worked on"
            echo "  Ready for CR                          Code complete, needs review"
            echo "  Ready to ship                         Approved, waiting for release"
            echo "  Hidden                                Internal/organizational tickets"
            echo "  Canceled                              Won't be completed"
            echo "  Shipped                               Released to production"
            echo "  Backlog                               Not yet prioritized"
            echo ""
            echo "NOTES:"
            echo "  - Issue list and create filter to Product team (PRO- tickets only)"
            echo "  - Search uses intelligent matching (words can appear anywhere in content)"
            echo "  - Use quotes for multi-word arguments: --project \"My Project Name\""
            echo "  - Pagination: Use 'endCursor' from response as --after value for next page"
            echo ""
            echo "MUTATIONS:"
            echo "  mutation help                         Show commands for creating/editing/deleting (use with caution)"
            ;;
        *)
            echo "Error: Unknown command '$command'" >&2
            echo "Run 'linear.sh help' for usage information" >&2
            exit 1
            ;;
    esac
}

main "$@"
