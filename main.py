import pyshark
import time
import binascii

cap = pyshark.LiveCapture(
    interface='\\Device\\NPF_{944C406E-D19F-4563-AD09-D6F1E66B5853}',
    bpf_filter='tcp and (host 102.132.99.61)'

)
for packet in cap.sniff_continuously(packet_count=30):  # adjust packet_count or remove for continuous
    try:
        timestamp = packet.sniff_time  # capture timestamp
        length = packet.length         # packet length in bytes
        src = packet.ip.src
        dst = packet.ip.dst
        proto = packet.transport_layer

        # Get raw payload if TCP layer exists
        payload_hex = ''
        payload_bytes = b''
        if hasattr(packet, 'tcp') and hasattr(packet.tcp, 'payload'):
            payload_hex = packet.tcp.payload.replace(':', '')
            payload_bytes = binascii.unhexlify(payload_hex)

        # Print metadata + payload in hex
        print(f"[{timestamp}] {src} -> {dst} | {proto} | Length: {length}")
        print(f"Payload (hex): {payload_hex}")
        print(f"Payload (bytes): {payload_bytes}\n")

    except AttributeError:
        # Skip packets without IP/TCP layer
        continue
