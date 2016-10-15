from flask import (Flask, request, jsonify)
from models.tables import (app)
from helpers.utils import (PayloadProcessor, BeaconRegistrator)
from uuid import uuid4


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

if __name__ == '__main__':
    app.run(debug=True)
