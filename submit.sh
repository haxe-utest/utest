#!/bin/sh
rm utest.zip
zip -r utest.zip hxml src test haxelib.json defines.json meta.json extraParams.hxml README.md CHANGELOG.md -x "*/\.*"
haxelib submit utest.zip
