#Leonardo Lusoli 8/1/2015
#Roberto Alfieri

from threading import Thread
from socket import *
import sys
import optparse



def ascolto(s,addr):
        print >>sys.stderr, 'connesso a ', addr
        data = s.recv(1500)
        print >>sys.stderr, 'ricevuto "%s"' % data
        answer=data
        s.sendall(answer)
        print >>sys.stderr, 'inviato "%s"' %  answer



if __name__ == "__main__":
        parser = optparse.OptionParser()
        parser.add_option('-s', '--server',  dest="server",  default="127.0.0.1", help="nome del server" )
        parser.add_option('-p', '--port',    dest="port",    type=int,  default=10084, help="porta di ascolto del server" )
        options, remainder = parser.parse_args()
        print "OPTIONS  server:", options.server, " - port:", options.port

        addr = (options.server,options.port)
        sock = socket(AF_INET,SOCK_STREAM)
        # Bind the socket to the port
#        server_address = (nomeserver, port)
        print >>sys.stderr, 'starting up on %s port %s' %  addr
        sock.bind(addr)
        # Listen for incoming connections
        sock.listen(1)
        print >>sys.stderr, 'in attesa di una connessione'
        sock.listen(1)
        # Wait for a connection
        while(1):
                s2, c_addr = sock.accept()
                #set the thread for the receive request
                ric = Thread(target = ascolto, args = (s2,c_addr))
                ric.start()
        sock.close()
