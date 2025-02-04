## mark-freq()

|  Accepted values:|   number \[seconds\]|
|Default:|           1200|

*Description:* An alias for the obsolete mark() option, retained for
compatibility with syslog-ng version 1.6.x.

The number of seconds between two MARK messages. MARK messages are
generated when there was no message traffic to inform the receiver that
the connection is still alive. If set to zero (**0**), no MARK messages
are sent. The mark-freq() can be set for global option and/or every MARK
capable destination driver if mark-mode() is periodical or dst-idle or
host-idle. If mark-freq() is not defined in the destination, then the
mark-freq() will be inherited from the global options. If the
destination uses internal mark-mode(), then the global mark-freq() will
be valid (does not matter what mark-freq() set in the destination side).
