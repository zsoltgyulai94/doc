---
title: Running a failure script
id: adm-debug-script
description: >-
    You can create a failure script that is executed when syslog-ng OSE
    terminates abnormally, that is, when it exits with a non-zero exit code.
    For example, you can use this script to send an automatic email
    notification.
---

## Prerequisites

The failure script must be the following file:
/opt/syslog-ng/sbin/syslog-ng-failure, and must be executable.

To create a sample failure script, complete the following steps.

## Steps

1. Create a file named /opt/syslog-ng/sbin/syslog-ng-failure with the
    following content:

    ```bash
    #!/usr/bin/env bash
    cat >>/tmp/test.txt <<EOF
    $(date)
    Name............$1
    Chroot dir......$2
    Pid file dir....$3
    Pid file........$4
    Cwd.............$5
    Caps............$6
    Reason..........$7
    Argbuf..........$8
    Restarting......$9

    EOF
    ```

2. Make the file executable: `chmod +x /opt/syslog-ng/sbin/syslog-ng-failure`

3. Run the following command in the /opt/syslog-ng/sbin directory:

    ```bash
    ./syslog-ng --process-mode=safe-background; sleep 0.5; ps aux |
    grep './syslog-ng' | grep -v grep | awk '{print \$2}' | xargs
    kill -KILL; sleep 0.5; cat /tmp/test.txt
    ```

    The command starts syslog-ng OSE in safe-background mode (which is
    needed to use the failure script) and then kills it. You should see
    that the relevant information is written into the /tmp/test.txt
    file, for example:

    ```text
    Thu May 18 12:08:58 UTC 2017
    Name............syslog-ng
    Chroot dir......NULL
    Pid file dir....NULL
    Pid file........NULL
    Cwd.............NULL
    Caps............NULL
    Reason..........signalled
    Argbuf..........9
    Restarting......not-restarting
    ```

4. You should also see messages similar to the following in system
    syslog. The exact message depends on the signal (or the reason why
    syslog-ng OSE stopped):

    >May 18 13:56:09 myhost supervise/syslog-ng[10820]: Daemon exited gracefully, not restarting; exitcode='0'
    >May 18 13:57:01 myhost supervise/syslog-ng[10996]: Daemon exited due to a deadlock/signal/failure, restarting; exitcode='131'
    >May 18 13:57:37 myhost supervise/syslog-ng[11480]: Daemon was killed, not restarting; exitcode='9'

    The failure script should run on every non-zero exit event.
