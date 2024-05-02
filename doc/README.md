---
title: Introduction
description:  >-
  Welcome to the syslog-ng documentation center.<br/>
  Here you can browse, search and contribute to most of the syslog-ng documentation.
permalink: /
id: doc-center
---

[![Deploy Jekyll site to Pages](https://github.com/syslog-ng/doc/actions/workflows/jekyll-gh-pages.yml/badge.svg)](https://github.com/syslog-ng/doc/actions/workflows/jekyll-gh-pages.yml)

## {% include markdown_link id="doc-guide" title="Documentation guide" outOfFrame=true %}

If you would like to help us to make our documentation better, here you can find information about {% include markdown_link id="doc-guide" title="how to contribute" outOfFrame=true %}

## {% include markdown_link id="adm-guide" title="Administrator guide" outOfFrame=true %}

If you are an active user of syslog-ng, start here to {% include markdown_link id="adm-guide" title="learn" outOfFrame=true %} about installation, configuration, fine tuning syslog-ng.

## {% include markdown_link id="dev-guide" title="Developer guide" outOfFrame=true %}

Want to add your idea, bug-fix to the fabolous syslog-ng? Take a look at our {% include markdown_link id="dev-guide" title="developer guide" outOfFrame=true %}

## How to contribute to the documentation

 1. If you do not already have a GitHub account, create one.
 2. Fork the repository on GitHub (preferably, from the master branch)
 3. Create a branch that will store your contribution, for example, `git checkout -b my-typo-fixes`
 4. Find the part of the source that you want to modify. The easiest thing is to search for a specific text using grep, regexxer, or a similar tool.
 5. If you modify a file in the `_includes/doc/` directory, it is probably included to multiple parts of the documentation. Make sure that your changes make sense in each context.
 6. Modify the files as you need (following our markup conventions). For example, you can add new examples, correct typos, and so on.
 7. Validate the files to make sure that the `markdown` is well-formed.
 8. Commit and sign off your changes. If your changes apply only to syslog-ng OSE, begin the commit message with the `ose` prefix. If the changes apply only to specific versions, indicate them in the tag, for example, `ose 3.35`
 9. For sizable contributions, attach a signed copy of the syslog-ng Open Source Edition Documentation Individual Contributor License Agreement, or if you do not own the copyright, the syslog-ng Open Source Edition Documentation Entity Contributor License Agreement signed by the copyright owner. Note that for typo fixes, clarifications, configuration examples, and similar smaller contributions, you do not need to sign the Contributor License Agreement.
 10. Push your changes, for example, `git push origin my-typo-fixes`
 11. Submit a pull request.
 12. We will review your contribution and if accepted, integrate to the master branch of the documentation and publish it.

## If you need help

In case you have any question, comment, or feedback, you can:

* we use github to track all of the [[documentation issues|gh-syslog-ng-doc-issue-tracker]]
* post your question on the syslog-ng mailing list

{% include doc/admin-guide/copyright.md %}
