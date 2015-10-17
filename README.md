# ngx-http-cas-client-lua

### WARNING, CAS integration is functional, but mileage may vary.

This is a CAS client written entirely using nginx's lua module. The idea is that
you will protect an nginx location by way of CAS authentication. By providing a
CAS endpoint (which for now must have a corresponding entry in nginx.conf, see
limitations section), you will be able to restrict access to only those who are
validated by the CAS server.

# Why is this useful?

CAS integration among many separated products is hard(ish). For grails apps, you
need to import a shiro plugin for CAS integration, and other platforms are
generally the same in this respect (Django CAS, node CAS). Instead, you can have
one virtual server protecting many apps, with minimal integration overhead.

# To Build

* [ngx\_openresty](https://github.com/openresty/ngx_openresty) seems to be the
  de facto standard in lua based nginx processing, so use it. It comes built in
  with a lot of functionality (and separate modules, like ssl support) which are
  necessary anyway.
* Depends on [lua resty cookie](https://github.com/cloudflare/lua-resty-cookie)
  for cookie.lua, and on
  [lua resty string](https://github.com/openresty/lua-resty-string) for
  random.lua and string.lua

# TODO

### Needed for full CAS support
* Strip service header when ticket is validated against CAS. (for some reason
  does not work)
  - non crucial and not necessary
* (future proposal) Support proxy tickets, wean off of the /validate (CAS 1.0)
  endpoint and use the /{service,proxy}Validate endpoints

### Misc
* COOKIE\_EXPIRY should only be set once per server. We should enforce this.
* Unit/Acceptance Tests!!!!!
* Determine performance degredation over long scale tests ( > 1 hour)

# Limitations
* For now, a CAS uri must exist within the nginx.conf, even if it's just a
  proxy-pass to the real server. This necessarily means that the CAS server is
  accessible on the same hostname (see example nginx.conf).
* The CAS protocol only returns a "yes" or a "no". Traditionally a separate
  database is used for the idea of permissions. This module does not (yet) pass
  any XML file data to the application as if we used the /serviceValidate
  endpoint. Be a good user for now and use a separate database for permissions.
* logout.lua is a GET endpoint meant for direct browser interaction to
  invalidate the current session, while also redirecting to the CAS logout url.
  * Limitation: this CAS client currently does not support Single Log Out, and
    as a result logout can only occur through direct browser interaction.
