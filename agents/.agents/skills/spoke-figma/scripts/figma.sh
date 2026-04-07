#!/bin/bash

# Figma REST API wrapper for agent workflows
# Navigation tool for exploring and exporting Figma designs
set +H  # Disable history expansion
set -o posix  # Enable POSIX mode for better compatibility
set -euo pipefail  # Prevents errors in a pipeline from being masked

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${1:-}" != "help" && "${1:-}" != "--help" && "${1:-}" != "-h" && -n "${1:-}" ]]; then
    "$SCRIPT_DIR/validate.sh" >/dev/null
fi

# Configuration
FIGMA_API_URL="https://api.figma.com/v1"
DEBUG="${DEBUG:-0}"

# Load environment variables if not already set
if [ -z "${FIGMA_TOKEN:-}" ]; then
    [ -f "$HOME/.spoke-env" ] && source "$HOME/.spoke-env"
fi

# Load token lookup table for semantic name resolution
TOKEN_LOOKUP_FILE="$SCRIPT_DIR/figma-tokens.json"

# Build token lookup as jq expression (loaded once, reused in filters)
build_token_lookup() {
    if [ ! -f "$TOKEN_LOOKUP_FILE" ]; then
        # No lookup file - return empty lookup
        echo '{}'
        return
    fi

    # Build lookup: canonicalId -> tokenPath
    cat "$TOKEN_LOOKUP_FILE" | jq 'map({(.canonicalId): .tokenPath}) | add'
}

# Utility: Parse Figma URL to extract file key and node ID
parse_figma_url() {
    local url="$1"
    local file_key=""
    local node_id=""
    
    # Extract file key from URL (supports design, file, and proto URLs)
    # File keys are 22-128 alphanumeric characters
    if [[ "$url" =~ /(design|file|proto)/([A-Za-z0-9]{22,128}) ]]; then
        file_key="${BASH_REMATCH[2]}"
    fi
    
    # Extract node ID from URL (if present)
    # Node IDs are in format like 12:34 or 12-34 (URL encoded as 12%3A34 or 12-34)
    if [[ "$url" =~ node-id=([^&]+) ]]; then
        node_id="${BASH_REMATCH[1]}"
        # URL decode the node ID (handle %3A -> :)
        node_id="${node_id//%3A/:}"
        # Also handle dash format (12-34) by converting to colon format
        if [[ "$node_id" =~ ^[0-9]+-[0-9]+$ ]]; then
            node_id="${node_id//-/:}"
        fi
    fi
    
    # Return as JSON for easy parsing
    jq -n -c \
        --arg key "$file_key" \
        --arg node "$node_id" \
        '{"file_key": $key, "node_id": $node}'
}

# Utility: Make Figma API request
figma_request() {
    local endpoint="$1"
    local method="${2:-GET}"
    
    if [ "$DEBUG" = "1" ]; then
        echo "Request: $method $FIGMA_API_URL$endpoint" >&2
    fi
    
    local response
    response=$(curl -s -X "$method" \
        -H "X-Figma-Token: $FIGMA_TOKEN" \
        "$FIGMA_API_URL$endpoint" \
        --fail-with-body 2>&1)
    
    # Check for curl errors
    if [ $? -ne 0 ]; then
        # Check if it's a rate limit error
        if printf '%s\n' "$response" | grep -q "429"; then
            echo "Error: Rate limit exceeded (60 requests/minute). Try again later." >&2
        elif printf '%s\n' "$response" | grep -q "403"; then
            echo "Error: Invalid token or insufficient permissions. Check FIGMA_TOKEN in ~/.spoke-env" >&2
        elif printf '%s\n' "$response" | grep -q "404"; then
            echo "Error: File or node not found. Check the URL/ID is correct." >&2
        else
            echo "Error: Failed to connect to Figma API" >&2
            echo "Details: $response" >&2
        fi
        exit 1
    fi
    
    # Check for API errors in response
    if printf '%s\n' "$response" | jq -e '.err' > /dev/null 2>&1 && \
       [ "$(printf '%s\n' "$response" | jq -r '.err')" != "null" ]; then
        local error_message
        error_message=$(printf '%s\n' "$response" | jq -r '.err // "Unknown error"')
        echo "Error: $error_message" >&2
        exit 1
    fi
    
    # Return response
    printf '%s\n' "$response"
}

# Removed cmd_file_show - page list is the entry point now

# Command: page list - List pages in a file
cmd_page_list() {
    local input="${1:-}"
    
    if [ -z "$input" ]; then
        echo "Error: File key or URL required" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    local file_key=""
    
    # Check if input is a URL or direct file key
    if [[ "$input" =~ ^https?:// ]]; then
        # It's a URL, parse it
        local parsed
        parsed=$(parse_figma_url "$input")
        file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')
        
        if [ -z "$file_key" ] || [ "$file_key" = "null" ]; then
            echo "Error: Could not extract file key from URL" >&2
            echo "URL should be like: https://www.figma.com/design/FILE_KEY/NAME" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi
    else
        # Assume it's a direct file key
        file_key="$input"
    fi

    # Validate file key format
    if ! [[ "$file_key" =~ ^[A-Za-z0-9]{22,128}$ ]]; then
        echo "Error: Invalid file key format. Must be 22-128 alphanumeric characters." >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi

    if [ "$DEBUG" = "1" ]; then
        echo "Fetching page list for file: $file_key" >&2
    fi
    
    # Always use depth=1 to just get pages
    local endpoint="/files/$file_key?depth=1"
    local response
    response=$(figma_request "$endpoint")
    
    # Extract and display page names only
    printf '%s\n' "$response" | jq -r '.document.children[] | select(.type == "CANVAS") | .name'
}

# Command: page show - Fetch specific page content
cmd_page_show() {
    local input="${1:-}"
    local page_name="${2:-}"
    local depth="${3:-1}"  # Optional depth parameter, default is 1 (sections/frames within page)
    
    if [ -z "$input" ]; then
        echo "Error: File key or URL required" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    local file_key=""
    
    # Check if input is a URL or direct file key
    if [[ "$input" =~ ^https?:// ]]; then
        # It's a URL, parse it
        local parsed
        parsed=$(parse_figma_url "$input")
        file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')
        
        if [ -z "$file_key" ] || [ "$file_key" = "null" ]; then
            echo "Error: Could not extract file key from URL" >&2
            echo "URL should be like: https://www.figma.com/design/FILE_KEY/NAME" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi
    else
        # Assume it's a direct file key
        file_key="$input"
    fi

    # Validate file key format
    if ! [[ "$file_key" =~ ^[A-Za-z0-9]{22,128}$ ]]; then
        echo "Error: Invalid file key format. Must be 22-128 alphanumeric characters." >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi

    # First, fetch the file at depth 1 to get page list
    if [ "$DEBUG" = "1" ]; then
        echo "Fetching page list for file: $file_key" >&2
    fi
    
    local endpoint="/files/$file_key?depth=1"
    local response
    response=$(figma_request "$endpoint")
    
    # Extract page information
    local pages
    pages=$(printf '%s\n' "$response" | jq -r '.document.children[] | select(.type == "CANVAS") | .name')
    
    # Page name is required for show command
    if [ -z "$page_name" ]; then
        echo "Error: Page name required" >&2
        echo "Available pages:" >&2
        printf '%s\n' "$pages" | while IFS= read -r page; do
            echo "  - $page" >&2
        done
        echo "" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    # Find the page ID for the requested page name (case-insensitive, whitespace-normalized)
    local page_id
    page_id=$(printf '%s\n' "$response" | jq -r --arg name "$page_name" '
        def normalize: gsub("^\\s+|\\s+$"; "") | ascii_downcase;
        .document.children[] |
        select(.type == "CANVAS" and ((.name | normalize) == ($name | normalize))) |
        .id
    ')
    
    if [ -z "$page_id" ] || [ "$page_id" = "null" ]; then
        echo "Error: Page '$page_name' not found" >&2
        echo "Available pages:" >&2
        printf '%s\n' "$pages" | while IFS= read -r page; do
            echo "  - $page" >&2
        done
        exit 1
    fi
    
    if [ "$DEBUG" = "1" ]; then
        echo "Found page '$page_name' with ID: $page_id" >&2
        echo "Fetching page content with depth: $depth" >&2
    fi
    
    # Validate depth
    if ! [[ "$depth" =~ ^[0-9]+$ ]] || [ "$depth" -lt 1 ]; then
        echo "Error: Depth must be a positive integer" >&2
        exit 1
    fi
    
    # Fetch the specific page using nodes endpoint
    endpoint="/files/$file_key/nodes?ids=$page_id&depth=$depth"
    response=$(figma_request "$endpoint")
    
    # Apply navigation filtering to reduce response size
    # Level 0 = page canvas, level 1 = direct children (sections/frames)
    local filtered
    filtered=$(printf '%s\n' "$response" | jq --arg page_name "$page_name" '
        def filter_node(level):
            if type == "object" then
                {
                    id: .id,
                    name: .name,
                    type: .type,
                    characters: .characters
                } +
                # Size only at level 1 (direct children of page)
                (if level == 1 and has("absoluteBoundingBox") and .absoluteBoundingBox.width != null and .absoluteBoundingBox.height != null then
                    {size: "\(.absoluteBoundingBox.width | floor)×\(.absoluteBoundingBox.height | floor)"}
                else {} end) +
                # Warning on ANY oversized node (>4000pt produces illegible exports)
                (if has("absoluteBoundingBox") and .absoluteBoundingBox.width != null and .absoluteBoundingBox.height != null and (([.absoluteBoundingBox.width, .absoluteBoundingBox.height] | max) > 4000) then
                    {exportWarning: "too large"}
                else {} end) +
                # Recurse for children
                (if has("children") and (.children | type == "array") then
                    {children: (.children | map(filter_node(level + 1)))}
                else {} end)
            elif type == "array" then
                map(filter_node(level))
            else
                .
            end;

        # Extract just the page node and apply filtering
        {
            name: .name,
            lastModified: .lastModified,
            thumbnailUrl: .thumbnailUrl,
            page: {
                name: $page_name,
                content: (.nodes | to_entries | .[0].value.document | filter_node(0))
            }
        }
    ')

    if [ "$DEBUG" = "1" ]; then
        local filtered_size
        filtered_size=$(printf '%s\n' "$filtered" | wc -c)
        local original_size
        original_size=$(printf '%s\n' "$response" | wc -c)
        local original_kb=$((original_size / 1024))
        local filtered_kb=$((filtered_size / 1024))
        local reduction=$(( (original_size - filtered_size) * 100 / original_size ))
        echo "Filtering: ${original_kb}KB → ${filtered_kb}KB (${reduction}% reduction)" >&2
    fi
    
    printf '%s\n' "$filtered"
}

# Command: node show - Fetch specific nodes with optional depth control
cmd_node_show() {
    local input="${1:-}"
    local node_ids="${2:-}"
    local depth="${3:-1}"  # Optional depth parameter, default is 1
    
    if [ -z "$input" ] || [ -z "$node_ids" ]; then
        echo "Error: File key/URL and node IDs required" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    local file_key=""
    
    # Parse file key (reuse existing logic)
    if [[ "$input" =~ ^https?:// ]]; then
        local parsed
        parsed=$(parse_figma_url "$input")
        file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')

        if [ -z "$file_key" ] || [ "$file_key" = "null" ]; then
            echo "Error: Could not extract file key from URL" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi
    else
        file_key="$input"
    fi

    # Validate file key
    if ! [[ "$file_key" =~ ^[A-Za-z0-9]{22,128}$ ]]; then
        echo "Error: Invalid file key format" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    if [ "$DEBUG" = "1" ]; then
        echo "Fetching nodes: $node_ids from file: $file_key" >&2
    fi
    
    # Validate depth if provided
    if [ -n "$depth" ]; then
        if ! [[ "$depth" =~ ^[0-9]+$ ]] || [ "$depth" -lt 1 ]; then
            echo "Error: Depth must be a positive integer" >&2
            exit 1
        fi
    fi
    
    # Fetch specific nodes with optional depth
    local endpoint="/files/$file_key/nodes?ids=$node_ids"
    if [ -n "$depth" ]; then
        endpoint="${endpoint}&depth=$depth"
    fi
    
    local response
    response=$(figma_request "$endpoint")

    # Load token lookup table for semantic name resolution
    local token_lookup
    token_lookup=$(build_token_lookup)

    # Apply spec filtering to reduce response size while keeping design-relevant fields
    # Keep: id, name, type, children, characters, dimensions, spacing, typography, fills (simplified), design tokens
    # Now also includes: effects, strokes, corner radius, opacity, constraints, text alignment
    local filtered
    filtered=$(printf '%s\n' "$response" | jq \
        --argjson tokenLookup "$token_lookup" \
        --argjson debug "$DEBUG" '
        # Extract canonical ID from variable ID
        def extractCanonicalId:
            if . == null then null
            elif type != "string" then null
            elif startswith("VariableID:") | not then null
            else
                # Remove VariableID: prefix
                .[11:] |
                # Split by / to get hash portion
                split("/")[0]
            end;

        # Resolve semantic name from canonical ID
        def resolveSemanticName:
            . as $canonicalId |
            if $canonicalId == null then null
            else $tokenLookup[$canonicalId] // null
            end;

        # Resolve semantic name from boundVariable (returns string or null)
        def getSemanticName($boundVar):
            if $boundVar == null then null
            elif ($boundVar | type) == "object" and $boundVar.id != null then
                # Single variable binding
                $boundVar.id | extractCanonicalId | resolveSemanticName
            elif ($boundVar | type) == "array" and ($boundVar | length) > 0 and $boundVar[0].id != null then
                # Array of variable bindings (e.g., fills)
                $boundVar[0].id | extractCanonicalId | resolveSemanticName
            else
                null
            end;

        def filter_spec:
            if type == "object" then
                # Store boundVariables for enrichment
                (.boundVariables // {}) as $boundVars |
                # Start with basic fields
                {
                    id: .id,
                    name: .name,
                    type: .type,
                    characters: .characters,
                    width: .width,
                    height: .height
                } +
                # Add spacing fields if present
                (if has("paddingLeft") then {paddingLeft: .paddingLeft} else {} end) +
                (if has("paddingRight") then {paddingRight: .paddingRight} else {} end) +
                (if has("paddingTop") then {paddingTop: .paddingTop} else {} end) +
                (if has("paddingBottom") then {paddingBottom: .paddingBottom} else {} end) +
                (if has("itemSpacing") then {itemSpacing: .itemSpacing} else {} end) +
                # Add semantic names for spacing
                (getSemanticName($boundVars.paddingLeft) as $name | if $name then {paddingLeftSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.paddingRight) as $name | if $name then {paddingRightSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.paddingTop) as $name | if $name then {paddingTopSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.paddingBottom) as $name | if $name then {paddingBottomSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.itemSpacing) as $name | if $name then {itemSpacingSemanticName: $name} else {} end) +
                (if has("layoutMode") then {layoutMode: .layoutMode} else {} end) +
                (if has("layoutSizingHorizontal") then {layoutSizingHorizontal: .layoutSizingHorizontal} else {} end) +
                (if has("layoutSizingVertical") then {layoutSizingVertical: .layoutSizingVertical} else {} end) +
                (if has("primaryAxisAlignItems") then {primaryAxisAlignItems: .primaryAxisAlignItems} else {} end) +
                (if has("counterAxisAlignItems") then {counterAxisAlignItems: .counterAxisAlignItems} else {} end) +
                # Skip resolved style object (fontSize, fontWeight, etc.) - lacks semantic meaning. Typography variables in boundVariables ARE extracted.
                (if has("textAlignHorizontal") then {textAlignHorizontal: .textAlignHorizontal} else {} end) +
                (if has("textAlignVertical") then {textAlignVertical: .textAlignVertical} else {} end) +
                # Add corner radius fields
                (if has("cornerRadius") then {cornerRadius: .cornerRadius} else {} end) +
                (if has("rectangleCornerRadii") then {rectangleCornerRadii: .rectangleCornerRadii} else {} end) +
                # Add semantic names for corner radius
                (getSemanticName($boundVars.cornerRadius) as $name | if $name then {cornerRadiusSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.rectangleCornerRadii.RECTANGLE_TOP_LEFT_CORNER_RADIUS) as $name | if $name then {rectangleCornerRadiiSemanticName: $name} else {} end) +
                # Add visual styling fields
                (if has("opacity") then {opacity: .opacity} else {} end) +
                (if has("blendMode") then {blendMode: .blendMode} else {} end) +
                # Add constraints for responsive behavior
                (if has("constraints") then {constraints: .constraints} else {} end) +
                (if has("layoutAlign") then {layoutAlign: .layoutAlign} else {} end) +
                (if has("layoutGrow") then {layoutGrow: .layoutGrow} else {} end) +
                # Add positioning
                (if has("absoluteBoundingBox") then {absoluteBoundingBox: .absoluteBoundingBox} else {} end) +
                (if has("relativeTransform") then {relativeTransform: .relativeTransform} else {} end) +
                # Add strokes (simplified - first stroke only to save space)
                (if has("strokes") and (.strokes | type == "array") and (.strokes | length > 0) then
                    {strokes: (.strokes[0:1] | map({type, color: .color?, opacity: .opacity?}))}
                else {} end) +
                (if has("strokeWeight") then {strokeWeight: .strokeWeight} else {} end) +
                (if has("strokeAlign") then {strokeAlign: .strokeAlign} else {} end) +
                # Add effects (with key properties)
                (if has("effects") and (.effects | type == "array") and (.effects | length > 0) then
                    {effects: (.effects | map({
                        type,
                        visible: .visible,
                        radius: .radius?,
                        color: .color?,
                        offset: .offset?,
                        spread: .spread?
                    }))}
                else {} end) +
                # Add design system references
                (if has("styles") then {styles: .styles} else {} end) +
                (if has("componentProperties") then {componentProperties: .componentProperties} else {} end) +
                (if has("componentId") then {componentId: .componentId} else {} end) +
                # Simplified fills - just first color
                (if has("fills") and (.fills | type == "array") and (.fills | length > 0) then
                    {fills: (.fills[0:1] | map(if has("color") then {type, color: .color} else {type} end))}
                else {} end) +
                # Add semantic names for fills and strokes
                (getSemanticName($boundVars.fills) as $name | if $name then {fillsSemanticName: $name} else {} end) +
                (getSemanticName($boundVars.strokes) as $name | if $name then {strokesSemanticName: $name} else {} end) +
                # Conditionally add boundVariables (only in DEBUG mode)
                (if $debug == 1 and has("boundVariables") then
                    {boundVariables: .boundVariables}
                else {} end) +
                # Recurse for children if present
                (if has("children") and (.children | type == "array") then
                    {children: (.children | map(filter_spec))}
                else {} end)
            elif type == "array" then
                map(filter_spec)
            else
                .
            end;
        
        # Filter each node entry individually - nodes have nested document structure
        def filter_node_entry:
            if has("document") then
                {
                    document: (.document | filter_spec),
                    components: .components,
                    componentSets: .componentSets,
                    styles: .styles,
                    schemaVersion: .schemaVersion
                }
            else
                filter_spec
            end;
        
        # Preserve file metadata but filter nodes
        {
            name: .name,
            lastModified: .lastModified,
            thumbnailUrl: .thumbnailUrl,
            version: .version,
            role: .role,
            editorType: .editorType,
            linkAccess: .linkAccess,
            nodes: (.nodes | with_entries(.value |= filter_node_entry))
        }
    ')

    if [ "$DEBUG" = "1" ]; then
        local filtered_size
        filtered_size=$(printf '%s\n' "$filtered" | wc -c)
        local original_size
        original_size=$(printf '%s\n' "$response" | wc -c)
        local original_kb=$((original_size / 1024))
        local filtered_kb=$((filtered_size / 1024))
        if [ "$original_size" -gt 0 ]; then
            local reduction=$(( (original_size - filtered_size) * 100 / original_size ))
            echo "Filtering: ${original_kb}KB → ${filtered_kb}KB (${reduction}% reduction)" >&2
        fi
    fi

    printf '%s\n' "$filtered"
}

# Command: node export
cmd_node_export() {
    local input1="${1:-}"
    local input2="${2:-}"
    
    if [ -z "$input1" ]; then
        echo "Error: File key/URL and node ID required" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    local file_key=""
    local node_id=""
    
    # Check if we have one or two arguments
    if [ -z "$input2" ]; then
        # Single argument - must be URL with node ID
        if ! [[ "$input1" =~ ^https?:// ]]; then
            echo "Error: When using single argument, it must be a URL with node-id" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi

        local parsed
        parsed=$(parse_figma_url "$input1")
        file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')
        node_id=$(printf '%s\n' "$parsed" | jq -r '.node_id')

        if [ -z "$file_key" ] || [ "$file_key" = "null" ]; then
            echo "Error: Could not extract file key from URL" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi

        if [ -z "$node_id" ] || [ "$node_id" = "null" ]; then
            echo "Error: Could not extract node ID from URL" >&2
            echo "URL should include: ?node-id=NODE_ID" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi
    else
        # Two arguments - file key/URL and node ID
        if [[ "$input1" =~ ^https?:// ]]; then
            # First arg is URL
            local parsed
            parsed=$(parse_figma_url "$input1")
            file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')
        else
            # First arg is direct file key
            file_key="$input1"
        fi
        node_id="$input2"
    fi
    
    # Validate file key format
    if ! [[ "$file_key" =~ ^[A-Za-z0-9]{22,128}$ ]]; then
        echo "Error: Invalid file key format" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi

    if [ "$DEBUG" = "1" ]; then
        echo "Exporting node $node_id from file $file_key" >&2
    fi
    
    # Request PNG export at 2x scale for downstream visual analysis
    local endpoint="/images/$file_key?ids=$node_id&format=png&scale=2"
    local response
    response=$(figma_request "$endpoint")
    
    # Extract S3 URL from response
    local image_url
    image_url=$(printf '%s\n' "$response" | jq -r ".images.\"$node_id\"")
    
    if [ -z "$image_url" ] || [ "$image_url" = "null" ]; then
        echo "Error: Failed to get export URL for node $node_id" >&2
        exit 1
    fi
    
    # Create output directory with today's date
    local date_dir
    date_dir="${TMPDIR:-/tmp}"
    date_dir="${date_dir%/}/spoke-figma/$(date +%Y-%m-%d)"
    mkdir -p "$date_dir"
    
    # Escape node ID for filesystem (replace : with _)
    local node_id_escaped="${node_id//:/_}"
    local output_file="$date_dir/figma-${file_key}-${node_id_escaped}.png"
    
    if [ "$DEBUG" = "1" ]; then
        echo "Downloading image to: $output_file" >&2
    fi
    
    # Download image immediately (S3 URLs expire quickly)
    # Silently overwrite if file exists
    if ! curl -s -L "$image_url" -o "$output_file" --fail; then
        echo "Error: Failed to download image from S3" >&2
        exit 1
    fi

    # Get image dimensions and calculate a conservative target size for visual analysis
    local pixel_dims pixel_width pixel_height
    pixel_dims=$(sips -g pixelWidth -g pixelHeight "$output_file" 2>/dev/null | awk '/pixelWidth:/{w=$2} /pixelHeight:/{h=$2} END{print w, h}')
    pixel_width=${pixel_dims% *}
    pixel_height=${pixel_dims#* }

    # Target dimensions for resize (0 = no resize needed)
    local target_width=0 target_height=0

    if [ -n "$pixel_width" ] && [ -n "$pixel_height" ]; then
        # Conservative constraints: max 1568px either dimension, max 1.15M total pixels
        local max_visual_dim=1568
        local max_visual_pixels=1150000

        target_width=$pixel_width
        target_height=$pixel_height

        # Apply dimension constraint (max 1568px in either dimension)
        if [ "$target_width" -gt "$max_visual_dim" ] || [ "$target_height" -gt "$max_visual_dim" ]; then
            if [ "$target_width" -ge "$target_height" ]; then
                # Width is the long edge
                target_height=$(awk "BEGIN {printf \"%.0f\", $target_height * $max_visual_dim / $target_width}")
                target_width=$max_visual_dim
            else
                # Height is the long edge
                target_width=$(awk "BEGIN {printf \"%.0f\", $target_width * $max_visual_dim / $target_height}")
                target_height=$max_visual_dim
            fi
        fi

        # Apply pixel constraint (max 1.15M total pixels)
        local total_pixels=$((target_width * target_height))
        if [ "$total_pixels" -gt "$max_visual_pixels" ]; then
            local scale
            scale=$(awk "BEGIN {printf \"%.6f\", sqrt($max_visual_pixels / $total_pixels)}")
            target_width=$(awk "BEGIN {printf \"%.0f\", $target_width * $scale}")
            target_height=$(awk "BEGIN {printf \"%.0f\", $target_height * $scale}")
        fi

        # Check if resize is actually needed
        if [ "$target_width" -eq "$pixel_width" ] && [ "$target_height" -eq "$pixel_height" ]; then
            target_width=0
            target_height=0
        fi

        if [ "$DEBUG" = "1" ]; then
            echo "Image dimensions: ${pixel_width}×${pixel_height}" >&2
            if [ "$target_width" -gt 0 ]; then
                local estimated_tokens
                estimated_tokens=$(awk "BEGIN {printf \"%.0f\", ($target_width * $target_height) / 750}")
                echo "Target dimensions: ${target_width}×${target_height} (~${estimated_tokens} tokens)" >&2
            fi
        fi
    fi

    # Resize if needed (sips modifies in place, no external dependencies)
    # Resample along the long edge so sips sets the constrained dimension exactly
    local resize_info=""
    if [ "$target_width" -gt 0 ] && [ "$target_height" -gt 0 ]; then
        if [ "$target_width" -ge "$target_height" ]; then
            sips --resampleWidth "$target_width" "$output_file" >/dev/null 2>&1
        else
            sips --resampleHeight "$target_height" "$output_file" >/dev/null 2>&1
        fi
        resize_info=" (resized from ${pixel_width}×${pixel_height})"
    fi

    # Check against hard limit (3.5MB × 1.33 base64 overhead ≈ 4.66MB, safely under 5MB API limit)
    local file_size_bytes max_file_size=3670016
    file_size_bytes=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")

    if [ "$DEBUG" = "1" ]; then
        local file_size_kb=$((file_size_bytes / 1024))
        echo "Output: ${file_size_kb}KB PNG$resize_info" >&2
    fi

    if [ "$file_size_bytes" -gt "$max_file_size" ]; then
        local file_size_mb
        file_size_mb=$(awk "BEGIN {printf \"%.1f\", $file_size_bytes / 1048576}")
        rm -f "$output_file"
        echo "Error: Exported image exceeds 3.5MB limit (${file_size_mb}MB)" >&2
        echo "Export smaller child nodes instead (use 'page show' with depth 2+)" >&2
        exit 1
    fi

    # Output only the file path for the caller to read
    echo "$output_file"
}

# Command: comment list
cmd_comment_list() {
    local input="${1:-}"
    
    if [ -z "$input" ]; then
        echo "Error: File key or URL required" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi
    
    local file_key=""
    
    # Check if input is a URL or direct file key
    if [[ "$input" =~ ^https?:// ]]; then
        # It's a URL, parse it
        local parsed
        parsed=$(parse_figma_url "$input")
        file_key=$(printf '%s\n' "$parsed" | jq -r '.file_key')
        
        if [ -z "$file_key" ] || [ "$file_key" = "null" ]; then
            echo "Error: Could not extract file key from URL" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
        fi
    else
        # Assume it's a direct file key
        file_key="$input"
    fi

    # Validate file key format
    if ! [[ "$file_key" =~ ^[A-Za-z0-9]{22,128}$ ]]; then
        echo "Error: Invalid file key format" >&2
        echo "Run 'figma.sh help' for usage information" >&2
        exit 1
    fi

    if [ "$DEBUG" = "1" ]; then
        echo "Fetching comments for file: $file_key" >&2
    fi
    
    # Fetch comments
    local endpoint="/files/$file_key/comments"
    local response
    response=$(figma_request "$endpoint")
    
    # Format comments for readability
    printf '%s\n' "$response" | jq '.comments | map({
        id: .id,
        message: .message,
        author: .user.handle,
        created_at: .created_at,
        resolved_at: .resolved_at,
        node_id: .client_meta.node_id,
        node_offset: .client_meta.node_offset
    })'
}

# Command: help
cmd_help() {
    cat << 'EOF'
Usage: figma.sh <command> <subcommand> [options]

PAGES:
  page list [FILE_KEY|URL]              List all pages in a file
  page show [FILE_KEY|URL] [PAGE_NAME] [DEPTH] Show sections and frames in a page
    PAGE_NAME                           Page name (e.g., 'design', 'drafts')
    DEPTH                               Positive integer (default: 1)
      1 = Sections/frames - RECOMMENDED
      2 = Components within frames
      3+ = Deeper navigation

    Use this for:
      - Finding node IDs to export
      - Exploring design structure

    Output includes:
      - size: Dimensions of top-level nodes
      - exportWarning: Do not export (too large to be legible) — use depth 2+ to find smaller child nodes

NODES:
  node show [FILE_KEY|URL] [NODE_IDS] [DEPTH] Get precise specs for components
    NODE_IDS                            Comma-separated (e.g., '307:9277,151:5879')
    DEPTH                               Nesting depth (default: 1)
      1 = Component + direct children only (RECOMMENDED)
      2 = Includes nested children (useful for modals, cards)
      3+ = Deep hierarchy (rarely needed, often exceeds limits)
    
    Use this for:
      - Extracting semantic colors (fills for backgrounds/text, strokes for borders) like "Colors/brand/bg/emphasis"
      - Extracting semantic spacing (padding, itemSpacing) like "Spacing/space-3"
      - Extracting semantic corner radius like "Radius/radius-sm"
      - Extracting semantic typography (Text Styles) like "Title/Light", "Body/Default"
      - Verifying exact measurements and understanding which values are relative vs absolute

    Node selection tips:
      - Use 'page show' to find component IDs, then 'node show' for specs
      - Fetch individual components (buttons, inputs, cards, modals)
      - Avoid entire screens at depth >1 (produces excessive output)
      - For lists: Get one item as template rather than entire list

  node export [FILE_KEY|URL] [NODE_ID]  Export specific node as PNG image
  node export [URL_WITH_NODE]           Export node from URL with node-id param
                                        Saves to: ${TMPDIR:-/tmp}/spoke-figma/YYYY-MM-DD/
                                        Returns: file path only

COMMENTS:
  comment list [FILE_KEY|URL]           List all comments on a Figma file

COMMON PATTERNS:
  # Explore a new Figma design
  figma.sh page list "https://www.figma.com/design/ABC123/Feature-Name"
  figma.sh page show "https://www.figma.com/design/ABC123/Feature-Name" "designs"
  figma.sh node export "https://www.figma.com/design/ABC123/Feature-Name?node-id=307-9277"
  
  # Get precise measurements for a specific button
  figma.sh page show "$URL" "design"    # Find the button's node ID
  figma.sh node show "$URL" "152:12183" # Get padding, corner radius, colors
  
  # Compare multiple text elements
  figma.sh node show "$URL" "152:12181,152:12182,152:12183"  # Get all text at once

TYPICAL WORKFLOW:
  1. Use 'page list' to see available pages in a file
  2. Use 'page show' to explore designs and find node IDs  
  3. Use 'node export' for visual references of specific designs
  4. After reading exported images, use 'node show' if you need precision

NOTES:
  - Production-ready work is typically found on a page called "design" or "designs"; you can usually ignore "cover", "drafts", "exploration", etc.
  - The 'node show' command works best on individual components, not entire screens
  - Text nodes have styles.text reference (eg. "82:74") which maps to file-level styles dictionary with semantic names like "Button/Default" or "Body/Heavy"
EOF
}

# Main command router
main() {
    local command="${1:-}"
    local subcommand="${2:-}"
    
    case "$command" in
        page)
            case "$subcommand" in
                list)
                    shift 2
                    cmd_page_list "$@"
                    ;;
                show)
                    shift 2
                    cmd_page_show "$@"
                    ;;
                *)
                    echo "Error: Unknown page subcommand '$subcommand'" >&2
                    echo "Run 'figma.sh help' for usage information" >&2
                    exit 1
                    ;;
            esac
            ;;
        node)
            case "$subcommand" in
                show)
                    shift 2
                    cmd_node_show "$@"
                    ;;
                export)
                    shift 2
                    cmd_node_export "$@"
                    ;;
                *)
                    echo "Error: Unknown node subcommand '$subcommand'" >&2
                    echo "Run 'figma.sh help' for usage information" >&2
                    exit 1
                    ;;
            esac
            ;;
        comment)
            case "$subcommand" in
                list)
                    shift 2
                    cmd_comment_list "$@"
                    ;;
                *)
                    echo "Error: Unknown comment subcommand '$subcommand'" >&2
                    echo "Run 'figma.sh help' for usage information" >&2
                    exit 1
                    ;;
            esac
            ;;
        help|--help|-h|"")
            cmd_help
            ;;
        *)
            echo "Error: Unknown command '$command'" >&2
            echo "Run 'figma.sh help' for usage information" >&2
            exit 1
            ;;
    esac
}

main "$@"
