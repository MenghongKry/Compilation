#!/bin/sh
# Generate the lexer with JFlex, then compile everything into build/
set -e
cd "$(dirname "$0")"
jflex -d src src/LogScanner.flex
mkdir -p build
javac -d build src/*.java
echo "Build OK. Run:  java -cp build LogScan"
