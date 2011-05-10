haxe doc.hxml
rmdir /S /Q release
rmdir release.zip
mkdir release
xcopy src release /S
xcopy haxelib.xml release
xcopy haxedoc.xml release
cd release
7z a -tzip ..\release.zip *
cd ..
rmdir /S /Q release
haxelib submit release.zip
pause