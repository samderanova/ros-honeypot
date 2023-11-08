from datetime import datetime, timedelta
import os

from scapy.all import *
from scapy.sessions import TCPSession

LAST_RECEIVED = None
COUNTER = 0

def sniff_packets(iface):
    sniff(filter="port 11311", prn=process_packet, iface=iface)

def process_packet(packet):
    global LAST_RECEIVED, COUNTER
    now = datetime.now()
    if LAST_RECEIVED is None or now - LAST_RECEIVED > timedelta(hours=6):
        LAST_RECEIVED = now
        COUNTER += 1

    ymd_date = now.strftime("%Y-%m-%d")
    file_path = os.path.join("/", "root", "ros-honeypot", "data", f"{ymd_date}.{COUNTER}.pcap")
    wrpcap(file_path, packet, append=os.path.isfile(file_path))


if __name__ == "__main__":
    sniff_packets("enp1s0")

