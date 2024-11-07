# 2. Run services in Docker containers

Date: 2023-11-28

## Status

Accepted

## Context

I am currently running services in Docker containers.
This provides benefits I appreciate.

- I generally don't need to know how a service is installed. Installation details are handled for me in the Docker image. I can concentrate on post-installation configuration.
- Dockerfiles provide a self-documenting, reproducible, and version-controlled installation procedure. If I ever do need to understand how a service is installed, looking at the Dockerfile shows me.
- I can extend existing images. If one doesn't meet my needs, I can use it as a base for a custom image and add the additional functionality I need.
- Service installations are isolated to the container. This avoids dependency conflicts between services and makes uninstalling a service and its dependencies as simple as deleting the container.
- Provides an abstraction over resources (virtualization). Bind mounts let me control where each service saves its data. Port mapping lets me control what ports each service uses to handle traffic. Services are not aware of this inside their containers, which lets them use default configurations. This gives me flexibility to move data around without needing to reconfigure the service.
- The isolated installation, reproducable builds, and resource virtualization let me work with services as immutable units. Instead of updating a service in place, I replace its container with a new one that has the new version of the service. The state of the service remains well-known. It prevents build-up of old or stale cached files. There is peace of mind from knowing that if container disappeared, I could get a new one going in a few minutes.
- Docker provides DNS that lets containers contact each other using their pod names.
- Provides process and network isolation. This helps restrict the damage if a service is compromised.

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
