>**TIP:** To format multi-line messages to your individual needs, consider
>the following:
>  
>- To make multi-line messages more readable when written to a file,
>    use a template in the destination and instead of the \${MESSAGE}
>    macro, use the following: **$(indent-multi-line ${MESSAGE})**.
>    This expression inserts a tab after every newline character (except
>    when a tab is already present), indenting every line of the message
>    after the first. For example:
>
>    ```config
>    destination d_file {
>        file ("/var/log/messages"
>            template("${ISODATE} ${HOST} $(indent-multi-line ${MESSAGE})\n")
>        );
>    };
>    ```
>  
{: .notice--info}

For details on using templates, see [[Templates and macros]].

- To actually convert the lines of multi-line messages to single line
    (by replacing the newline characters with whitespaces), use the
    **flags(no-multi-line)** option in the source.
