# ngx-http-cas-client-lua

### WARNING, this project is not yet finished

This is a cas client written entirely using nginx's lua module. The idea is that you will
protect an nginx location by way of CAS authentication. By providing a CAS endpoint (which
for now must have a corresponding entry in nginx, see limitations section), you will be able
to restrict access to only those who are validated by the CAS server.

# Why is this useful?

CAS integration among many separated products is hard. For grails apps, you need to import a
shiro plugin, and for many other web apps it means installing a module (Django CAS, node CAS).
Instead, you can have one virtual server protecting many apps, with minimal integration
overhead.

# Limitations
* For now, a CAS uri must exist within the nginx.conf, even if it is just a proxy-pass to the
  real server.
  ```
    location /CAS {
      ...
      location /CAS/serviceValidate {
        ...
      }
    }

    location /client {
      set $CAS_SERVICEREG "https://localhost/client";
      set $CAS_HOSTNAME   "/CAS";

      lua_need_request_body on;
      access_by_lua_file cas.lua;

      ...
    }
  }
  ```
* The CAS protocol only returns an XML file that says "success" or not. Traditionally a
  separate database is used for the idea of permissions. This module does not (yet) pass
  the XML file data to the application.
