---
title: Global and environmental variables
id: adm-conf-global
description: >-
    You can define global variables in the configuration file. Global
    variables are actually name-value pairs. When syslog-ng processes the
    configuration file during startup, it automatically replaces name
    with value. 
---

To define a global variable, use the following syntax:

```config
@define name "value"
```

The value can be any string, but special characters must be escaped (for
details, see [[Regular expressions]]).  
To use the variable, insert the name of the variable enclosed between backticks
(like, `` `global-variable` ``, similarly to using variables in Linux or UNIX shells) anywhere in
the configuration file. If backticks are meant literally, repeat the
backticks to escape them. For example, ```` ``not-substituted-value`` ````.

The value of the global variable can be also specified using the
following methods:

- Without any quotes, as long as the value does not contain any spaces
    or special characters. In other words, it contains only the
    following characters: a-zA-Z0-9_..

- Between apostrophes, in case the value does not contain apostrophes.

- Between double quotes, in which case special characters must be
    escaped using backslashes (\).

**TIP:** The environmental variables of the host are automatically imported
and can be used as global variables.
{: .notice--info}

In syslog-ng OSE 3.24 and later, the location of the syslog-ng
configuration file is available as the `syslog-ng-sysconfdir`
variable.

## Example: Using global variables

For example, if an application is creating multiple log files in a
directory, you can store the path in a global variable, and use it in
your source definitions.

```config
@define mypath "/opt/myapp/logs"

source s_myapp_1 {
    file("`mypath`/access.log" follow-freq(1));
};

source s_myapp_2 {
    file("`mypath`/error.log" follow-freq(1));
};

source s_myapp_3 {
    file("`mypath`/debug.log" follow-freq(1));
};
```

The syslog-ng OSE application will interpret this as:

```config
@define mypath "/opt/myapp/logs"

source s_myapp_1 {
    file("/opt/myapp/logs/access.log" follow-freq(1));
};

source s_myapp_2 {
    file("/opt/myapp/logs/error.log" follow-freq(1));
};

source s_myapp_3 {
    file("/opt/myapp/logs/debug.log" follow-freq(1));
};
```
