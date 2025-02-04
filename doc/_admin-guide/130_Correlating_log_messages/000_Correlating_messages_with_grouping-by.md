---
title: Correlating messages using the grouping-by() parser
id: adm-cor-grouping-by
description: >-
    The syslog-ng OSE application can correlate log messages that match a
    set of filters. This works similarly to SQL GROUP BY statements.
    Alternatively, you can also correlate log messages using pattern
    databases. For details, see Correlating log messages using pattern databases.
---

Log messages are supposed to describe events, but applications often
separate information about a single event into different log messages.
For example, the Postfix email server logs the sender and recipient
addresses into separate log messages, or in case of an unsuccessful
login attempt, the OpenSSH server sends a log message about the
authentication failure, and the reason of the failure in the next
message. Of course, messages that are not so directly related can be
correlated as well, for example, login-logout messages, and so on.

To correlate log messages with syslog-ng OSE, you can add messages into
message-groups called contexts. A context consists of a series of log
messages that are related to each other in some way, for example, the
log messages of an SSH session can belong to the same context. As new
messages come in, they may be added to a context. Also, when an incoming
message is identified it can trigger actions to be performed, for
example, generate a new message that contains all the important
information that was stored previously in the context.

## How the grouping-by() parser works

![]({{ adm_img_folder | append: 'fig-grouping-by-parser-works.png' }})

The grouping-by() parser has three options that determine if a message
is added to a context: scope(), key(), and where().

- The scope() option acts as an early filter, selecting messages sent
    by the same process (\${HOST}\${PROGRAM}\${PID} is identical),
    application (\${HOST}\${PROGRAM} is identical), or host.

- The key() identifies the context the message belongs to. (The value
    of the key must be the same for every message of the context.)

- To use a filter to further limit the messages that are added to the
    context, you can use the **where()** option.

The timeout() option determines how long a context is stored, that is,
how long syslog-ng OSE waits for related messages to arrive. If the
group has a specific log message that ends the context (for example, a
logout message), you can specify it using the **trigger()** option.

When the context is closed, and the messages match the filter set in the
having() option (or the having() option is not set), syslog-ng OSE
generates and sends the message set in the aggregate() option.

**NOTE:** Message contexts are persistent and are not lost when syslog-ng
OSE is reloaded (SIGHUP), but are lost when syslog-ng OSE is restarted.
{: .notice--info}

**Declaration**

```config
parser parser_name {
    grouping-by(
        key()
        having()
        aggregate()
        timeout()
    );
};
```

For the parser to work, you must set at least the following options:
key(), aggregate(), and timeout().

Note the following points about timeout values:

- When a new message is added to a context, syslog-ng OSE will restart
    the timeout using the context-timeout set for the new message.

- When calculating if the timeout has already expired or not,
    syslog-ng OSE uses the timestamps of the incoming messages, not
    system time elapsed between receiving the two messages (unless the
    messages do not include a timestamp, or the **keep-timestamp(no)**
    option is set). That way syslog-ng OSE can be used to process and
    correlate already existing log messages offline. However, the
    timestamps of the messages must be in chronological order (that is,
    a new message cannot be older than the one already processed), and
    if a message is newer than the current system time (that is, it
    seems to be coming from the future), syslog-ng OSE will replace its
    timestamp with the current system time.

    Example: How syslog-ng OSE calculates context-timeout

    Consider the following two messages:

    ><38>1990-01-01T14:45:25 customhostname program6[1234]: program6 testmessage
    ><38>1990-01-01T14:46:25 customhostname program6[1234]: program6 testmessage

    If the context-timeout is 10 seconds and syslog-ng OSE receives the
    messages within 1 second, the timeout event will occour immediately,
    because the difference of the two timestamp (60 seconds) is larger
    than the timeout value (10 seconds).

- Avoid using unnecessarily long timeout values on high-traffic
    systems, as storing the contexts for many messages can require
    considerable memory. For example, if two related messages usually
    arrive within seconds, it is not needed to set the timeout to
    several hours.

### Example: Correlating Linux Audit logs

Linux audit logs tend to be broken into several log messages (generated
as a list of lines). Usually, the related lines are close to each other
in time, but multiple events can be logged at around the same time,
which get mixed up in the output. The example below is the audit log for
running ntpdate:

>type=SYSCALL msg=audit(1440927434.124:40347): arch=c000003e syscall=59 success=yes exit=0 a0=7f121cef0b88 a1=7f121cef0c00 a2=7f121e690d98 a3=2 items=2 ppid=4312 pid=4347 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="ntpdate" exe="/usr/sbin/ntpdate" key=(null)
>type=EXECVE msg=audit(1440927434.124:40347): argc=3 a0="/usr/sbin/ntpdate" a1="-s" a2="ntp.ubuntu.com"
>type=CWD msg=audit(1440927434.124:40347):  cwd="/"
>type=PATH msg=audit(1440927434.124:40347): item=0 name="/usr/sbin/ntpdate" inode=2006003 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL
>type=PATH msg=audit(1440927434.124:40347): item=1 name="/lib64/ld-linux-x86-64.so.2" inode=5243184 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL
>type=PROCTITLE msg=audit(1440927434.124:40347): proctitle=2F62696E2F7368002F7573722F7362696E2F6E7470646174652D64656269616E002D73

These lines are connected by their second field:
`msg=audit(1440927434.124:40347)`. You can parse such messages using the
[[Linux audit parser]] of syslog-ng OSE, and then
use the parsed .auditd.msg field to group the messages.

```config
parser auditd_groupingby {
    grouping-by(
        key("${.auditd.msg}")
        aggregate(
            value("MESSAGE" "$(format-json .auditd.*)")
        )
        timeout(10)
    );
};
```

For another example, see [The grouping-by() parser in syslog-ng blog
post](https://www.syslog-ng.com/community/b/blog/posts/the-grouping-by-parser-in-syslog-ng-3-8)
