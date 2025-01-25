# Running remote Docker commands with Docker context

A [Docker context](https://docs.docker.com/engine/manage-resources/contexts/) allows me to run Docker commands on my laptop and
have them target the Docker instance running on my media server.
I find this more convenient than having to SSH into the media server.

To [create a Docker context](https://docs.docker.com/engine/manage-resources/contexts/#create-a-new-context):

```sh
$ docker context create media-server --docker "host=ssh://media-server"
```

By using the `ssh` protocol, I'm able to piggyback off the `media-server` definition in my SSH config:

```
Host media-server
  HostName <ip>
  User <user>
```

To select the context I run:

```sh
$ docker context use media-server
```

And there we go, remote Docker commands!
