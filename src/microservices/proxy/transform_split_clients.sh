#!/bin/bash

for env_var in $(compgen -e); do
    if [[ "$env_var" == *MIGRATION_PERCENT ]]; then
        declare -n current_var="$env_var"
        
        if [[ "$current_var" == 0 ]]; then
            export SPLIT_CLIENT_${env_var}="0.01"
        else 
            export SPLIT_CLIENT_${env_var}="$current_var"
        fi
    fi
done

exec "$@"