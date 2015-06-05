#!/bin/bash
regex='\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}'
while read line; do
    while [[ "$line" =~ $regex ]]; do
        param="${BASH_REMATCH[1]}"
        line=${line//${BASH_REMATCH[0]}/${!param}}
    done
    echo $line
done < "/home/app/webapp/config/pull_db_config.json.tmpl" > "/home/app/webapp/config/pull_db_config.json"

