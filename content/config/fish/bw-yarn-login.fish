# bw-yarn-login
#
# Fish function that uses Bitwarden CLI (`bw`) to fetch your npm credentials and then
# drives Yarn's interactive `yarn npm login` prompts via `expect`, so you don't have to
# copy/paste username/password/OTP.
#
# Requirements: `bw`, `expect`, `jq`, `yarn`
# Default Bitwarden item id: ba95b595-9cb2-4a64-98c6-acd401878ded (override with `--item`)
# Username/password source: item.login.username / item.login.password (or custom fields
# named `npm_username` / `npm_password`).

function bw-yarn-login --description "Bitwarden-driven `yarn npm login` (supports --publish)"
    set -l bw_yarn_login_version '2026-01-07.3'
    set -l default_item_id 'ba95b595-9cb2-4a64-98c6-acd401878ded'

    # Avoid stale values from previous runs/sessions.
    set -e BW_YARN_NPM_OTP 2>/dev/null
    set -e -U BW_YARN_NPM_OTP 2>/dev/null

    argparse -n bw-yarn-login \
        'item=' 'scope=' \
        publish always-auth totp no-totp debug help -- $argv
    or return 2

    if set -q _flag_help
        echo "Usage:"
        echo "  bw-yarn-login [--item <id-or-search>] [--publish] [--scope <scope>] [--always-auth] [--debug]"
        echo ""
        echo "Notes:"
        echo "- Defaults to item id: $default_item_id"
        echo "- Reads username/password from Bitwarden item login.username/login.password"
        echo "- If you store custom fields instead, use field names npm_username/npm_password"
        echo "- OTP is required by npm; by default this command tries to fetch TOTP via Bitwarden and auto-types it"
        echo "  - Use --no-totp to force manual OTP entry"
        echo "- --debug enables verbose expect tracing"
        return 0
    end

    if set -q _flag_debug
        echo "bw-yarn-login version: $bw_yarn_login_version" >&2
    end

    command -v bw >/dev/null; or begin
        echo "Missing bw (Bitwarden CLI) in PATH." >&2
        return 1
    end
    command -v expect >/dev/null; or begin
        echo "Missing expect (used to answer yarn prompts)." >&2
        return 1
    end
    command -v jq >/dev/null; or begin
        echo "Missing jq (used to parse Bitwarden JSON)." >&2
        return 1
    end
    command -v yarn >/dev/null; or begin
        echo "Missing yarn in PATH." >&2
        return 1
    end

    set -l item_query (set -q _flag_item; and echo $_flag_item; or echo $default_item_id)
    set -l scope (set -q _flag_scope; and echo $_flag_scope; or echo '')

    # Ensure BW session
    if not set -q BW_SESSION; or test -z "$BW_SESSION"
        set -gx BW_SESSION (bw unlock --raw)
    end

    # Resolve item (id preferred; else search must return exactly one match)
    set -l item_json (bw get item "$item_query" 2>/dev/null)
    if test $status -ne 0
        set -l list_json (bw list items --search "$item_query")
                set -l list_len (printf '%s' "$list_json" | jq -r 'length' 2>/dev/null)
                if test -z "$list_len"
                        echo "Failed to parse Bitwarden search results as JSON." >&2
                        return 2
                end

                if test "$list_len" = 0
                        echo "No Bitwarden items matched search." >&2
                        return 2
                end

                if test "$list_len" != 1
                        echo "Multiple Bitwarden items matched; use an exact item id." >&2
                        printf '%s' "$list_json" | jq -r '.[0:20][] | "- \(.id)  \(.name)"' 2>/dev/null >&2
                        return 3
                end

                set -l resolved_id (printf '%s' "$list_json" | jq -r '.[0].id // empty' 2>/dev/null)
                if test -z "$resolved_id"
                        echo "Bitwarden search returned an item without an id." >&2
                        return 2
                end

                set item_json (bw get item "$resolved_id")
    end

        set -l item_id (printf '%s' "$item_json" | jq -r '.id // empty' 2>/dev/null)
        if test -z "$item_id"
                echo "Failed to read Bitwarden item id." >&2
                return 2
        end

        set -l npm_username (printf '%s' "$item_json" | jq -r '([
            .fields[]? | select(.name == "npm_username") | .value
        ][0] // .login.username // empty)' 2>/dev/null)
        if test -z "$npm_username"
        echo "Missing npm username (login.username or custom field npm_username)." >&2
        return 5
    end

        set -l npm_password (printf '%s' "$item_json" | jq -r '([
            .fields[]? | select(.name == "npm_password") | .value
        ][0] // .login.password // empty)' 2>/dev/null)
        if test -z "$npm_password"
        echo "Missing npm password (login.password or custom field npm_password)." >&2
        return 6
    end

    set -l want_totp 1
    if set -q _flag_no_totp
        set want_totp 0
    end

    set -l otp ''
    if test "$want_totp" = 1
        set otp (string trim -- (bw get totp "$item_id" 2>/dev/null))

        # If Bitwarden doesn't have TOTP configured, or returns something unexpected,
        # fall back to manual OTP entry at the prompt.
        if test -n "$otp"; and not string match -rq '^[0-9]{6,8}$' -- "$otp"
            echo "Warning: Bitwarden TOTP isn't a 6-8 digit code; falling back to manual OTP entry." >&2
            set otp ''
        end

        if set -q _flag_debug
            set -l otp_len (string length -- "$otp")
            if test -n "$otp"
                echo "bw-yarn-login debug: using Bitwarden TOTP (numeric, length=$otp_len)" >&2
            else
                echo "bw-yarn-login debug: no usable Bitwarden TOTP; will prompt for OTP" >&2
            end
        end
    end

    set -gx BW_YARN_NPM_USERNAME "$npm_username"
    set -gx BW_YARN_NPM_PASSWORD "$npm_password"

    # Export OTP only when we have a fresh numeric code; otherwise prompt manually.
    if test -n "$otp"
        set -gx BW_YARN_NPM_OTP "$otp"
    else
        set -e BW_YARN_NPM_OTP 2>/dev/null
    end

    set -gx BW_YARN_NPM_PUBLISH (set -q _flag_publish; and echo 1; or echo 0)
    set -gx BW_YARN_NPM_ALWAYS_AUTH (set -q _flag_always_auth; and echo 1; or echo 0)
    set -gx BW_YARN_NPM_SCOPE "$scope"
    set -gx BW_YARN_NPM_DEBUG (set -q _flag_debug; and echo 1; or echo 0)

    expect -c '
    set timeout -1

        if {[info exists env(BW_YARN_NPM_DEBUG)] && $env(BW_YARN_NPM_DEBUG) == "1"} {
            exp_internal 1
        }

    set username $env(BW_YARN_NPM_USERNAME)
    set password $env(BW_YARN_NPM_PASSWORD)
    set otp ""
    if {[info exists env(BW_YARN_NPM_OTP)]} { set otp $env(BW_YARN_NPM_OTP) }
    # Never auto-send non-numeric OTPs (npm requires digits).
    if {![regexp {^[0-9]{6,8}$} $otp]} { set otp "" }
    set otp_sent 0

    set publish 0
    if {[info exists env(BW_YARN_NPM_PUBLISH)] && $env(BW_YARN_NPM_PUBLISH) == "1"} { set publish 1 }

    set always_auth 0
    if {[info exists env(BW_YARN_NPM_ALWAYS_AUTH)] && $env(BW_YARN_NPM_ALWAYS_AUTH) == "1"} { set always_auth 1 }

    set scope ""
    if {[info exists env(BW_YARN_NPM_SCOPE)]} { set scope $env(BW_YARN_NPM_SCOPE) }

    set cmd [list yarn npm login]
    if {$publish} { lappend cmd --publish }
    if {$always_auth} { lappend cmd --always-auth }
    if {$scope ne ""} { lappend cmd --scope $scope }

        eval spawn $cmd

        # Single loop to avoid "spawn id not open" when the process exits early.
        # Match OTP ONLY on actual prompt lines (Yarn prints warnings containing "OTP").
        expect {
            -re {(?i)\?\s*username\s*:} { send -- "$username\r"; exp_continue }
            -re {(?i)(\?|>)[^\n]*user\s*name[^\n]*} { send -- "$username\r"; exp_continue }
            -re {(?i)email\s*:} { send -- "\r"; exp_continue }

            # OTP prompt (must come before password matching, because the prompt text
            # contains the word "password": "One-time password".
            # Be tolerant of ANSI sequences between tokens.
            -re {(?i)one[- ]?time[^\r\n]*password[^\r\n]*:} {
                if {$otp eq ""} {
                    interact
                } elseif {$otp_sent == 0} {
                    send -- "$otp\r"
                    set otp_sent 1
                }
                exp_continue
            }
            -re {(?i)(^|\n)[^\r\n]*(otp|2fa|auth(entication)?[^\r\n]*code)[^\r\n]*:} {
                if {$otp eq ""} {
                    interact
                } elseif {$otp_sent == 0} {
                    send -- "$otp\r"
                    set otp_sent 1
                }
                exp_continue
            }

            # Password prompt (after OTP rules)
            -re {(?i)(^|\n)[^\r\n]*\?[^\r\n]*password[^\r\n]*:} { send -- "$password\r"; exp_continue }
            -re {(?i)(^|\n)[^\r\n]*(\?|>)[^\r\n]*\bpassword\b[^\r\n]*} { send -- "$password\r"; exp_continue }

            eof
        }
  '

    # This should fail if the token isn't valid / not stored.
    if set -q _flag_publish
        yarn npm whoami --publish
    else if test -n "$scope"
        yarn npm whoami --scope "$scope"
    else
        yarn npm whoami
    end
end
