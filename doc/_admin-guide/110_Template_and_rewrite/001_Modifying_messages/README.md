---
title: Modifying messages using rewrite rules
id: adm-temp-rewrite
description: >-
    The syslog-ng application can rewrite parts of the messages using
    rewrite rules. Rewrite rules are global objects similar to parsers and
    filters and can be used in log paths. The syslog-ng application has two
    methods to rewrite parts of the log messages: substituting (setting) a
    part of the message to a fix value, and a general search-and-replace
    mode.
---

- Substitution completely replaces a specific part of the message that
    is referenced using a built-in or user-defined macro.

- General rewriting searches for a string in the entire message (or
    only a part of the message specified by a macro) and replaces it
    with another string. Optionally, this replacement string can be a
    template that contains macros.

Rewriting messages is often used in conjunction with message parsing
[[parser: Parse and segment structured messages]].

Rewrite rules are similar to filters: they must be defined in the
syslog-ng configuration file and used in the log statement. You can also
define the rewrite rule inline in the log path.

{% include doc/admin-guide/notes/parser-order.md %}
