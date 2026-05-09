# trace reference

Useful tshark commands for packet capture analysis.
tshark is the CLI version of Wireshark — same dissectors, same engine, ships with Wireshark.

---

## first pass

```bash
# Protocol hierarchy — what protocols are in the capture and at what volume
tshark -r file.pcap -q -z io,phs,

# Expert info — all warnings and errors flagged automatically by Wireshark dissectors
tshark -r file.pcap -q -z expert,

# Quick capture summary (duration, packet count, file size)
capinfos file.pcap
```

---

## conversations and flows

```bash
# TCP conversations — endpoints, packet counts, bytes, duration
tshark -r file.pcap -q -z conv,tcp

# UDP conversations
tshark -r file.pcap -q -z conv,udp

# All endpoints
tshark -r file.pcap -q -z endpoints,ip
```

---

## TCP issues

```bash
# All TCP analysis flags (retransmissions, resets, zero windows, dup ACKs, etc.)
tshark -r file.pcap -Y "tcp.analysis.flags" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport \
  -e tcp.analysis.flags

# Retransmissions only
tshark -r file.pcap -Y "tcp.analysis.retransmission" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst

# Zero window events
tshark -r file.pcap -Y "tcp.analysis.zero_window" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst

# RST packets
tshark -r file.pcap -Y "tcp.flags.reset == 1" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport

# Retransmission rate over time (1s buckets)
tshark -r file.pcap -q -z io,stat,1,"tcp.analysis.retransmission"
```

---

## latency and RTT

```bash
# TCP RTT per stream
tshark -r file.pcap -q -z io,stat,1,"tcp.analysis.ack_rtt"

# HTTP request/response timing
tshark -r file.pcap -Y "http.request or http.response" \
  -T fields -e frame.time_relative -e ip.src -e ip.dst \
  -e http.request.method -e http.request.uri -e http.response.code
```

---

## DNS

```bash
# All DNS queries and responses
tshark -r file.pcap -Y "dns" \
  -T fields -e frame.time_relative -e ip.src \
  -e dns.qry.name -e dns.qry.type -e dns.flags.response -e dns.flags.rcode

# DNS failures only (non-zero response code)
tshark -r file.pcap -Y "dns.flags.rcode != 0" \
  -T fields -e frame.time_relative -e ip.src \
  -e dns.qry.name -e dns.flags.rcode

# DNS response time
tshark -r file.pcap -q -z dns,tree
```

---

## TLS

```bash
# TLS handshakes
tshark -r file.pcap -Y "tls.handshake" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e tls.handshake.type

# TLS alerts (errors, cert issues, version mismatches)
tshark -r file.pcap -Y "tls.alert_message" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e tls.alert_message.desc
```

---

## MTU and fragmentation

```bash
# ICMP fragmentation needed (PMTUD failures)
tshark -r file.pcap -Y "icmp.type == 3 and icmp.code == 4" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e icmp.mtu

# IP fragments
tshark -r file.pcap -Y "ip.flags.mf == 1 or ip.frag_offset > 0" \
  -T fields -e frame.number -e ip.src -e ip.dst \
  -e ip.flags -e ip.frag_offset
```

---

## GTP / cellular data plane

```bash
# GTP-U traffic
tshark -r file.pcap -Y "gtp" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e gtp.message_type -e gtp.teid

# GTP cause codes
tshark -r file.pcap -Y "gtp.cause" \
  -T fields -e frame.number -e frame.time_relative \
  -e ip.src -e ip.dst -e gtp.cause
```

---

## filtering tips

```bash
# Filter by IP
tshark -r file.pcap -Y "ip.addr == 192.168.1.1"

# Filter by port
tshark -r file.pcap -Y "tcp.port == 443"

# Filter by protocol and IP
tshark -r file.pcap -Y "dns and ip.src == 10.0.0.1"

# Save filtered output to a new pcap
tshark -r file.pcap -Y "tcp.analysis.flags" -w filtered.pcap

# Read only N packets
tshark -r file.pcap -c 100
```

---

## when to use Wireshark GUI instead

- **Follow TCP/UDP stream** — right-click a packet → Follow → TCP Stream
- **I/O graphs** — Statistics → I/O Graph (visualize traffic over time)
- **TCP sequence graphs** — Statistics → TCP Stream Graphs
- **Manual packet inspection** — expanding dissector trees interactively
