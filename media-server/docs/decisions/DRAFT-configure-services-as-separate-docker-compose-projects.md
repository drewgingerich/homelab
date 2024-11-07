# 12. Configure services as separate Docker Compose projects

Date: 2023-09-04

## Status

Accepted

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

## Decision

Configure each service as its own Docker Compose project, with it's own folder for resources such as Dockerfiles, configuration files, and environment variables.

## Consequences

Services will be easier to start and stop.

Common configuration, such as time zone, will need to be duplicated across services.

A shared, external network will need to be created for services to be able to interact with each other.
In particular a there will need to be a network for Traefik be able to communicate with services for traffic routing.
