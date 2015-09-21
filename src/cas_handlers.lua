local ck = require('resty.cookie')
local cookie_store = ngx.shared[ngx.var.COOKIE_STORE]
local ticket_store = ngx.shared[ngx.var.TICKET_STORE]

local cookie_name = "NGXCAS"

function first_access()
  -- CAS_URI and CAS_SERVICEREG are both trusted
  return ngx.redirect(
    ngx.var.CAS_URI .. "/login?service=" .. ngx.var.CAS_SERVICEREG,
    ngx.HTTP_MOVED_TEMPORARILY)
end

function set_cookie_and_store(max_age, cookie_val, ticket_val)
  local cookie = ck:new()

  -- place cookie into cookie store
  local success, err, forcible = cookie_store:add(
    cookie_val, ticket_val, max_age)
  if not success then
    if err == "no memory" then
      -- the add method will attempt to clear out all LRU entries
      -- if it doesn't have sufficient memory to do an insertion,
      -- but if it got here then even that didn't help.
      ngx.log(ngx.EMERG, "Cookie store is out of memory")
      return false
    elseif err == "exists" then
      -- we don't do anything, since this in itself has a very low
      -- probability of occurring (the user just has to log in again)
      return false
    end
  end

  -- analagous for placement of tickets
  local success, err, forcible = ticket_store:add(
    ticket_val, cookie_val, max_age)
  if not success then
    if err == "no memory" then
      ngx.log(ngx.EMERG, "Ticket store is out of memory")
      return false
    elseif err == "exists" then
      return false
    end
  end

  -- if that was okay, then place cookie into the browser
  cookie:set({
    key=cookie_name,
    value=cookie_val,
    max_age=max_age
  })

  return true
end

function generate_cookie()
  local resty_random = require('resty.random')
  local str = require("resty.string")

  local strong_random = resty_random.bytes(32, true)
  while strong_random == nil do
    strong_random = resty_random.bytes(32, true)
  end

  return "CK-" .. str.to_hex(strong_random)
end

function validate_with_CAS(ticket)
  -- send a subrequest to CAS/validate w/ the ticket
  local res = ngx.location.capture(ngx.var.CAS_URI .. "/validate",
    { args = { ticket = ticket, service = ngx.var.CAS_SERVICEREG } })

  -- did the response from CAS have the string "yes" in it?
  if res.status == ngx.HTTP_OK and
     res.body ~= nil and string.find(res.body, "yes") then
    local max_age = (ngx.var.COOKIE_EXPIRY or 3600)
    local cookie_val = generate_cookie()

    -- fails on low memory or on duplicate (for now)
    if not set_cookie_and_store(max_age, cookie_val, ticket) then
      return first_access()
    end
  else
    return first_access()
  end
end

function validate_cookie(cookie)
  -- does the cookie exist in our store?
  if cookie_store:get(cookie) == nil then
    -- the cookie was probably destroyed
    -- by us in SLO previously anyway, so
    -- we expire it immediately
    local cookie = ck:new()
    cookie:set({
      key=cookie_name,
      value="",
      max_age=-1
    })
    return first_access()
  end
end

function destroy_ticket(ticket)
  -- destroys cookie and ticket for SLO
  local assoc_cookie, _ = ticket_store:get(ticket)
  if assoc_cookie ~= nil then
    cookie_store:delete(assoc_cookie)
    ticket_store:delete(ticket)
  end
end

return {
  first_access = first_access;
  validate_with_CAS = validate_with_CAS;
  validate_cookie = validate_cookie;
  destroy_ticket = destroy_ticket;
}
