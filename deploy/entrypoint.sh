#!/bin/bash

# Initialize an empty string to hold the environment variables
env_string=""

# Iterate over the environment variables
for var in $(compgen -e); do
  # If the variable has a non-empty value
  if [ -n "${!var}" ]; then
    # Append the variable and its value to the string
    env_string+="${var}=${!var} "
  fi
done

# Pass the string of environment variables to /app/bin/web-env
/app/bin/web-env $env_string

# This will exec the CMD from Dockerfile
exec "$@"