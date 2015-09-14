# ngx-http-cas-client-lua

### WARNING, this project is not yet finished

This is a CAS client written entirely using nginx's lua module. The idea is that you will
protect an nginx location by way of CAS authentication. By providing a CAS endpoint (which
for now must have a corresponding entry in nginx.conf, see limitations section), you will be
able to restrict access to only those who are validated by the CAS server.

# Why is this useful?

CAS integration among many separated products is hard(ish). For grails apps, you need to
import a shiro plugin for CAS integration, and other platforms are generally the same in
this respect (Django CAS, node CAS). Instead, you can have one virtual server protecting
many apps, with minimal integration overhead.

# TODO

### Needed for full CAS support
* Generator for generating random cookies.
* Strip service header when ticket is validated against CAS.
* (future proposal) Support proxy tickets, wean off of the /validate (CAS 1.0) endpoint
  and use the /{service,proxy}Validate endpoints

### Corner Cases
* What should happen on collision in ngx.shared.DICT for cookie\_store?
* What should happen when ngx.shared.DICT runs out of memory? What do we do?
  - currently we just write to a log file and fail silently without tampering with any
    other data.

### Misc
* Unit/Acceptance Tests!!!!!
* Package application like lua-resty-cookie, with just lua files and no build script. Build
  script link may be put in the README or on a wiki.
* Determine performance degredation over long scale tests ( > 1 hour)

# Limitations
* For now, a CAS uri must exist within the nginx.conf, even if it's just a proxy-pass to the
  real server. This necessarily means that the CAS server is accessible on the same hostname,
  though not necessarily accessible to the public.
  ```
  # This endpoint must exist, optimally a proxy pass to the actual server
  location /CAS {
    ...
  }

  location /client {
    set $CAS_SERVICEREG "https://localhost/client";
    set $CAS_HOSTNAME   "/CAS";
    set $COOKIE_EXPIRY 7200; # defaults to 3600s=1 hour

    lua_need_request_body on;
    access_by_lua_file cas.lua;

    ...
  }
  ```
* The CAS protocol only returns a "yes" or a "no". Traditionally a separate database is used
  for the idea of permissions. This module does not (yet) pass any XML file data to the
  application as if we used the /serviceValidate endpoint. Be a good user for now and use
  a separate database for permissions, etc.
