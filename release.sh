clear
haxe doc.hxml
rm _
cp doc/doc.js.xml haxedoc.xml
rm -f -r release
rm release.zip
mkdir release
cp haxelib.json release
cp -r src/. release
cp haxelib.json release
cp haxedoc.xml release
cd release
zip -r ../release .
cd ..
rm -f -r release
haxelib submit release.zip
