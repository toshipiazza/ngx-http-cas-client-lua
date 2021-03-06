local handlers = require('cas_handlers')

-- per request variables
local cookie = ngx.var.cookie_NGXCAS
local ticket = ngx.var.arg_ticket

function strip_query(ngx, arg)
  -- TODO: why doesn't this work?
  local args = ngx.req.get_uri_args()
  args[arg] = nil
  ngx.req.set_uri_args(args)
end

-- we read the body before we do anything
ngx.req.read_body()

if cookie ~= nil then
  return handlers.validate_cookie(cookie)
elseif ticket ~= nil then
  strip_query(ngx, ticket)
  return handlers.validate_with_CAS(ticket)
else
  return handlers.first_access()
end
