#!/bin/sh

# Initialize an empty string to hold the environment variables
env_string=""

# Iterate over the environment variables
for var in $(printenv | awk -F= '{print $1}'); do
  val=$(printenv $var)
  env_string="${env_string}${var}=${val} "
done

# Pass the string of environment variables to /app/bin/web-env
/app/bin/web-env $env_string

# This will exec the CMD from Dockerfile
exec "$@"