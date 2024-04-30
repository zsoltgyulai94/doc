---
title: 'Example use case: using the $DESTIP, the $DESTPORT, and the $PROTO macros'
short_title: Example use case
id: adm-temp-example
---

This section describes scenarios when One Identity recommends using the
\$DESTIP, the \$DESTPORT, and the \$PROTO macros.

Using the \$DESTIP, the \$DESTPORT, and the \$PROTO macros is relevant
when multiple sources are configured to receive messages on the
syslog-ng OSE side. In this case, the hostname and IP address on the
sender\'s side and the syslog-ng OSE side is the same, and at a later
point in the pipeline, syslog-ng OSE can not by default specify which
source received the message. The \$DESTIP, the \$DESTPORT, and the
\$PROTO macros solve this issue by specifying the local IP address and
local port of the original message source, and the protocol used on the
original message source on the syslog-ng OSE side.

## When to use the \$DESTIP, the \$DESTPORT, and the \$PROTO macros

One Identity recommends using the \$DESTIP, the \$DESTPORT, and the
\$PROTO macros in either of the following scenarios:

- Your appliance sends out log messages through both UDP and TCP.

- The format of the UDP log messages and the TCP log messages is
    different, and instead of using complex filters, you want to capture
    either of them, preferably with the simplest possible filter.

- The IP addresses on the sender\'s side and the syslog-ng OSE side
    are the same, therefore the netmask() option doesn\'t work in your
    configuration.

- The hostnames on the sender\'s side and the syslog-ng OSE side are
    the same, therefore the host() option doesn\'t work in your
    configuration.

## Macros: \$DESTIP, \$DESTPORT, and \$PROTO

To solve either of the challenges listed previously, syslog-ng Open
Source Edition (syslog-ng OSE) supports the following macros that you
can include in your configuration:

- $DESTIP

- $DESTPORT

- $PROTO

## Configuration and output

The following configuration example illustrates how you can use the
\$DESTIP, the \$DESTPORT, and the \$PROTO macros in your syslog-ng OSE
configuration.

### Example: using the \$DESTIP, the \$DESTPORT, and the \$PROTO macros in your configuration

The \$DESTIP, the \$DESTPORT, and the \$PROTO macros in your syslog-ng
OSE configuration:

```config
log{ 
  source{ 
    network(localip(10.12.15.215) port(5555) transport(udp)); 
  };

destination { 
  file("/dev/stdout" template("destip=$DESTIP destport=$DESTPORT proto=$PROTO\n"));
  };
};
```

With these configuration settings, the macros will specify the local IP,
the local port, and the protocol information of the source from which
the message originates as follows:

```config
destip=10.12.15.215 destport=5555 proto=17
```
