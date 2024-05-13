# 22. Use Traefik middleware to set HTTP security headers

Date: 2023-09-09

## Status

Accepted

## Context

Browsers can provide security

To prevent bad actors doing sneaky things from the browser.
This includes things like loading a real web page in an iframe to get the cookies.
These generally involve

The HTTP `Strict-Transport-Security` (HSTS) response header tells the browser that it should only use HTTPS, and not HTTP. This helps make sure that communication between the browser and the server is encrypted so bad actors can look at or modify messages.

The `Content-Security-Policy` (CSP) response header tells the browser how the webpage expects to be loaded. For example, it might indicate the web page should never be loaded in an iframe. If the browser sees the web page attempt to be loaded in an iframe, then, the browser will block it to prevent malicious actors from taking advantage of displaying it in an unintended way.

[Cross Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) is configured using the `Access-Control-Allow-Origin`,

## Decision

The change that we're proposing or have agreed to implement.

## Consequences

What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.

## References

- [HTTP Security Response Headers Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Headers_Cheat_Sheet.html)
- [Security on the web](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Mozilla InfoSec Web Security](https://infosec.mozilla.org/guidelines/web_security)
- [HTTP security headers: An easy way to harden your web applications](https://www.invicti.com/blog/web-security/http-security-headers/)
