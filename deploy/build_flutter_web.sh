#!/bin/bash
set -euo pipefail  # Exit on errors or unset vars, and pipeline failures.

# Configure maximum parallel codegen jobs (tunable via env or default)
MAX_PARALLEL_JOBS=${MAX_PARALLEL_JOBS:-$(nproc)}

# Color codes for pretty logging
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Logging helper functions
log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step()    { echo -e "${BLUE}[STEP]${NC} $1"; }

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
log_step "0/5 Cleaning up example folders..."
find packages -type d -name "example" -exec rm -rf {} + 2>/dev/null || true
log_info "Removed example folders from packages"

# 1. Fetch Flutter dependencies for the main app
log_step "1/5 Getting Flutter packages for main app..."
flutter pub get || { log_error "Failed to get Flutter packages"; exit 1; }

# 2. Run all code generation tasks in parallel (for monorepo packages and localization)
log_step "2/5 Running code generation tasks in parallel..."

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
            [ -f "$JOBS_DIR/job_${i}.out" ] && tail -n 20 "$JOBS_DIR/job_${i}.out" | sed 's/^/  /' >&2
            log_error "  (See full output in $JOBS_DIR/job_${i}.out)"
        fi
    done
    set -e  # re-enable immediate exit on errors
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_error "Code generation failed for ${#failed_packages[@]} package(s): ${failed_packages[*]}"
        if [ "$localization_failed" = true ]; then
            log_error "Localization generation failed - this is critical for the build."
        fi
        exit 1
    else
        log_info "✅ All $success_count code generation jobs completed successfully"
    fi
else
    log_info "No code generation tasks needed"
fi

# 3. Build the Flutter web app (release mode)
log_step "3/5 Building Flutter web app..."
# Construct extra --dart-define arguments for any provided secret keys
BUILD_DEFINES=""
if [[ -n "${S3_URL:-}" ]]; then
    BUILD_DEFINES+=" --dart-define=S3_URL=${S3_URL}"
    log_info "Added S3_URL to build defines"
fi
if [[ -n "${OAI_KEY:-}" ]]; then
    BUILD_DEFINES+=" --dart-define=OAI_KEY=${OAI_KEY}"
    log_info "Added OAI_KEY to build defines"
fi
if [[ -n "${WHISPER_ADDRESS:-}" ]]; then
    BUILD_DEFINES+=" --dart-define=WHISPER_ADDRESS=${WHISPER_ADDRESS}"
    log_info "Added WHISPER_ADDRESS to build defines"
fi

# Run the Flutter web build with environment-specific config
if ! flutter build web --release --no-pub ${BUILD_DEFINES} \
    --dart-define-from-file=config/${APP_ENVIRONMENT}.env \
    --source-maps --wasm --no-web-resources-cdn --tree-shake-icons --base-href /; then
    log_error "Flutter web build failed"
    exit 1
fi

# Verify that the build output contains the main index.html (to ensure build succeeded)
if [ ! -f "build/web/index.html" ]; then
    log_error "Build output verification failed: build/web/index.html not found"
    exit 1
fi

# 4. Upload source maps to Sentry (if credentials provided)
log_step "4/5 Uploading source maps to Sentry..."
if [[ -n "${SENTRY_AUTH_TOKEN:-}" && -n "${SENTRY_ORG:-}" && -n "${SENTRY_PROJECT:-}" ]]; then
    if ! flutter pub run sentry_dart_plugin; then
        log_warning "Sentry source map upload failed, but continuing (non-critical)"
    else
        log_info "✅ Source maps uploaded to Sentry"
    fi
else
    log_warning "Sentry credentials not provided, skipping source map upload"
fi

# Remove source map files to avoid exposing them publicly
find build/web -type f -name '*.map' -delete

# 5. Generate a build info file for traceability
log_step "5/5 Generating build info..."
BUILD_INFO_FILE="build/web/build-info.json"
cat > "$BUILD_INFO_FILE" << EOF
{
  "environment": "$APP_ENVIRONMENT",
  "buildTime": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "gitCommit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "gitBranch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
  "flutterVersion": "$(flutter --version --machine | grep '"frameworkVersion"' | cut -d'"' -f4)",
  "packagesWithCodeGen": $job_count,
  "buildHost": "$(hostname)"
}
EOF

log_info "Build info written to $BUILD_INFO_FILE"

# Calculate build output size for information
BUILD_SIZE=$(du -sh build/web | cut -f1)
log_info "Build size: $BUILD_SIZE"

# Final build summary logs
echo ""
log_info "📊 Build Summary:"
log_info "  Environment: $APP_ENVIRONMENT"
log_info "  Code generation jobs: $job_count"
log_info "  Build size: $BUILD_SIZE"
log_info "  Build time: $(date)"
log_info "  Output directory: build/web/"
echo ""
log_info "✅ Flutter web build completed successfully!"
