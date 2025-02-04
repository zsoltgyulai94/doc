---
title: Fortigate parser
id: adm-parser-fortigate
description: >-
    The Fortigate parser can parse the log messages of FortiGate/FortiOS
    (Fortigate Next-Generation Firewall (NGFW)).  
---

{% include doc/admin-guide/parser-intro.md %}

The parser can parse messages in the following format:

>\<PRI\>\<NAME=VALUE PAIRS\>

For example:

><189>date=2021-01-15 time=12:58:59 devname="FORTI_111" devid="FG100D3G12801312" logid="0001000014" type="traffic" subtype="local" level="notice" vd="root" eventtime=1610704739683510055 tz="+0300" srcip=91.234.154.139 srcname="91.234.154.139" srcport=45295 srcintf="wan1" srcintfrole="wan" dstip=213.59.243.9 dstname="213.59.243.9" dstport=46730 dstintf="unknown0" dstintfrole="undefined" sessionid=2364413215 proto=17 action="deny" policyid=0 policytype="local-in-policy" service="udp/46730" dstcountry="Russian Federation" srccountry="Russian Federation" trandisp="noop" app="udp/46730" duration=0 sentbyte=0 rcvdbyte=0 sentpkt=0 appcat="unscanned" crscore=5 craction=262144 crlevel="low"

If you find a message that the fortigate-parser() cannot properly parse,
[contact Support](https://www.syslog-ng.com/support/), so we can improve
the parser.

By default, the Fortigate-specific fields are extracted into name-value
pairs prefixed with .fortigate. For example, the devname in the previous
message becomes \${.fortigate.devname}. You can change the prefix using
the prefix option of the parser.

**Declaration**

```config
@version: 3.38
@include "scl.conf"
log {
    source { network(transport("udp") flags(no-parse)); };
    parser { fortigate-parser(); };
    destination { ... };
};
```

Note that you have to disable message parsing in the source using the
**flags(no-parse)** option for the parser to work.

The fortigate-parser() is actually a reusable configuration snippet
configured to parse Fortigate messages. For details on using or writing
such configuration snippets, see [[Reusing configuration blocks]].
You can find the source of this configuration snippet on
[GitHub](https://github.com/syslog-ng/syslog-ng/blob/master/scl/websense/plugin.conf).
