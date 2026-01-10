# Use systemd to manage services and jobs

## Problem

I need a way to manage the services running on my media server, specifically to:

- Configure service environments
  - Network
  - Filesystem
  - Compute resources
  - Environment variables
- Secrets management
- Restart unhealthy services
- Define dependencies between services
- Schedule recurring jobs
- Operate based declarative, version-controlled configuration files

## Options

- Container orchestrator
- [Docker](https://www.docker.com/) + [Docker Compose](https://docs.docker.com/compose/) + container-based job scheduler
- [Systemd](https://en.wikipedia.org/wiki/Systemd)

## Decision

Use systemd to manage services.

## Exploration

### Container orchestrator

The production-grade tool for my needs is a container orchestrator.
The main options are:

- [Kubernetes](https://kubernetes.io/)
- [Nomad](https://developer.hashicorp.com/nomad)
- [Docker Swarm](https://docs.docker.com/engine/swarm/)

I'm most familiar with Kubernetes (K8s) and I like its design.

K8s can do everything I need,
but is limited to using containers.
This is fine since I'm currently running services in containers anyways.

While K8s can do a single-node setup, it's designed to manage multiple nodes.
This makes it more complicated than necessary for a single-node setup,
but also ready to provide support if I ever decide to add more nodes.

### Docker stack

Docker provides container environments, health checks and restart policies, and basic secrets management,
while Docker Compose adds inter-service dependencies and declarative configuration.
With the addition of a container-based job scheduler such as [Ofelia](https://github.com/mcuadros/ofelia),
This stack meets all of my service management needs.

Docker + Docker Compose is what I currently use to manage my services,
and it's been a pretty great experience.
I do feel that I've been running into some lack of flexibility, though.

I don't have experience with a container-based job scheduler.

### Systemd

Systemd process manager that is built into most Linux distributions.

https://medium.com/@sebastiancarlos/systemds-nuts-and-bolts-0ae7995e45d3

Being built-in is appealing to me, because I prefer to keep things lean.

Systemd provides everything I want for service management,
and can integrate other tools when I want to.

Systemd services are declaratively defined using configuration files,
which can be version-controlled.

Because systemd handles processes in general,
it can manage any sort of workload: binary, VM, containerized, or whatever.
Then actual running of non-binary workloads is delegated to other tools, such as Docker or QEMU.

I'm interested in learning more about systemd.

