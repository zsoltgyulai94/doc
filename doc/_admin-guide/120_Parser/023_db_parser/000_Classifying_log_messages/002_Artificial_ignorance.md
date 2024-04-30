---
title: Artificial ignorance
id: adm-parser-db-ai
description: >-
    Artificial ignorance is a method used to detect anomalies. When applied
    to log analysis, it means that you ignore the regular, common log
    messages --- these are the result of the regular behavior of your
    system, and therefore are not too concerning. However, new messages that
    have not appeared in the logs before can signal important events, and
    should be therefore investigated. \"By definition, something we have
    never seen before is anomalous\" (Marcus J. Ranum).
---

The syslog-ng application can classify messages using a pattern
database: messages that do not match any pattern are classified as
unknown. This provides a way to use artificial ignorance to review your
log messages. You can periodically review the unknown messages ---
syslog-ng can send them to a separate destination, and add patterns for
them to the pattern database. By reviewing and manually classifying the
unknown messages, you can iteratively classify more and more messages,
until only the really anomalous messages show up as unknown.

Obviously, for this to work, a large number of message patterns are
required. The radix-tree matching method used for message classification
is very effective, can be performed very fast, and scales very well.
Basically the time required to perform a pattern matching is independent
from the number of patterns in the database. For sample pattern
databases, see [[Downloading sample pattern databases]].
