# edit to deploy somewhere else... note that Request1.hx also has a hardcoded url
DEPLOY_DIR=/var/www/utest/

rm -rf $DEPLOY_DIR*
haxe Request1.hxml
cp -r ../bin/* $DEPLOY_DIR
