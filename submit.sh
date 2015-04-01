#!/bin/sh
rm utest.zip
zip -r utest.zip hxml src test haxelib.json README.md -x "*/\.*"
haxelib submit utest.zip
