#!/bin/sh
rm utest.zip
zip -r utest.zip hxml src test haxelib.json README.md
haxelib submit utest.zip