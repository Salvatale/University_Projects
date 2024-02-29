import socket
import sys

if len(sys.argv) < 2:
    name = "146.75.60.223"
else:
   [name] = sys.argv[1:]

try:
    host = socket.gethostbyaddr(name)
    print (host)
except (socket.gaierror, err):
    print ("cannot resolve hostname: ", name, err)
