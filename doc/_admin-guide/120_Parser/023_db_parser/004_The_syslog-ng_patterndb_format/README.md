---
title: The syslog-ng pattern database format
id: adm-parser-db-patterndb-format
description: >-
    Pattern databases are XML files that contain rules describing the
    message patterns. For sample pattern databases, see Downloading sample pattern databases.
    The following scheme describes the V5 format of the pattern database.
    This format is backwards-compatible with the earlier formats.
---

For a sample database containing only a single pattern, see Example: A
pattern database containing a single rule.

**TIP:** Use the **pdbtool** utility that is bundled with syslog-ng to test
message patterns and convert existing databases to the latest format.
For details, see [[The pdbtool manual page]].
To automatically create an initial pattern database from an existing log
file, use the **pdbtool patternize** command. For details, see
[[The pdbtool manual page]].
{: .notice--info}

## Example: A pattern database containing a single rule

The following pattern database contains a single rule that matches a log
message of the ssh application. A sample log message looks like:

>Accepted password for sampleuser from 10.50.0.247 port 42156 ssh2

The following is a simple pattern database containing a matching rule.

```xml
<patterndb version='5' pub_date='2010-10-17'>
    <ruleset name='ssh' id='123456678'>
        <pattern>ssh</pattern>
            <rules>
                <rule provider='me' id='182437592347598' class='system'>
                    <patterns>
                        <pattern>Accepted @QSTRING:SSH.AUTH_METHOD: @ for@QSTRING:SSH_USERNAME: @from\ @QSTRING:SSH_CLIENT_ADDRESS: @port @NUMBER:SSH_PORT_NUMBER:@ ssh2</pattern>
                    </patterns>
                </rule>
            </rules>
    </ruleset>
</patterndb>
```

Note that the rule uses macros that refer to parts of the message, for
example, you can use the **\${SSH\_USERNAME}** macro refer to the
username used in the connection.

The following is the same example, but with a test message and test
values for the parsers.

```xml
<patterndb version='4' pub_date='2010-10-17'>
    <ruleset name='ssh' id='123456678'>
        <pattern>ssh</pattern>
            <rules>
                <rule provider='me' id='182437592347598' class='system'>
                    <patterns>
                        <pattern>Accepted @QSTRING:SSH.AUTH_METHOD: @ for@QSTRING:SSH_USERNAME: @from\ @QSTRING:SSH_CLIENT_ADDRESS: @port @NUMBER:SSH_PORT_NUMBER:@ ssh2</pattern>
                    </patterns>
                    <examples>
                        <example>
                            <test_message>Accepted password for sampleuser from 10.50.0.247 port 42156 ssh2</test_message>
                            <test_values>
                                <test_value name="SSH.AUTH_METHOD">password</test_value>
                                <test_value name="SSH_USERNAME">sampleuser</test_value>
                                <test_value name="SSH_CLIENT_ADDRESS">10.50.0.247</test_value>
                                <test_value name="SSH_PORT_NUMBER">42156</test_value>
                            </test_values>
                        </example>
                    </examples>
                </rule>
            </rules>
    </ruleset>
</patterndb>
```
