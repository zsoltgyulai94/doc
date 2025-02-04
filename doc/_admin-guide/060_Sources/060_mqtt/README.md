---
title: 'mqtt: Receiving messages from an MQTT broker'
short_title: mqtt
id: adm-src-mqtt
description: >-
    From syslog-ng OSE version 3.35, you can use the mqtt() source to fetch
    messages from MQTT brokers.
---

The mqtt() source builds on the [MQTT
protocol](https://www.hivemq.com/mqtt/mqtt-protocol/), and uses its
[client](https://www.hivemq.com/blog/seven-best-mqtt-client-tools/) and
[broker](https://www.hivemq.com/hivemq/mqtt-broker/) entities.

**NOTE:** The rest of this chapter and its sections build on your
familiarity with the MQTT protocol, the concept of client and broker
entities, and how these entities function within an MQTT system.
{: .notice--warning}

**Declaration**

```config
source s_mqtt{
    mqtt(
        address("tcp://<hostname>:<port-number>")
        topic("<topic-name>")
    );
};
```

### Example: Using the mqtt() source in your configuration

The following example illustrates an mqtt() source configured to fetch
messages from the MQTT broker running on **localhost:4444** using the
**test/test topic**, and send them to the **localhost:4445** address.

```config
    @version: 3.35
    @include "scl.conf"
    source s_mqtt {
        mqtt(
            address("tcp://localhost:4444")
            topic("test/test")
        );
    };
    destination d_network {
        network(
            "localhost"
            port(4445)
        );
    };
    log {
        source(s_mqtt);
        destination(d_network);;
    };
```
