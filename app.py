from flask import Flask, request, jsonify
from models.tables import (app, db, Beacon)
from uuid import uuid4
from datetime import datetime

@app.route('/beacon', methods=['GET'])
def beacon():
    all_args = request.args.to_dict()
    print(all_args)

    q_app = request.args.get('a') or 'N/A'
    q_ip = request.remote_addr or 'N/A'
    # If beacon hashid is not provided - assign uuid server side for tracking
    # Constraint: size<=8
    q_hashid = request.args.get('h') or uuid4().hex
    q_hashid = q_hashid[:8]

    q_data = request.args.get('d') or 'N/A'

    beacon = Beacon(q_hashid, q_app, q_ip, q_data, datetime.now())
    db.session.add(beacon)
    db.session.commit()

    # Log new beacon just in case
    beacon_new = Beacon.query.filter_by(hashid=q_hashid).first()
    print(beacon_new)

    # we dont; provide error checking to beacons (yet?)
    return ('', 200)

if __name__ == '__main__':
    app.run(debug=True)
