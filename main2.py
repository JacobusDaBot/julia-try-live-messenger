import pyshark
import binascii

# Replace with your correct interface
cap = pyshark.LiveCapture(
    interface='\\Device\\NPF_LOOPBACK',
    bpf_filter='port 4000'


)
#tcp portrange 64484-64488
#    'tcp and (host 102.132.99.61)'
#64484
#64485
#64486
#64487
#64488
#ip.src == 10.0.0.115 or ip.dst == 10.0.0.115 
for packet in cap.sniff_continuously(packet_count=20):
    if hasattr(packet.tcp, 'payload'):
        print("------------------------------------------")
        raw_hex = packet.tcp.payload.replace(':', '')  
        raw_bytes = binascii.unhexlify(raw_hex)
        print("Raw data:", raw_bytes)
        try:
            text = raw_bytes.decode("utf-8", errors="ignore")  # or "latin-1" if not UTF-8
            print("String:", text)
        except Exception as e:
            print("Could not decode:", e)