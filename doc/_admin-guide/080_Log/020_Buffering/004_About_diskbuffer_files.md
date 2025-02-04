---
title: About disk queue files
id: adm-log-diskbuff-about
---

## Normal and reliable queue files

The key difference between disk queue files that employ the
reliable(yes) option and not is the strategy they employ. Reliable disk
queues guarantee that all the messages passing through them are written
to disk first, and removed from the queue only after the destination has
confirmed that the message has been successfully received. This prevents
message loss, for example, due to syslog-ng OSE crashes if the client
and the destination server communicate using the Advanced Log Transport
Protocol (ALTP). Note that the Advanced Log Transport Protocol is
available only in [syslog-ng Premium Edition version 6
LTS](https://syslog-ng.com/log-management-software). Of course, using
the reliable(yes) option introduces a significant performance penalty as
well.

Both reliable and normal disk-buffers employ an in-memory output queue
(set in quot-size()) and an in-memory overflow queue (set in
mem-buf-size() for reliable disk-buffers, or mem-buf-length() for normal
disk-buffers). The difference between reliable and normal disk-buffers
is that when the reliable disk-buffer uses one of its in-memory queues,
it also stores the message on the disk, whereas the normal disk-buffer
stores the message only in memory. The normal disk-buffer only uses the
disk if the in-memory output buffer is filled up completely. This
approach has better performance (due to fewer disk I/O operations), but
also carries the risk of losing a maximum of quot-size() plus
mem-buf-length() number of messages in case of an unexpected power
failure or application crash.

## Size of the queue files

Disk queue files tend to grow. Each may take up to disk-buf-size() bytes
on the disk. Due to the nature of reliable queue files, all the messages
traversing the queue are written to disk, constantly increasing the size
of the queue file.

The disk-buffer file\'s size should be considered as the configured
disk-buf-size() at any point of time, even if it does not have messages
in it. Truncating the disk-buffer file can slow down disk I/O
operations, so syslog-ng OSE does not always truncate the file when it
would be possible (see the truncate-size-ratio() option). If a large
disk-buffer file is not desirable, you should set the disk-buf-size()
option to a smaller value.

![]({{ site.baseurl}}/assets/images/caution.png) **CAUTION:**
One Identity recommends that you do not build upon the current truncating logic
of the disk-buffer files, because syslog-ng OSE might pre-allocate the disk-buffer
files and never truncate them in the future.
{: .notice--warning}

**NOTE:** The disk-buffer file\'s size does not strictly correlate to the
number of stored messages. If you want to get information about the
disk-buffer, use dqtool (for more information, see
[Getting the status information of disk-buffer files]).
{: .notice--info}

**NOTE:** If a queue file becomes corrupt, syslog-ng OSE starts a new one.
This might lead to the queue files consuming more space in total than
their maximal configured size and the number of configured queue files
multiplied together.
{: .notice--info}
