from base64 import b64encode, b64decode
import operator


def encodeString(clearText, key):
    cipherText='' 
    for a in range(0,len(clearText)):
        c = ord(clearText[a])
        k = ord(key)
        cipherText += str(operator.xor(c, k) )
        if a < (len(clearText)-1): cipherText += ','
    
    return cipherText


def decodeString(cipherText, key):
    
    cipherText = cipherText.split(',')
    clearText = ''
    
    for a in range(0, len(cipherText)):
        c = int(cipherText[a])
        k = ord(key)
        clearText += chr(operator.xor(c, k))
    
    return clearText

    
def main():
    key = '~'
    payload="""{
            'a':'A', 
            'b':'√√',
            'c':'123'
        }"""


    print()
    print("Plain Payload: {}".format(payload))
    xor_payload=encodeString(payload, key)

    print("XOR'd Payload: {}".format(xor_payload))

    b64_encoded=b64encode(bytes(xor_payload, 'utf-8')).decode('utf-8')
    print("B64 Encoded: {}".format(b64_encoded))

    b64_decoded=bytes.decode(b64decode(b64_encoded.encode('utf-8')))
    print("B64 Decoded: {}".format(b64_decoded))

    plain_payload=decodeString(b64_decoded, key)
    print("Plain Payload: {}".format(plain_payload))

if __name__ == '__main__':
    main()
    
