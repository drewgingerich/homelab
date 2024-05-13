# 3. Use Docker Compose to configure Docker containers

Date: 2023-08-20

## Status

Accepted

## Context

- Capture more configuration as code

Configuration drift is a potential problem when maintaining a server.
Over time the state of services will change, eventually ending up in an unknown state.

I want to install and manage services using a configuration-as-code approach,
which is to save service configuration as version-controlled artifacts.
These artifacts act as documentation that I can use to remember how each service is set up.
They also provide a foundation for automating service setup and teardown.

## Decision

The change that we're proposing or have agreed to implement.

## Consequences

Configuration will be stored as version-controlled records.
This enables services to be reconfigured quickly and accurately.

Prevents configuration drift.

Foundation for automation.
