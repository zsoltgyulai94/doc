>![]({{ site.baseurl}}/assets/images/caution.png) **CAUTION:**
>When receiving messages using the UDP protocol, increase the
>size of the UDP receive buffer on the receiver host  
>(that is, the syslog-ng OSE server or relay receiving the messages).  
>  
>Note that on certain platforms, for example, on Red Hat Enterprise
>Linux 5, even low message load (\~200 messages per second) can
>result in message loss, unless the so-rcvbuf() option of the
>source is increased. In this cases, you will need to increase
>the net.core.rmem_max parameter of the host (for example, to
>**1024000**), but do not modify net.core.rmem_default
>parameter.  
>  
>As a general rule, increase the so-rcvbuf() so that the buffer size in kilobytes is
>higher than the rate of incoming messages per second.  
>For example, to receive 2000 messages per second, set the so-rcvbuf()
> at least to **2 097 152** bytes.
{: .notice--warning}
