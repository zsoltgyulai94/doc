## spoof-source()

|  Type:|      yes or no|
  |Default:|   no|

*Description:* Enables source address spoofing. This means that the host
running syslog-ng generates UDP packets with the source IP address
matching the original sender of the message. It is useful when you want
to perform some kind of preprocessing using syslog-ng then forward
messages to your central log management solution with the source address
of the original sender. This option only works for UDP destinations
though the original message can be received by TCP as well. This option
is only available if syslog-ng was compiled using the
--enable-spoof-source configuration option.

The maximum size of spoofed datagrams in udp() destinations is set to
1024 bytes by default. To change the maximum size, use the
spoof-source-max-msglen() option.

**NOTE:** Anything above the size of the maximum transmission unit (MTU),
which is 1500 bytes by default, is not recommended because of
fragmentation.
{: .notice--info}

The maximum datagram in IP protocols (both IPv4 and IPv6) is 65535 bytes
including the IP and UDP headers. The minimum size of the IPv4 header is
20 bytes, the IPv6 is 40 bytes, and the UDP is 8 bytes.
