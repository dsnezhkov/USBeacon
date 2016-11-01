#!/bin/bash

############### Dependencies
apt-get install -y python3 sqlite3 python3-pip

git clone https://github.com/dsnezhkov/USBeacon.git

pip3 install --upgrade virtualenv
virtualenv -p python3 venv

. ./venv/bin/activate
pip3 install -r ./requirements.txt

############### Gunicorn (in my venv)
pip install -I gunicorn
############### beacons.db
python init_db.py

############### NGINX site template
# Movie it to /etc/nginx/sites-available/usbeacon and
# ln -s /etc/nginx/sites-available/usbeacon /etc/nginx/sites-enabled/usbeacon
# Contents:
cat<<HERE>./nginx-usbeacon-site.template
# /etc/nginx/sites-available/usbeacon

# Handle requests to exploreflask.com on port 80
server {
        listen 80;
        server_name <resolvable-domain-from-external>.com;

        # Handle all locations
        location /beacon {
                # Pass the request to Gunicorn
                proxy_pass http://127.0.0.1:8000;

                # Set some HTTP headers so that our app knows where the
                # request really came from
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
HERE

chmod u+x scripts/start_server.sh scripts/stop_server.sh
mkdir logs

################## Start gUnicorn
./scripts/start_server.sh
