# 首先要确保安装了pycrypto 安装：sudo easy_install pycrypto
# 
# -*- coding:utf-8 -*-
from Crypto.Cipher import AES
from binascii import b2a_hex, a2b_hex
import sys
import os

class prpcrypt():
    def __init__(self,key):
        self.key = key
        self.mode = AES.MODE_CBC

    def encrypt(self,text):
       cryptor = AES.new(self.key, self.mode, b'0000000000000000')
       length = 16
       count = len(text)

       if count < length:
           add = (length-count)
           text = text + ('\0' * add)
       elif count > length:
           add = (length-(count % length))
           text = text + ('\0' * add)

       self.ciphertext = cryptor.encrypt(text)
       return b2a_hex(self.ciphertext)
     
    def decrypt(self,text):
        cryptor = AES.new(self.key, self.mode, b'0000000000000000')
        plain_text  = cryptor.decrypt(a2b_hex(text))
        return plain_text.rstrip('\0')


def get_text_file(filename):
    if not os.path.exists(filename):
        print("ERROR: file not exit: %s" % (filename))
        return None
 
    if not os.path.isfile(filename):
        print("ERROR: %s not a filename." % (filename))
        return None
 
    f = open(filename, "r")
    content = f.read()
    f.close()
 
    return content
 
def write_text_to_file(text,filePath):
    if not os.path.isfile(filePath):
        print("ERROR: %s not a filename." % (filename))
        return None;

    path = os.path.dirname(filePath)
    path += '/developerInfo.xml'

    f = open(path,"w")
    f.writelines(text);
    return path;

if __name__ == '__main__':

    if len(sys.argv)<=0:
        print "缺少参数"
        sys.exit(0);

    file = sys.argv[1];

    content = get_text_file(file);

    if content==None:
        print "文件读取失败"
        sys.exit(0);

    pc = prpcrypt('xygamecomforksdk')
    e = pc.encrypt(content)
    # d = pc.decrypt(e)

    outputFile = write_text_to_file(e, file);

    print "加密:",e
    print "加密输出文件:",outputFile
    # print "解密:",d