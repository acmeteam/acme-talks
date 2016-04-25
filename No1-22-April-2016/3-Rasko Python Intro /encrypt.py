from Crypto.Cipher import AES
import base64


################## basic AES encryption ##################

key = 'my key which is '
vec = 'vector 123456789'
        

def encrypt(text):
    text = addPadding(text)
    encryption = AES.new(key, AES.MODE_CBC, vec)
    encryptedText = encryption.encrypt(text)
    encryptedText = base64.b64encode(encryptedText)
    return encryptedText
    
def decrypt(text):
    decryption = AES.new(key, AES.MODE_CBC, vec)
    decriptedText = base64.b64decode(text)
    decriptedText = decryption.decrypt(decriptedText)
    return decriptedText
    
    

#since this encryption is working with 16 byte blocks, this method is used to add padding to n*16 length    
def addPadding(text):
    dm = divmod(len(text), 16)
    if(dm[1] != 0):
        padding = (dm[0]+1) * 16 - len(text)
        padding = ' ' * padding
        return text + padding
    else:
        return text