#!/bin/bash

set -euo pipefail

usage() {
    cat <<EOF
Usage: gh-unapproved-prs <owner/repo>

Show open PRs where you are a requested reviewer or have commented,
but have not yet approved.

Arguments:
  owner/repo  GitHub repository (e.g. myorg/myrepo)

Options:
  --help  Show this help message
EOF
}

if [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 1 ]]; then
    echo "Error: owner/repo is required" >&2
    usage >&2
    exit 1
fi

REPO="$1"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

if [[ -z "$OWNER" || -z "$REPO_NAME" || "$OWNER/$REPO_NAME" != "$REPO" ]]; then
    echo "Error: invalid format '$REPO'. Expected owner/repo" >&2
    exit 1
fi

ME="$(gh api user --jq '.login')"

QUERY="$(
    cat <<'GRAPHQL'
query($owner: String!, $repo: String!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequests(first: 100, states: OPEN, after: $cursor) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number
        title
        url
        author { login }
        reviewRequests(first: 100) {
          nodes {
            requestedReviewer {
              ... on User { login }
              ... on Team { name }
            }
          }
        }
        reviews(first: 100) {
          nodes {
            author { login }
            state
          }
        }
      }
    }
  }
}
GRAPHQL
)"

CURSOR=""
RESULTS=()

while true; do
    PAGE="$(gh api graphql \
        -f query="$QUERY" \
        -f owner="$OWNER" \
        -f repo="$REPO_NAME" \
        -f cursor="$CURSOR")"

    HAS_NEXT="$(echo "$PAGE" | jq -r '.data.repository.pullRequests.pageInfo.hasNextPage')"
    CURSOR="$(echo "$PAGE" | jq -r '.data.repository.pullRequests.pageInfo.endCursor')"

    # Extract PRs where I am requested or have reviewed, but have not approved
    MATCHED="$(echo "$PAGE" | jq -r \
        --arg me "$ME" \
        '.data.repository.pullRequests.nodes[] |
        select(.author.login != $me) |
        select(
            ([ .reviewRequests.nodes[] | .requestedReviewer | select((.login? // "") == $me) ] | length > 0)
            or
            ([ .reviews.nodes[] | select(.author.login == $me) ] | length > 0)
        ) |
        select(
            ([ .reviews.nodes[] | select(.author.login == $me and .state == "APPROVED") ] | length) == 0
        ) |
        "#\(.number) \(.title)\n  \(.url)"'
    )"

    if [[ -n "$MATCHED" ]]; then
        RESULTS+=("$MATCHED")
    fi

    if [[ "$HAS_NEXT" != "true" ]]; then
        break
    fi
done

if [[ ${#RESULTS[@]} -eq 0 ]]; then
    echo "No unapproved PRs found for $ME in $REPO"
    exit 0
fi

for RESULT in "${RESULTS[@]}"; do
    echo -e "$RESULT"
done
