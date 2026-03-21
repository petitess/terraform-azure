import logging
import socket


def check_proxy_connectivity(proxy_host, proxy_port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)

        result = sock.connect_ex((proxy_host, proxy_port))
        if result == 0:
            logging.info(f"'{proxy_host}:{proxy_port}' is open")
        else:
            logging.info(f"'{proxy_host}:{proxy_port}' is not open")

        sock.close()
    except Exception as e:
        logging.info(f"Error checking proxy connectivity: {e}")


SG_PROXY = {} # {"http": "1.1.128.8:8080", "https": "1.1.128.8:8080"}
