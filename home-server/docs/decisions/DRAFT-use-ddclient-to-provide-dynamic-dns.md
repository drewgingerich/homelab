# 15. Use ddclient to provide dynamic DNS

Date: 2023-09-04

## Status

Accepted

## Context

The issue motivating this decision, and any context that influences or constrains the decision.

## Decision

Use `ddclient` to provide dynamic DNS.

## Consequences

Services exposed via port forwarding on my router's firewall will be accessible at a domain name.
This will make it easier for friends and family to use exposed services.

The IP address of my home network will be published via DNS.
