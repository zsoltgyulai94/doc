---
title: Testing Methodology
toc: true
description: >-
  Only the building and the corresponding unit tests are guaranteed on x86
  macOS. This is a documentation of the tests done on the various sub-components
  of syslog-ng on both the architectures.
---

Syslog-ng is composed of various modules, each with its own set of plugins. Plugins are primarily one of the following types:

* Source Drivers
* Destination Drivers
* Template Functions
* Rewrite Functions
* Parsers

Most of the template functions and rewrite functions are simple text manipulation functions without any external dependencies and are theoretically expected to work without a hunch. However, some of them do have external dependencies (e.g.: python template-function) and thus need to be tested.

Given the variability in the external dependencies and module scope, the modules will be tested in the following classification of priority:&#x20;

* **Priority 1:** Modules such as afsocket, affile etc, which are integral to the basic expected use cases of syslog-ng, need to be tested with utmost priority.\

* **Priority 2:** Modules such as afmongodb, afsql, kafka need to be tested with a high priority as they have external dependencies and can take time to set up and test.\

* **Priority 3:** Modules with no external dependencies, such as the examples module, can be tested once the above two categories are exhausted. This also includes drivers that are reusable configuration snippets configured to send log messages using other drivers. (eg: slack driver)\

* **Priority 4:** Modules with no drivers and basic parsers, such as json-plugin can be tested with the least priority.

