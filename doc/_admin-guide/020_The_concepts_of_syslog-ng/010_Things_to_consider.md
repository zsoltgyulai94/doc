---
title: Things to consider when forwarding messages between syslog-ng OSE hosts
id: adm-conc-cons
description: >-
    When you send your log messages from a syslog-ng OSE client through the
    network to a syslog-ng OSE server, you can use different protocols and
    options. Every combination has its advantages and disadvantages. The
    most important thing is to use matching protocols and options, so the
    server handles the incoming log messages properly.
---

In syslog-ng OSE you can change many aspects of the network
communication. First of all, there is the structure of the messages
itself. Currently, syslog-ng OSE supports two standard syslog protocols:
the BSD (RFC3164) and the syslog (RFC5424) message format.

These RFCs describe the format and the structure of the log message, and
add a (lightweight) framing around the messages. You can set this
framing/structure by selecting the appropriate driver in syslog-ng OSE.
There are two drivers you can use: the **network()** driver and the
**syslog()** driver. The syslog() driver is for the syslog (RFC5424)
protocol and the network() driver is for the BSD (RFC3164) protocol.

The tcp() and udp() drivers are now deprecated, they are essentially
equivalent with the network(transport(tcp)) and network(transport(udp))
drivers.

In addition to selecting the driver to use, both drivers allow you to
use different transport-layer protocols: TCP and UDP, and optionally
also higher-level transport protocols: TLS (over TCP. To complicate
things a bit more, you can configure the network() driver (corresponding
to the BSD (RFC3164) protocol) to send the messages in the syslog
(RFC5424) format (but without the framing used in RFC5424) using the
**flag(syslog-protocol)** option.

Because some combination of drivers and options are invalid, you can use
the following drivers and options as sources and as destinations:

1. syslog(transport(tcp))

2. syslog(transport(udp))

3. syslog(transport(rltp))

4. syslog(transport(tls))

5. syslog(transport(rltp(tls-required(yes)))

6. network(transport(tcp))

7. network(transport(udp))

8. network(transport(rltp))

9. network(transport(tls))

10. network(transport(rltp(tls-required(yes)))

11. network(transport(tcp) flag(syslog-protocol))

12. network(transport(udp) flag(syslog-protocol))

13. network(transport(rltp)flag(syslog-protocol))

14. network(transport(tls) flag(syslog-protocol))

15. network(transport(rltp(tls-required(yes)) flag(syslog-protocol))

If you use the same driver and options in the destination of your
syslog-ng OSE client and the source of your syslog-ng OSE server,
everything should work as expected. Unfortunately there are some other
combinations, that seem to work, but result in losing parts of the
messages. The following table shows the combinations:

|Source \\ Destination|   syslog/tcp|   syslog/udp|   syslog/tls|   network/tcp|   network/udp|   network/tls|   network/tcp/flag|   network/udp/flag|   network/tls/flag|
|---|---|---|---|---|---|---|---|---|---|
|syslog/tcp |✔| \-| \-| ! |  \- | \- | ! | \-  | \-|
|syslog/udp |  \- |  ✔|  \-| \-| !|  \-|  \-| !|  \-|
|syslog/tls |\-| \-|  ✔| \-| \-| ! | \-| \-| !|
|network/tcp|\-|\-|\-| ✔| \-|\-| ✔?|\-|\-|
|network/udp|\-|✔?|\-|\-| ✔ | \-|\-| ✔?|\-|
|network/tls|\-|\-|\-|\-|\-|✔|\-|\-|✔?|
|network/tcp/flag|!|\-|\-|!|\-|\-|✔|\-|\-|
|network/udp/flag|\-|!|\-|\-|!|\-|\-|✔|\-|
|network/tls/flag|\-|\-|!|\-|\-|!|\-|\-| ✔|

- \- This method does not work. The logs will not get to the server.

- ✔ This method works.

- ! This method has some visible drawbacks. The logs go through, but
    some of the values are missing / misplaced / and so on.

- ✔? This method seems to work, but it is not recommended because this
    can change in a future release.
