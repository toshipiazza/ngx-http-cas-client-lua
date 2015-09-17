local handlers = require('cas_handlers')

-- per request variables
local cookie = ngx.var.cookie_JSESSIONID
local ticket = ngx.var.arg_ticket

if cookie ~= nil then
  return handlers.validate_cookie(cookie)
elseif ticket ~= nil then
  return handlers.validate_with_CAS(ticket)
else
  return handlers.first_access()
end
