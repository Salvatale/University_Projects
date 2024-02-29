import httplib

#apriamo connessione verso il nostro server nginx
connection = httplib.HTTPConnection('localhost', 80)
#impostiamo il messaggio della richiesta
connection.request("GET", "/index.html", "HTTP/1.0")
#otteniamo la risposta
response = connection.getresponse()
#estrapoliamo i dati della risposta
data = response.read()
print(data)

#chiusura connessione
connection.close()

