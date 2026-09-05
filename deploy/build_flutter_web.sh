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

# 0. Clean up example folders that interfere with workspace resolution.
# CI-only: on a developer tree this permanently deletes working example apps.
log_step "0/6 Cleaning up example folders..."
if [[ -n "${CI:-}" ]]; then
    find packages -type d -name "example" -exec rm -rf {} + 2>/dev/null || true
    log_info "Removed example folders from packages (CI)"
else
    log_info "Skipping example cleanup (not CI)"
fi

# 1. Fetch Flutter dependencies for the main app
log_step "1/6 Getting Flutter packages for main app..."
flutter pub get || { log_error "Failed to get Flutter packages"; exit 1; }

# 1.5 Activate pubspec_generator (actual generation runs after build_runner in step 3.5)
dart pub global activate pubspec_generator || { log_error "Failed to activate pubspec_generator"; exit 1; }

# 3. Run all code generation tasks in parallel (for monorepo packages)
log_step "3/6 Running code generation tasks in parallel..."

# Create a temporary directory to collect job outputs
JOBS_DIR=$(mktemp -d)
# (The cleanup trap will remove this directory on exit)

# Initialize job tracking
declare -A job_packages      # Map job_id -> package name
declare -a job_pids          # Array to store background job PIDs
job_count=0
active_jobs=0

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

# Packages first, app AFTER the wait below: the app's build_runner consumes the packages'
# generated output, so it must not race them in the same parallel wave.

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
        exit 1
    else
        log_info "✅ All $success_count code generation jobs completed successfully"
    fi
else
    log_info "No code generation tasks needed"
fi

# 3.2 App codegen — serial, after every package job finished (see the ordering note above).
if grep -q "build_runner:" pubspec.yaml; then
    log_info "Running code generation for the main app..."
    if ! dart run build_runner build --release --fail-on-severe -d; then
        log_error "build_runner failed for the main app"
        exit 1
    fi
    job_count=$((job_count + 1))
fi

# 3.5 Generate pubspec.yaml.g.dart (runs after build_runner to avoid -d deleting it)
PUBSPEC_GEN="lib/_core/generated/constant/pubspec.yaml.g.dart"
log_info "Generating pubspec.yaml.g.dart..."
dart pub global run pubspec_generator:generate \
    --input pubspec.yaml \
    --output "$PUBSPEC_GEN" || { log_error "Failed to generate pubspec.yaml.g.dart"; exit 1; }
log_info "pubspec.yaml.g.dart generated successfully"

# 4. Build the Flutter web app (release mode)
log_step "4/6 Building Flutter web app..."
# Construct extra --dart-define arguments for any provided secret keys.
# Use a bash array so values stay correctly quoted when passed through.
BUILD_DEFINES=()
if [[ -n "${S3_URL:-}" ]]; then
    BUILD_DEFINES+=(--dart-define="S3_URL=${S3_URL}")
    log_info "Added S3_URL to build defines"
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

# 4.3 Strip repo files that must not ship: the web README documents the token/XSS
# threat model. Flutter copies web/ verbatim into build/web; removing it BEFORE
# sw:generate keeps it out of the SW precache manifest too. firebase.json
# `hosting.ignore` guards the same for deploys made outside this script.
# (v0/v1/prod-basic template snapshots were deleted from web/ on 2026-09-02.)
rm -f build/web/README.md
log_info "Removed non-shipping web files (README.md)"

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
# Runs AFTER the Sentry upload above, so sentry_dart_plugin still gets the maps.
if [ "$APP_ENVIRONMENT" = "production" ]; then
    find build/web -type f -name '*.map' -delete
    log_info "Source maps removed (production)"
else
    log_info "Source maps preserved (${APP_ENVIRONMENT}) for debugging"
fi

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
