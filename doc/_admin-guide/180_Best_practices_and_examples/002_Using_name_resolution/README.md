---
title: Using name resolution in syslog-ng
id: adm-pract-nameres
description: >-
    The syslog-ng application can resolve the hostnames of the clients and
    include them in the log messages. However, the performance of syslog-ng
    is severely degraded if the domain name server is unaccessible or slow.
    Therefore, it is not recommended to resolve hostnames in syslog-ng. 
---

If you must use name resolution from syslog-ng, consider the following:

- Use DNS caching. Verify that the DNS cache is large enough to store
    all important hostnames. (By default, the syslog-ng DNS cache stores
    1007 entries.)

    ```config
    options { dns-cache-size(2000); };
    ```

- If the IP addresses of the clients change only rarely, set the
    expiry of the DNS cache large.

    ```config
    options { dns-cache-expire(87600); };
    ```

- If possible, resolve the hostnames locally. For details, see
    [[Resolving hostnames locally]].

**NOTE:** Domain name resolution is important mainly in relay and server
mode.
{: .notice--info}
