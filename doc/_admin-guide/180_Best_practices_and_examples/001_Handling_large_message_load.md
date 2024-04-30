---
title: Handling large message load
id: adm-pract-large-load
description: >-
    This section provides tips on optimizing the performance of syslog-ng.
    Optimizing the performance is important for syslog-ng hosts that handle
    large traffic.
---

- Disable DNS resolution, or resolve hostnames locally. For details,
    see [[Using name resolution in syslog-ng]].
- Enable flow-control for the TCP sources. For details, see
    [[Managing incoming and outgoing messages with flow-control]].

- Do not use the usertty() destination driver. Under heavy load, the
    users are not be able to read the messages from the console, and it
    slows down syslog-ng.

- Do not use regular expressions in our filters. Evaluating general
    regular expressions puts a high load on the CPU. Use simple filter
    functions and logical operators instead. For details, see
    [[Regular expressions]].

{% include doc/admin-guide/warnings/udp-buffer.md %}

- Increase the value of the flush-lines() parameter. Increasing
    flush-lines() from 0 to **100** can increase the performance of
    syslog-ng OSE by 100%.
