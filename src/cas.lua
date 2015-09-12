local handlers = require('cas_handlers')


-- per request variables
local cookie = ngx.var.cookie_JSESSIONID
local token = ngx.var.arg_token

if cookie ~= nil then
  -- cookie, no token
  -- TODO: cookie store?
elseif token ~= nil then
  return handlers.validate_with_CAS(token)
else
  return handlers.first_access()
end
