# 6. Use a public Git repository

Date: 2019

## Status

Accepted

## Context

I want to share my setup with others.
I want to leave a mark of what I've accomplished.
I would be thrilled if my efforts were helpful to someone else.

I am already managing this project using Git and GitHub.
GitHub is currently the most popular Git backend,
and provides the widest potential reach for sharing this project.

## Decision

I will save this project as a publicly-accessible Git repository on GitHub.

## Consequences

I will need to be careful to keep sensitive data out of version control,
otherwise it will be leaked to the public.
This includes obvious things like API keys and passwords.
I also prefer to keep infrastructure details, such as ports and filesystem paths, private when feasible.
