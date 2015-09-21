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

function extract_ticket(saml)
  -- TODO: Should we make this more robust? How? Why?
  local match_str = "<samlp:SessionIndex>(.*)</samlp:SessionIndex>"
  if saml ~= nil then
    return string.match(saml, match_str)
  end
end

-- we read the body before we do anything
ngx.req.read_body()

if ngx.req.get_method() == "POST" then
  -- single logout request from CAS
  local ticket = extract_ticket(ngx.req.get_body_data())
  if ticket ~= nil then
    handlers.destroy_ticket(ticket)
  end
  -- specs say client MUST return 200
  ngx.exit(ngx.HTTP_OK)
elseif cookie ~= nil then
  return handlers.validate_cookie(cookie)
elseif ticket ~= nil then
  strip_query(ngx, ticket)
  return handlers.validate_with_CAS(ticket)
else
  return handlers.first_access()
end
