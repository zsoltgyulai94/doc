---
title: Setting the facility field with the set-facility() rewrite function
short_title: Setting facility
id: adm-temp-facility
description: >-
  It is possible to set the facility field with the set-facility() rewrite
  function. When set, the set-facility() rewrite function will only
  rewrite the $PRIORITY field in the message to the first parameter value
  specified in the function.
---

{% include doc/admin-guide/notes/not-valid-param.md %}

**Declaration**

```config
log {
  source { system(); };
    if (program("postfix")) {
      rewrite { set-facility("mail"); };
    };
    destination { file("/var/log/mail.log"); };
    flags(flow-control);
};
```

## Parameters

The set-facility() rewrite function has a single, mandatory parameter
that can be defined as follows:

```config
set-facility( "parameter1" );
```

## Accepted values

The set-facility() rewrite function accepts the following values:

- numeric strings: \[0-7\]

- named values: emerg, emergency, panic, alert, crit, critical, err,
    error, warning, warn, notice, info, informational, debug

### Example usage for the set-facility() rewrite function

The following example can be used in production for the set-facility()
rewrite function.

```config
rewrite {
set-facility("info");
set-facility("6");
set-facility("${.json.severity}");};
```
