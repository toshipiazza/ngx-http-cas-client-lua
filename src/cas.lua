local handlers = require('cas_handlers')

-- per request variables
local cookie = ngx.var.cookie_NGXCAS
local ticket = ngx.var.arg_ticket

function strip_ticket_query()
  local args = ngx.req.get_uri_args()
  args['ticket'] = nil
  ngx.req.set_uri_args(args)
end

if cookie ~= nil then
  return handlers.validate_cookie(cookie)
elseif ticket ~= nil then
  -- TODO: why doesn't this work?
  strip_ticket_query()
  return handlers.validate_with_CAS(ticket)
else
  return handlers.first_access()
end
