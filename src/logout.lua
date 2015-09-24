local handlers = require('cas_handlers')

-- we read the body before we do anything
ngx.req.read_body()

function extract_ticket(saml)
  if saml ~= nil then
    local match_str = "<samlp:SessionIndex>(.*)</samlp:SessionIndex>"
    return string.match(saml, match_str)
  end
end

if ngx.req.get_method() == "POST" then
  -- single logout request from CAS
  local ticket = extract_ticket(ngx.req.get_body_data())
  if ticket ~= nil then
    handlers.destroy_ticket(ticket)
  end
end

-- specs say client MUST return 200
ngx.exit(ngx.HTTP_OK)
