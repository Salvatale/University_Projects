#!/usr/bin/env python

# Nome Cognome, data
# Summary :

from socket import *
import sys, time
import optparse


parser = optparse.OptionParser()
parser.add_option('-s', '--server',  dest="server",  default="127.0.0.1", help="nome del server" )
parser.add_option('-p', '--port',    dest="port",    type=int,  default=10084, help="porta di ascolto del server" )
parser.add_option('-m', '--message', dest="message", default="hello from Salvatore, in python", help="messaggio  da spedire")
options, remainder = parser.parse_args()
print "OPTIONS  server:", options.server, " - port:", options.port, " - message:", options.message

addr = (options.server,options.port)
s = socket(AF_INET,SOCK_STREAM)

s.connect(addr)

print "Connesso al server!"
messaggio=options.message
s.send(messaggio+"\r\n")
#s.send("\r\n")
risposta = s.recv(1500)
print "Risposta del server: " + risposta
s.send("")
s.close()
