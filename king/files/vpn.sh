#!/bin/bash

admin_user=openvpn
admin_pw=openvpn
passwd openvpn <<EOF
${openvpn_admin_password}
${openvpn_admin_password}
EOF
