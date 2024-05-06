---
title: Jellyfin log source
short_title: Jellyfin
id: adm-src-jfin
description: >-
    In syslog-ng OSE 4.7 and later versions it is possible to use the `jellyfin()` source to read [Jellyfin](https://jellyfin.org/) logs from its log file output.
---

### Example: minimal configuration of jellyfin()

```config
source s_jellyfin {
    jellyfin(
    base-dir("/path/to/my/jellyfin/root/log/dir")
    filename-pattern("log_*.log")
    );
};
```
For more information about Jellyfin logs, see:
* [https://jellyfin.org/docs/general/administration/configuration/#main-configuration](https://jellyfin.org/docs/general/administration/configuration/#main-configuration)
* [https://jellyfin.org/docs/general/administration/configuration/#log-directory](https://jellyfin.org/docs/general/administration/configuration/#log-directory)

Since the `jellyfin()` source is based on the `wildcard-file()` source, the wildcard-file() source options can be used.

The `jellyfin()` driver is a reusable configuration snippet. For details on using or writing configuration snippets, see Reusing configuration blocks. The source of this configuration snippet can be accessed on [GitHub](https://github.com/syslog-ng/syslog-ng/blob/master/scl/jellyfin/jellyfin.conf).
