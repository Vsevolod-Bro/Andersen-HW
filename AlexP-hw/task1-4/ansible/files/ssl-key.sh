#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt -subj "/C=RU/ST=NSK/L=NSK/O=Andersen-Test/OU=Broyak Vsevolod/CN=$1"
