---
title: GSOC - Project Report
description: >-
  This testing effort was part of a Google Summer Of Code project, the details
  of which will be outlined here.
permalink: /developer-guide/chapter_4/macos-testing-status/
toc: true
---

### **Project**

MacOS, as of 2021, is not officially supported by syslog-ng. Currently, only the building and the corresponding unit tests are guaranteed on MacOS (x86 architecture) with some minor changes to the config file. However, what makes syslog-ng a better alternative is the abundance of sources/destinations and the rich filtering capabilities.

These, unfortunately, don't have any guarantee of working as extensive testing is still pending. Moreover, Apple has also introduced their in-house Apple Silicon laptops with ARM architecture, and no tests have been done on this system whatsoever.

This project aims to test and document the current status of syslog-ng on MacOS and, if possible, provide fixes for the same. This project seeks to extensively test multiple modules with their various plugins on both the macOS architectures. For all the plugins tested, reproducible tests and documentation will be maintained and a root cause analysis provided if a plugin fails to function.

### Work Done

The work done in this project is being tracked on the [Testing Status](testing-status.md) page. As of the GSOC final submission, over 35 drivers have been tested, from writing the tests to documenting the results and errors faced. \
\
Apart from this, I have also worked with my Mentor to discuss various solutions to the problems we faced with drivers that didn't function as expected. One example can be the system() source driver which did not support macOS. We discussed the possible solutions, researched the options and consequently I pushed a [pull request](https://github.com/syslog-ng/syslog-ng/pull/3710) for the same.&#x20;

### Highlights

GSOC has given me a plethora of different experiences, from learning how to interact with a dev team to building professional connections online. Having had contributed to open source before however, my favourite part of participating in GSOC this year is most definitely my interactions with the team at syslog-ng, in particular, my mentor. Never before have I met a team that is so friendly and helpful, oftentimes going beyond what is expected of the devs when it comes to troubleshooting.

My mentor, Mr Attila Szakacs in particular has been immensely helpful throughout the process. From helping perfect my proposal during the contribution phase to oftentimes being online and troubleshooting a problem with me instead of simply pointing me somewhere else. Since the problem I am covering is a broad one, he has also given me the freedom to explore in any direction whilst also keeping a constant check which is very comforting.

### Challenges

This project was very broad ended in its scope. Testing a driver required me to learn about the dependencies of that driver so I could write a test code for the same. This meant, throughout the project I have had to learn various technologies such as Elasticsearch, Riemann, Redis etc. \
\
When a particular driver or process did not work, the root cause analysis would often point to a chain of issues and getting to the root of it all wasn't always easy. We also extensively discussed the solution space for such drivers which often required a lot research.&#x20;
