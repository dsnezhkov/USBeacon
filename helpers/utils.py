from flask import (Flask, request, jsonify)
from models.tables import (db, Beacon)
from uuid import uuid4
from datetime import datetime
from base64 import b64decode
import sys,operator

class PayloadProcessor:
    def __init__(self):
        self.payload={} 

    def xor_decrypt_str(cipherText, key):
        ''' 
         Stolen from //raw.githubusercontent.com/silentbreaksec/Throwback/master/Python/tbMangler.py        
        '''
        cipherText = cipherText.split(',')
        clearText = ''
        
        for a in range(0, len(cipherText)):
            c = int(cipherText[a])
            k = ord(key)
            clearText += chr(operator.xor(c, k))

        return clearText

    def decrypt_param(b64_encoded):
        key = '~'
        b64_decoded=bytes.decode(b64decode(b64_encoded.encode('utf-8')))
        print("B64 Decoded: {}".format(b64_decoded))

        plain_payload=PayloadProcessor.xor_decrypt_str(b64_decoded, key)
        print("Plain Payload: {}".format(plain_payload))
        print(plain_payload)
        return plain_payload 

    def process_get(self, request, encrypt=False):
        self.payload['q_ip'] = request.remote_addr or 'N/A'
        self.payload['q_app'] = request.args.get('a') or 'N/A'

        if encrypt == True:
            q_data=request.args.get('d')
            if q_data is not None:
                self.payload['q_data']=PayloadProcessor.decrypt_param(q_data)
            else:
                self.payload['q_data'] = 'N/A'
        else:
            self.payload['q_data'] = request.args.get('d') or 'N/A'

        return self.payload

    def process_put(self, request, encrypt=False):
        content = request.json
        self.payload['q_ip'] = request.remote_addr or 'N/A'
        self.payload['q_app'] = content['a'] if 'a' in content else 'N/A'

        if encrypt == True:
            q_data=content['d'] if 'd' in content else None 
            if q_data is not None:
                self.payload['q_data']=PayloadProcessor.decrypt_param(q_data)
            else:
                self.payload['q_data'] = 'N/A'
        else:
            self.payload['q_data'] = content['d'] if 'd' in content else 'N/A'

        return self.payload

    def process_post(self, request, encrypt=False):
        self.payload['q_ip'] = request.remote_addr or 'N/A'
        self.payload['q_app'] = request.form.get('a') or 'N/A'

        if encrypt == True:
            q_data=request.form.get('d') or None
            if q_data is not None:
                self.payload['q_data']=PayloadProcessor.decrypt_param(q_data)
            else:
                self.payload['q_data'] = 'N/A'
        else:
            self.payload['q_data'] = request.form.get('d') or 'N/A'

        return self.payload

class BeaconRegistrator:
    def accept_beacon(self,hashid,payload_struct):
        beacon = Beacon(hashid, 
                        payload_struct['q_app'], 
                        payload_struct['q_ip'], 
                        payload_struct['q_data'], datetime.now())
        db.session.add(beacon)
        db.session.commit()

        # Log new beacon just in case
        beacon_new = Beacon.query.filter_by(hashid=hashid).first()
        print(beacon_new)

        # we don't provide error codes to beacons (yet?)
        return ('', 200)
