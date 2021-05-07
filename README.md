# FluentD on Docker


This is example project that install [FluentD](https://www.fluentd.org/) in each container and then `sender` container start sending messages to `receiver` host.

## Sender

This is .NET Framework 4.8 application that write timestamps data to `C:\app\log-output.log` file. FluentD configured like this:

```powershell
<source>
  @type tail
  path C:/app/log-output*.log
  pos_file C:/app/log-output-fluentd.pos
  tag GPOSERVERLOG
  read_from_head true
  <parse>
    @type none
  </parse>
</source>


<match **>
  @type forward
  send_timeout 60s
  recover_wait 1s
  hard_timeout 60s
  ignore_network_errors_at_startup true
  tls_insecure_mode true
  keepalive true

  <server>
    host $hostname
    port 24222
  </server>
</match>
```

So actually any change in this file will be send to `$hostname` port `24222`


## Receiver

This is .NET Framework 4.8 application that do nothing - just waiting. All the work is actually done by FluentD

FluentD configured like this:

```powershell
<source>
    @type forward
    port 24222
    bind 0.0.0.0
    tag gposerver.log
</source>

<match **>
    @type file
    path C:\FluentDLog
</match>
```

Anything that send to this host and port `24222` will be saved to file in `C:\FluentDLog` folder.

## Run

This application was created with Visual Studio 2019 with default settings. All you have to do is to select `docker-compose` as run target and then `F5` and viola - it's running.

