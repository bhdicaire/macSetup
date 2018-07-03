#!/bin/bash
tempadminuser=tempserveradmin
temppass=$(openssl rand -base64 32)

sysadminctl -addUser $tempadminuser -fullName "Temp Admin User" -password $temppass -admin

/usr/bin/expect<<EOF
set timeout 100
spawn /Applications/Server.app/Contents/ServerRoot/usr/sbin/server setup
puts "$tempadminuser"
puts "$temppass"
expect "Press Return to view the software license agreement." { send \r }
expect "Do you agree to the terms of the software license agreement? (y/N)" { send "y\r" }
expect "User name:" { send "$tempadminuser\r" }
expect "Password:" { send "$temppass\r" }
expect "%"
EOF

sysadminctl -deleteUser $tempadminuser
