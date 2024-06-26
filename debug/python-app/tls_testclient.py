import socket
import ssl
import time

HOST = "192.168.1.187"
PORT = 60002

if __name__ == "__main__":
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.load_cert_chain(certfile="/home/tec/certs/public.crt", keyfile="/home/tec/certs/public.key")
    context.load_verify_locations(cafile="/home/tec/certs/rootCA.pem")
    context.check_hostname = False
    context.verify_mode = ssl.CERT_REQUIRED
    

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client = context.wrap_socket(s, server_hostname=HOST)
    s.close()

    client.connect((HOST, PORT))

    while True:
        client.sendall("Hello World!".encode("utf-8"))
        time.sleep(1)
        #data = client.recv(256)
        #print(f"Received {data!r}")