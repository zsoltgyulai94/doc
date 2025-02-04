---
title: Including configuration files
id: adm-conf-incl
description: >-
    The syslog-ng application supports including external files in its
    configuration file, so parts of its configuration can be managed
    separately. 
---

To include the contents of a file in the syslog-ng
configuration, use the following syntax:

```config
@include "<filename>"
```

This imports the entire file into the configuration of syslog-ng OSE, at
the location of the include statement. The `<filename>` can be one of
the following:

- A filename, optionally with full path. The filename (not the path)
    can include UNIX-style wildcard characters (*, ?). When using
    wildcard characters, syslog-ng OSE will include every matching file.
    For details on using wildcard characters, see Options of regular
    expressions.

- A directory. When including a directory, syslog-ng OSE will try to
    include every file from the directory, except files beginning with a
    ~ (tilde) or a . (dot) character. Including a directory is not
    recursive. The files are included in alphabetic order, first files
    beginning with uppercase characters, then files beginning with
    lowercase characters. For example, if the directory contains the
    a.conf, B. conf, c.conf, D.conf files, they will be included in the
    following order: B.conf, D. conf, a.conf, c.conf.

## When including configuration files, consider the following points

- The default path where syslog-ng OSE looks for the file depends on
    where syslog-ng OSE is installed. The `syslog-ng --version` command
    displays this path as **Include-Path**.

- Defining an object twice is not allowed, unless you use the @define
    allow-config-dups 1 definition in the configuration file. If an
    object is defined twice (for example, the original syslog-ng
    configuration file and the file imported into this configuration
    file both define the same option, source, or other object), then the
    object that is defined later in the configuration file will be
    effective. For example, if you set a global option at the beginning
    of the configuration file, and later include a file that defines the
    same option with a different value, then the option defined in the
    imported file will be used.

- Files can be embedded into each other: the included files can
    contain include statements as well, up to a maximum depth of 15
    levels.

- You cannot include complete configuration files into each other,
    only configuration snippets can be included. This means that the
    included file cannot have a @version statement.

- Include statements can only be used at top level of the
    configuration file. For example, the following is correct:

    ```config
    @version: 3.38
    @include "example.conf"
    ```

    But the following is not:

    ```config
    source s_example {
        @include "example.conf"
    };
    ```

    ![]({{ site.baseurl}}/assets/images/caution.png)
     **CAUTION:** The syslog-ng application will not start if it cannot find a
     file that is to be included in its configuration. Always double-check the
     filenames, paths, and access rights when including configuration files,
     and use the **--syntax-only** command-line option to check your configuration.
     {: .notice--warning}
