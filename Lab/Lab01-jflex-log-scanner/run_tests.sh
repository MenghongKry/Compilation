#!/bin/sh
# Runs every tests/*.txt file and compares the output with tests/*.expected
cd "$(dirname "$0")"
pass=0; fail=0
for input in tests/*.txt; do
    name="${input%.txt}"
    actual=$(java -cp build LogScan "$input" 2>&1)
    if [ "$actual" = "$(cat "$name.expected")" ]; then
        echo "PASS  $(basename "$name")"; pass=$((pass+1))
    else
        echo "FAIL  $(basename "$name")"; fail=$((fail+1))
        echo "  expected:"; sed 's/^/    /' "$name.expected"
        echo "  actual:";   echo "$actual" | sed 's/^/    /'
    fi
done
echo "----"
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
