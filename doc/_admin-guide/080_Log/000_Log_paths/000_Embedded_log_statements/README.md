---
title: Embedded log statements
id: adm-log-emb-log
description: >-
    Starting from version 3.0, syslog-ng can handle embedded log statements
    (also called log pipes). Embedded log statements are useful for creating
    complex, multi-level log paths with several destinations and use
    filters, parsers, and rewrite rules.
---

For example, if you want to filter your incoming messages based on the
facility parameter, and then use further filters to send messages
arriving from different hosts to different destinations, you would use
embedded log statements.

## Figure 12: Embedded log statement

![]({{ adm_img_folder | append: 'fig-syslog-ng-embedded-log-statement-2.png' }})

Embedded log statements include sources --- and usually filters,
parsers, rewrite rules, or destinations --- and other log statements
that can include filters, parsers, rewrite rules, and destinations. The
following rules apply to embedded log statements:

- Only the beginning (also called top-level) log statement can include
    sources.

- Embedded log statements can include multiple log statements on the
    same level (that is, a top-level log statement can include two or
    more log statements).

- Embedded log statements can include several levels of log statements
    (that is, a top-level log statement can include a log statement that
    includes another log statement, and so on).

- After an embedded log statement, you can write either another log
    statement, or the flags() option of the original log statement. You
    cannot use filters or other configuration objects. This also means
    that flags (except for the flow-control flag) apply to the entire
    log statement, you cannot use them only for the embedded log
    statement.

- Embedded log statements that are on the same level receive the same
    messages from the higher-level log statement. For example, if the
    top-level log statement includes a filter, the lower-level log
    statements receive only the messages that pass the filter.

## Figure 13: Embedded log statements

![]({{ adm_img_folder | append: 'fig-syslog-ng-embedded-log-statement.png' }})

Embedded log filters can be used to optimize the processing of log
messages, for example, to re-use the results of filtering and rewriting
operations.
