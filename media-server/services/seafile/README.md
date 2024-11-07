After starting the Seafile project, some settings must be updated in via the admin UI.

- `SERVICE_URL` should be set to just `/`
- `FILE_SERVER_ROOT` should be set to just `/seafhttp`

This will configure the webpage to use whatever domain it's on when calling Seafile's backend services. This is needed when Seafile can be accessed on multiple domains, such as LAN, WAN, and VPN variants.
