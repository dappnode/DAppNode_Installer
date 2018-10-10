#! /bin/sh
# This is a debconf-compatible script
. /usr/share/debconf/confmodule

# Create the template file
cat > /tmp/ip.template <<'!EOF!'
Template: ip-question/ask
Type: string
Description: If your public IP is dynamic, or you don't know, leave this field blank and continue.
 DAppNode needs to know the public IP of your node.

Template: ip-question/title
Type: text
Description: Your public IP.
!EOF!

debconf-loadtemplate ip-question /tmp/ip.template
db_settitle ip-question/title
db_input critical ip-question/ask
db_go
db_get ip-question/ask

echo "$RET" > /target/usr/src/dappnode/ip.value