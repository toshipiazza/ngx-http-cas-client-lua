local handlers = require('cas_handlers')
local ck = require('resty.cookie')

-- we read the body before we do anything
ngx.req.read_body()

function extract_ticket(saml)
  if saml ~= nil then
    local match_str = "<samlp:SessionIndex>(.*)</samlp:SessionIndex>"
    return string.match(saml, match_str)
  end
  return nil
end

if ngx.req.get_method() == "POST" then
  -- single logout request from CAS
  local ticket = extract_ticket(ngx.req.get_body_data())
  if ticket ~= nil then
    handlers.destroy_ticket(ticket)
  end

  -- specs say client MUST return 200
  ngx.exit(ngx.HTTP_OK)
elseif ngx.req.get_method() == "GET" then
  -- direct browser interaction, destroy cookie
  local cookie = ck:new()
  local cookie_val = ngx.var.cookie_NGXCAS
  handlers.destroy_cookie(cookie_val)

  -- expire session immediately
  cookie:set({
    key=handlers.cookie_name,
    value="",
    max_age=-1
  })

  -- redirect to cas logout
  return ngx.redirect(ngx.var.CAS_URI .. "/logout")
end
