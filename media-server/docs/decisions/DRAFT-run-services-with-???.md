## Problem

I need a way to run services that provides:

- Network isolation: only accessible through a reverse-proxy
- Version-controlled, declarative configuration: self-documenting and reproducible installation and configuration,
  simple and complete uninstallation.
- Secure: vulnerabilities in the service can't be used to compromise the rest of the system.
- Performant: may as well consider it, but good enough is fine.

- Per-service network isolation to avoid port conflicts and ensure services are only exposed
I need to choose a way to run services.
I want:

- Network isolation per service.
- User namespacing, ideally without root mapped to the host root.
- Declarative, reproducible way to run.
- Virtualization

## Options

- OCI containers
- VMs
- systemd services
- systemd-nspawn containers

## Decision

## Exploration

I currently run services using OCI containers.
This provides benefits I appreciate:

- I generally don't need to know hor a service is installed.
  Installation details are handled for me in the container image,
  and I can concentrate on post-installation configuration.
- I can extend existing images, , I can use it as a base for a custom image and add the additional functionality I need.
- Service installations are isolated to the container.
  This avoids dependency conflicts between services and makes uninstalling a service and its dependencies as simple as deleting the container.
- Private network per container
- Virtualized resources including networking ports and filesystems,
  giving flexibility to move data around without needing to reconfigure the service.
- The isolated installation, reproducable builds, and resource virtualization let me work with services as immutable units.
  Instead of updating a service in place, I replace its container with a new one that has the new version of the service.
  The state of the service remains well-known.
  It prevents build-up of old or stale cached files.
  There is peace of mind from knowing that if container disappeared, I could get a new one going in a few minutes.
- Docker provides DNS that lets containers contact each other using their pod names.
- Provides process and network isolation.
  This helps restrict the damage if a service is compromised.

There are also downsides.

- Additional complexity. Running services in containers adds at least one layer of abstraction. This can makes configuration and debugging more difficult. I have gotten comfortable working with these extra layers.
- There is a small performance cost to running services in containers. I have not noticed any issues.

I have several years of experience installing and running services using Docker containers.
I have little experience installing and managing services on bare metal.
I have no experience installing and managing services in virtual machines.

I could also run containers using Podman, Nomad, or Kubernetes (this is maybe better put in the ADR for using Docker Compose).
I could also run services on bare metal or in virtual machines.

Docker is working well enough right now.

---

Docker images capture installation in a Dockerfile that can be version-controlled.
This is an executable record of how the service was installed,
which can be used in the future to debug or re-create a service.

Containers provide a form of resource virtualization.
The resources seen inside the container are virtual resources mapped to physical resources on the host by the container engine.
This provides an abstraction layer that decouples host resources from the service running inside the container,
allowing resource configuration to be changed without needing to update service configuration.
The host port used by a web application container can be changed, for example, while the port used by the service inside the container remains unchanged.
This makes it easier to change configuration related to resources.

It also gives control over the host resources used by the application even when the application doesn't support it. For example an application that doesn't have a configurable port can be assigned any host port using virtualization.

The virtualized environment can be destroyed to completely uninstall a service,
without concern for lingering dependencies or cached files.
Using virtualized environments will also improve security,
as a compromised service will have limited access to other services.

Virtualization and configuration-as-code together will let me treat services as immutable.

## Decision

I will run services in Docker containers.

## Consequences

Immutable infrastructure.

## Related resources

https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Environment
https://medium.com/@sebastiancarlos/systemds-nuts-and-bolts-0ae7995e45d3
https://systemd.io/CREDENTIALS/
> Use LoadCredential=, LoadCredentialEncrypted= or SetCredentialEncrypted= (see below) to pass data to unit processes securely.

https://quantum5.ca/2025/03/18/docker-considered-harmful/

https://mwalkowski.com/post/introduction-to-systemd-nspawn-containers-chroot-on-steroids/
https://www.reddit.com/r/NixOS/comments/1ajfl8c/nixoscontainer_vs_docker_and_friends/
https://www.xda-developers.com/nixos-containers-are-pretty-exciting/

https://github.com/microvm-nix/microvm.nix

---
