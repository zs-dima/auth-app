#!/bin/bash
set -euo pipefail  # Exit on errors or unset vars, and pipeline failures.

# Configure maximum parallel codegen jobs (tunable via env or default)
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-$(nproc 2>/dev/null || echo 4)}

# Color codes for pretty logging
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Logging helper functions
log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step()    { echo -e "${BLUE}[STEP]${NC} $1"; }

# Expected Git source for the service-worker generator. CI can override these
# explicitly, but local runs default to the committed deploy configuration.
SW_GIT_URL="${SW_GIT_URL:-https://github.com/zs-dima/service-worker-generator.git}"
SW_GIT_REF="${SW_GIT_REF:-master}"
SW_GIT_RESOLVED_REF="${SW_GIT_RESOLVED_REF:-00c7d604d0248906eff557f7c6127b3789addc0f}"
SW_RESOLVED_REF=""

extract_sw_lock_section() {
    if [ ! -f "pubspec.lock" ]; then
        log_error "pubspec.lock not found; cannot validate sw dependency"
        return 1
    fi

    awk '
        { sub(/\r$/, "") }
        /^  sw:$/ { in_sw = 1 }
        in_sw {
            if ($0 ~ /^  [^ ]/ && $0 !~ /^  sw:$/) {
                exit
            }
            print
        }
    ' pubspec.lock
}

validate_sw_dependency() {
    local sw_lock_section
    local sw_source
    local sw_url
    local sw_ref
    local sw_resolved_ref

    sw_lock_section="$(extract_sw_lock_section)"
    if [ -z "$sw_lock_section" ]; then
        log_error "pubspec.lock is missing the sw dependency entry"
        return 1
    fi

    sw_source="$(printf '%s\n' "$sw_lock_section" | sed -n 's/^    source: //p' | head -n 1)"
    sw_url="$(printf '%s\n' "$sw_lock_section" | sed -n 's/^      url: //p' | head -n 1 | tr -d '"')"
    sw_ref="$(printf '%s\n' "$sw_lock_section" | sed -n 's/^      ref: //p' | head -n 1 | tr -d '"')"
    sw_resolved_ref="$(printf '%s\n' "$sw_lock_section" | sed -n 's/^      resolved-ref: //p' | head -n 1 | tr -d '"')"

    if [ "$sw_source" != "git" ]; then
        log_error "sw must resolve from git in pubspec.lock, found source: ${sw_source:-missing}"
        printf '%s\n' "$sw_lock_section" >&2
        return 1
    fi

    if [ "$sw_url" != "$SW_GIT_URL" ]; then
        log_error "sw git URL mismatch. Expected ${SW_GIT_URL}, found ${sw_url:-missing}"
        printf '%s\n' "$sw_lock_section" >&2
        return 1
    fi

    if [ "$sw_ref" != "$SW_GIT_REF" ]; then
        log_error "sw git ref mismatch. Expected ${SW_GIT_REF}, found ${sw_ref:-missing}"
        printf '%s\n' "$sw_lock_section" >&2
        return 1
    fi

    if [ -n "$SW_GIT_RESOLVED_REF" ] && [ "$sw_resolved_ref" != "$SW_GIT_RESOLVED_REF" ]; then
        log_error "sw resolved-ref mismatch. Expected ${SW_GIT_RESOLVED_REF}, found ${sw_resolved_ref:-missing}"
        printf '%s\n' "$sw_lock_section" >&2
        return 1
    fi

    SW_RESOLVED_REF="${sw_resolved_ref}"
    log_info "Verified sw dependency source: ${sw_url}@${sw_ref} (${sw_resolved_ref:-no resolved-ref})"
}

require_generated_file() {
    local path="$1"
    local hint="$2"

    if [ -f "$path" ]; then
        log_info "Verified generated file: $path"
        return 0
    fi

    log_error "Missing generated file: $path"
    log_error "$hint"
    return 1
}

validate_generated_bootstrap() {
    local bootstrap_path="build/web/bootstrap.js"
    local has_stale_dispose=0
    local has_async_patch=0
    local has_once_bridge=0

    if [ ! -f "$bootstrap_path" ]; then
        log_error "Generated bootstrap validation failed: $bootstrap_path not found"
        return 1
    fi

    if grep -q 'updateHandlers.clear' "$bootstrap_path"; then
        has_stale_dispose=1
    fi
    if grep -q 'instanceof Promise' "$bootstrap_path"; then
        has_async_patch=1
    fi
    if grep -Eq 'sw-update-available.{0,200}\{[[:space:]]*once[[:space:]]*:[[:space:]]*(true|!0)' "$bootstrap_path"; then
        has_once_bridge=1
    fi

    if [ "$has_stale_dispose" -eq 0 ] && [ "$has_async_patch" -eq 1 ] && [ "$has_once_bridge" -eq 0 ]; then
        log_info "Verified generated bootstrap.js contains the patched SW update flow"
        return 0
    fi

    log_error "Generated bootstrap.js failed validation for sw dependency ${SW_RESOLVED_REF:-unknown}"
    log_error "Stale dispose marker: ${has_stale_dispose}, async patch marker: ${has_async_patch}, one-shot bridge marker: ${has_once_bridge}"
    return 1
}

# Track overall build time
BUILD_START=$(date +%s)

# Cleanup function to run on exit (trap)
cleanup() {
    status=$?
    if [ $status -ne 0 ]; then
        log_error "Build failed! Check the logs above for details."
    fi
    # Remove temporary job output directory (if it exists)
    [[ -n "${JOBS_DIR:-}" && -d "$JOBS_DIR" ]] && rm -rf "$JOBS_DIR"
}
trap cleanup EXIT  # Ensure cleanup runs on script exit (success or failure)
# Note: Using a single trap for cleanup and logging prevents overriding previous traps.

log_info "🚀 Starting Flutter web build..."
log_info "Working directory: $(pwd)"
log_info "Max parallel jobs: $MAX_PARALLEL_JOBS"

# Determine target environment (defaults to 'staging' if not set)
APP_ENVIRONMENT="${APP_ENVIRONMENT:-${1:-staging}}"
log_info "Building for environment: $APP_ENVIRONMENT"
if [ ! -f "config/${APP_ENVIRONMENT}.env" ]; then
    log_error "Environment file config/${APP_ENVIRONMENT}.env not found!"
    exit 1
fi

# 0. Clean up example folders that interfere with workspace resolution
log_step "0/6 Cleaning up example folders..."
find packages -type d -name "example" -exec rm -rf {} + 2>/dev/null || true
log_info "Removed example folders from packages"

# 1. Fetch Flutter dependencies for the main app
log_step "1/6 Getting Flutter packages for main app..."
flutter pub get --enforce-lockfile || { log_error "Failed to get Flutter packages from the committed lockfile"; exit 1; }
validate_sw_dependency || exit 1

# 1.5 Activate pubspec_generator (actual generation runs after build_runner in step 3.5)
dart pub global activate pubspec_generator || { log_error "Failed to activate pubspec_generator"; exit 1; }

# 2. Generate OpenAPI client from the spec (must run before build_runner)
log_step "2/6 Generating OpenAPI client..."
if [ -f "api/openapi/v2/openapi.yaml" ]; then
    if ! dart run openapi_generator:generate \
        --input=api/openapi/v2/openapi.yaml \
        --output=lib/_core/api; then
        log_error "OpenAPI client generation failed"
        exit 1
    fi
    log_info "OpenAPI client generated successfully"
else
    log_warning "OpenAPI spec not found, skipping generation"
fi

# 3. Run all code generation tasks in parallel (for monorepo packages and localization)
log_step "3/6 Running code generation tasks in parallel..."

# Create a temporary directory to collect job outputs
JOBS_DIR=$(mktemp -d)
# (The cleanup trap will remove this directory on exit)

# Initialize job tracking
declare -A job_packages      # Map job_id -> package name
declare -a job_pids          # Array to store background job PIDs
job_count=0
active_jobs=0
localization_job_id=""

# Function to wait until a job slot is free (limits parallel jobs to MAX_PARALLEL_JOBS)
wait_for_job_slot() {
    while [ $active_jobs -ge $MAX_PARALLEL_JOBS ]; do
        wait -n        # Wait for any background job to finish (reduces active_jobs count)
        active_jobs=$((active_jobs - 1))
    done
}

# Function to start a build_runner codegen job for a given package directory
start_build_runner_job() {
    local dir="$1"
    local job_id="$2"
    local package_name=$(basename "$dir")
    wait_for_job_slot   # ensure we have a slot for this job

    (  # Start a subshell for the background codegen job
        local output_file="$JOBS_DIR/job_${job_id}.out"
        cd "$dir"
        # Redirect all output (stdout & stderr) to the job's output file
        exec > "$output_file" 2>&1

        echo "Starting build_runner for $package_name at $(date)"
        start_time=$(date +%s)
        # Ensure package dependencies are fetched
        if ! flutter pub get; then
            echo "ERROR: Flutter pub get failed for $package_name"
            exit 1
        fi

        # Run build_runner build (with retries on failure)
        local retry=0
        local max_retries=2
        while [ $retry -le $max_retries ]; do
            if dart run build_runner build --release --fail-on-severe -d; then
                end_time=$(date +%s)
                echo $(( end_time - start_time )) > "$JOBS_DIR/job_${job_id}.duration"               
                echo "Completed successfully at $(date)"
                exit 0
            fi
            retry=$((retry + 1))
            if [ $retry -le $max_retries ]; then
                echo "Retry $retry/$max_retries for $package_name"
                dart run build_runner clean 2>/dev/null || true
                sleep 2
            fi
        done
        # If we exit the loop, build_runner failed all retries
        echo "ERROR: build_runner failed after $max_retries retries for $package_name"
        exit 1
    ) &  # Run in background
    job_pids[$job_id]=$!
    job_packages[$job_id]="$package_name"
    active_jobs=$((active_jobs + 1))
}

# Schedule codegen for the main app if it uses build_runner
if grep -q "build_runner:" pubspec.yaml; then
    job_count=$((job_count + 1))
    log_info "Scheduling code generation for main app"
    start_build_runner_job "." "$job_count"
fi

# If localization configuration is present, run localization generation as a parallel job
if [ -f "l10n.yaml" ] || grep -q "flutter_intl:" pubspec.yaml || grep -q "intl:" pubspec.yaml; then
    wait_for_job_slot
    job_count=$((job_count + 1))
    localization_job_id=$job_count
    log_info "Scheduling localization generation..."

    (  # Localization generation job
        output_file="$JOBS_DIR/job_${localization_job_id}.out"
        exec > "$output_file" 2>&1
        echo "Starting localization generation at $(date)"
        start_time=$(date +%s)
        # Activate intl_utils (if needed for flutter_intl)
        dart pub global activate intl_utils || {
            echo "ERROR: Failed to activate intl_utils"
            exit 1
        }
        # Generate localization files using intl_utils or flutter gen-l10n
        method=""
        if dart pub global run intl_utils:generate; then
            method="intl_utils"
        else
            echo "Trying flutter gen-l10n as fallback..."
            if flutter gen-l10n; then
                method="flutter_gen_l10n"
            else
                echo "ERROR: Both intl_utils and flutter gen-l10n generation failed"
                exit 1
            fi
        fi
        # Verify that the expected localization output exists
        if [ ! -f "lib/_core/generated/localization/l10n.dart" ]; then
            echo "ERROR: Expected localization file not generated"
            exit 1
        fi

        end_time=$(date +%s)
        echo $(( end_time - start_time )) > "$JOBS_DIR/job_${localization_job_id}.duration"

        if [ "$method" = "flutter_gen_l10n" ]; then
            echo "Completed successfully with flutter gen-l10n at $(date)"
        else
            echo "Completed successfully at $(date)"
        fi
        exit 0
    ) &  # Run localization generation in background
    job_pids[$localization_job_id]=$!
    job_packages[$localization_job_id]="localization"
    active_jobs=$((active_jobs + 1))
fi

# Find and schedule code generation for each package in the monorepo that uses build_runner
if [ -d "package" ] || [ -d "packages" ]; then
    # Look for directories under "package(s)" that contain a pubspec with build_runner as a dependency
    while IFS= read -r dir; do
        if [ -f "$dir/pubspec.yaml" ] && grep -q "build_runner:" "$dir/pubspec.yaml"; then
            job_count=$((job_count + 1))
            package_name=$(basename "$dir")
            log_info "Scheduling code generation for package: $package_name"
            start_build_runner_job "$dir" "$job_count"
        fi
    done < <(find package* -mindepth 1 -maxdepth 2 -type d)
fi

# Wait for all codegen jobs to finish and collect results
if [ ${#job_packages[@]} -gt 0 ]; then
    job_count=${#job_packages[@]}
    log_info "Waiting for $job_count code generation jobs to complete..."
    
    # Collect results from each job (capture exit codes)
    set +e  # allow capturing non-zero exit codes without exiting immediately
    success_count=0
    failed_packages=()
    localization_failed=false
    for i in $(seq 1 $job_count); do
        wait "${job_pids[$i]}"
        exit_code=$?
        package_name=${job_packages[$i]:-"unknown"}
        if [ $exit_code -eq 0 ]; then
            success_count=$((success_count + 1))
            # log_info "✓ $package_name codegen completed successfully"
            if [ -f "$JOBS_DIR/job_${i}.duration" ]; then
                duration=$(cat "$JOBS_DIR/job_${i}.duration")
                minutes=$(( duration / 60 ))
                seconds=$(( duration % 60 ))
                log_info "✓ $package_name codegen completed successfully in ${minutes}m ${seconds}s"
            else
                log_info "✓ $package_name codegen completed successfully"
            fi
        else
            failed_packages+=("$package_name")
            [ "$i" = "$localization_job_id" ] && localization_failed=true
            log_error "✗ $package_name codegen failed:"
            if [ -f "$JOBS_DIR/job_${i}.out" ]; then
                grep -n -i 'SEVERE\|ERROR\|Could not generate\|Exception' "$JOBS_DIR/job_${i}.out" | head -n 20 | sed 's/^/  /' >&2
                echo "  --- last 100 lines ---" >&2
                tail -n 100 "$JOBS_DIR/job_${i}.out" | sed 's/^/  /' >&2
            fi
            log_error "  (See full output in $JOBS_DIR/job_${i}.out)"
        fi
    done
    set -e  # re-enable immediate exit on errors
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_error "Code generation failed for ${#failed_packages[@]} package(s): ${failed_packages[*]}"
        if [ "$localization_failed" = true ]; then
            log_error "Localization generation failed – this is critical for the build."
        fi
        exit 1
    else
        log_info "✅ All $success_count code generation jobs completed successfully"
    fi
else
    log_info "No code generation tasks needed"
fi

# 3.5 Generate pubspec.yaml.g.dart (runs after build_runner to avoid -d deleting it)
PUBSPEC_GEN="lib/_core/generated/constant/pubspec.yaml.g.dart"
log_info "Generating pubspec.yaml.g.dart..."
dart pub global run pubspec_generator:generate \
    --input pubspec.yaml \
    --output "$PUBSPEC_GEN" || { log_error "Failed to generate pubspec.yaml.g.dart"; exit 1; }
log_info "pubspec.yaml.g.dart generated successfully"

ASSETS_GEN="lib/_core/generated/resources/assets.gen.dart"
require_generated_file \
    "$ASSETS_GEN" \
    "FlutterGen output is required by EnvironmentLoader. In CI, avoid restoring .dart_tool/build on a clean checkout if this file is missing." || exit 1

# 4. Build the Flutter web app (release mode)
log_step "4/6 Building Flutter web app..."
# Construct extra --dart-define arguments for any provided secret keys.
# Use a bash array so values stay correctly quoted when passed through.
BUILD_DEFINES=()
if [[ -n "${S3_URL:-}" ]]; then
    BUILD_DEFINES+=(--dart-define="S3_URL=${S3_URL}")
    log_info "Added S3_URL to build defines"
fi
if [[ -n "${OAI_KEY:-}" ]]; then
    BUILD_DEFINES+=(--dart-define="OAI_KEY=${OAI_KEY}")
    log_info "Added OAI_KEY to build defines"
fi
if [[ -n "${WHISPER_ADDRESS:-}" ]]; then
    BUILD_DEFINES+=(--dart-define="WHISPER_ADDRESS=${WHISPER_ADDRESS}")
    log_info "Added WHISPER_ADDRESS to build defines"
fi

# Run the Flutter web build with environment-specific config.
if ! flutter build web --release --no-pub "${BUILD_DEFINES[@]}" \
    --dart-define-from-file="config/${APP_ENVIRONMENT}.env" \
    --source-maps --wasm --no-web-resources-cdn --tree-shake-icons --base-href /; then
    log_error "Flutter web build failed"
    exit 1
fi

# Verify that the build output contains the main index.html (to ensure build succeeded)
if [ ! -f "build/web/index.html" ]; then
    log_error "Build output verification failed: build/web/index.html not found"
    exit 1
fi

# 4.25 Swap dev index.html for the prod template before sw:generate.
# web/index.html is the `flutter run` dev template; web/index.prod.html holds the
# <script data-sw-bootstrap ...> tag that sw:generate expects. Flutter copied both
# into build/web/ verbatim, so we delete the dev copy and rename the prod copy
# over it. See packages/sw README "Local Development".
if [ ! -f "build/web/index.prod.html" ]; then
    log_error "Prod template build/web/index.prod.html is missing; check web/index.prod.html exists"
    exit 1
fi
rm -f build/web/index.html
mv build/web/index.prod.html build/web/index.html
log_info "Swapped dev index.html for prod template (index.prod.html)"

# Post-swap sanity: the prod index.html MUST include the sw bootstrap tag,
# otherwise sw:generate will succeed but the deployed site will load nothing.
if ! grep -q 'data-sw-bootstrap' build/web/index.html; then
    log_error "Post-swap verification failed: build/web/index.html lacks <script data-sw-bootstrap>"
    exit 1
fi

# 4.5 Generate the production bootstrap/update pipeline with the sw CLI.
# sw.yaml defines the input/output/glob rules; only the cache version varies
# per build. `sw` owns the shipping `bootstrap.js` + `sw.js` pair
log_step "4.5/6 Generating service worker..."

# Resolve a deterministic, git-traceable cache version.
# Prefer the CI-provided SHA, normalized to the same 8-char form used locally;
# if git metadata is unavailable (for example in a source archive), fall back to
# a timestamp so release builds still succeed.
if [[ -n "${GIT_SHA:-}" ]]; then
    SW_VERSION="${GIT_SHA:0:8}"
else
    SW_VERSION="$(git rev-parse --short=8 HEAD 2>/dev/null || date +%s)"
fi
log_info "Using sw cache version: ${SW_VERSION}"

# Generate sw.js + bootstrap.js (reads sw.yaml; only --version varies per build).
if ! dart run sw:generate --version="${SW_VERSION}"; then
    log_error "Service worker generation failed"
    exit 1
fi

validate_generated_bootstrap || exit 1

# Verify the final shipping entrypoints exist.
for f in index.html sw.js bootstrap.js; do
    if [ ! -f "build/web/${f}" ]; then
        log_error "Service worker generation verification failed: build/web/${f} not found"
        exit 1
    fi
done

# Verify the deprecated Flutter-generated service worker is not shipped.
if [ -f "build/web/flutter_service_worker.js" ]; then
    log_error "Release output verification failed: build/web/flutter_service_worker.js should not ship when sw is used"
    exit 1
fi

# Verify sw cleanup ran (flutter.js should be gone — it's inlined into bootstrap.js).
if [ -f "build/web/flutter.js" ]; then
    log_error "Cleanup failed: build/web/flutter.js still present after sw generation"
    exit 1
fi
log_info "✅ Service worker generated successfully (sw.js + bootstrap.js, flutter.js inlined)"

# 5. Upload source maps to Sentry (if credentials provided)
log_step "5/6 Uploading source maps to Sentry..."
if [[ -n "${SENTRY_AUTH_TOKEN:-}" && -n "${SENTRY_ORG:-}" && -n "${SENTRY_PROJECT:-}" ]]; then
    if ! dart run sentry_dart_plugin; then
        log_warning "Sentry source map upload failed, but continuing (non-critical)"
    else
        log_info "✅ Source maps uploaded to Sentry"
    fi
else
    log_warning "Sentry credentials not provided, skipping source map upload"
fi

# Remove source map files in production to avoid exposing them publicly.
# Keep them in staging/development for debugging WASM runtime errors.
# if [ "$APP_ENVIRONMENT" = "production" ]; then
#     find build/web -type f -name '*.map' -delete
#     log_info "Source maps removed (production)"
# else
#     log_info "Source maps preserved (${APP_ENVIRONMENT}) for debugging"
# fi

# 6. Generate a build info file for traceability
log_step "6/6 Generating build info..."
BUILD_INFO_FILE="build/web/build-info.json"

# Extract Flutter version safely (fallback if --machine format changes)
FLUTTER_VER=$(flutter --version --machine 2>/dev/null | grep '"frameworkVersion"' | cut -d'"' -f4 || echo "unknown")

cat > "$BUILD_INFO_FILE" << EOF
{
  "environment": "$APP_ENVIRONMENT",
  "buildTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "gitCommit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "gitBranch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
  "flutterVersion": "$FLUTTER_VER",
  "packagesWithCodeGen": $job_count,
  "buildHost": "$(hostname)"
}
EOF

log_info "Build info written to $BUILD_INFO_FILE"

# Calculate build output size for information
BUILD_SIZE=$(du -sh build/web | cut -f1)
BUILD_END=$(date +%s)
BUILD_DURATION=$(( BUILD_END - BUILD_START ))
BUILD_MINS=$(( BUILD_DURATION / 60 ))
BUILD_SECS=$(( BUILD_DURATION % 60 ))

# Final build summary logs
echo ""
log_info "📊 Build Summary:"
log_info "  Environment: $APP_ENVIRONMENT"
log_info "  Code generation jobs: $job_count"
log_info "  Build size: $BUILD_SIZE"
log_info "  Total build time: ${BUILD_MINS}m ${BUILD_SECS}s"
log_info "  Output directory: build/web/"
echo ""
log_info "✅ Flutter web build completed successfully!"
