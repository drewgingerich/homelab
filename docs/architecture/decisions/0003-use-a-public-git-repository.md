# 3. Use a public Git repository

Date: 2023-10-05

## Status

Accepted

## Context

I want to capture what I've accomplished.
I want to share my work with others.
I would be thrilled if my efforts were helpful to someone else.

I am already managing this project using Git and GitHub.

I am comfortable with GitHub and GitLab.
GitHub is currently the most popular Git backend,
and provides the widest potential reach for sharing this project.

## Decision

I will continue to store this project as a publicly-accessible GitHub repository.

## Consequences

I will need to be careful to keep sensitive data out of the Git repository,
otherwise it will be exposed to the public.
This includes obvious things like API keys and passwords, and
I also prefer to keep infrastructure details, such as ports and filesystem paths, private when feasible.
