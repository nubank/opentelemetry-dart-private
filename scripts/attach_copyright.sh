#!/bin/bash

HERE="$(dirname "$0")"
# Locate and array filenames of all Dart files in this repository which do not contain "Copyright YYYY-YYYY Workiva".
# Exclude paths for logs and metrics implementations
IFS=$'\n' read -r -d '' -a FILES <<<"$(find . -type f -name '*.dart' \
    -not -path './lib/src/api/logs/*' \
    -not -path './lib/src/sdk/logs/*' \
    -not -path './lib/src/api/metrics/*' \
    -not -path './lib/src/sdk/metrics/*' \
    -not -path './test/unit/sdk/logs/*' \
    -not -path './test/unit/sdk/metrics/*' \
    -not -path './test/integration/sdk/logs/*' \
    -not -path './example/logs_example.dart' \
    -not -path './example/metrics_example.dart' \
    -print0 | xargs -0 grep -E -L 'Copyright \d+-\d+ Workiva')"

echo "Scanning files and attaching copyright..."

for FILE in "${FILES[@]}"; do
    mv "$FILE" "$FILE".old
    cat "$HERE"/copyright_notice.txt "$FILE".old > "$FILE"
    rm "$FILE".old
    printf 'Updated: %s\n' "$FILE"
done

echo "...done."
