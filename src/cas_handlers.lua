function first_access()
  -- CAS_HOSTNAME and CAS_SERVICEREG are both trusted
  return ngx.redirect(
    ngx.var.CAS_HOSTNAME .. "?service=" .. ngx.var.CAS_SERVICEREG,
    ngx.HTTP_MOVED_TEMPORARILY)
end

function set_cookie_and_store(max_age, cookie_val)
  local ck = require('cookie')
  local cookie = ck:new()

  -- place cookie into cookie store
  local success, err, forcible = ngx.shared.cookie_store:add(
    cookie_val, true, max_age)
  if not success then
    if err == "no memory" then
      -- the add method will attempt to clear out all LRU entries
      -- if it doesn't have sufficient memory to do an insertion,
      -- but if it got here then even that didn't help.
      ngx.log(ngx.EMERG, "Cookie store is out of memory")
      return false
    elseif err == "exists" then
      -- TODO: what to do about duplicate
      return false
    end
  end

  -- if that was okay, then place cookie into the browser
  cookie:set({
    key="JSESSIONID",
    value=cookie_val,
    max_age=max_age
  })

  return true
end

function validate_with_CAS(token)
  -- send a subrequest to CAS/validate w/ the token
  local res = ngx.location.capture(ngx.var.CAS_HOSTNAME .. "/validate",
    { args = { token = token, service = ngx.var.CAS_SERVICEREG} })

  -- did the response from CAS have the string "yes" in it?
  if res.status == ngx.HTTP_OK and
     res.body ~= nil and string.find(res.body, "yes") then
    local max_age = (ngx.var.COOKIE_EXPIRY or 3600)
    local cookie_val = "asdasd" -- TODO: randomly generated

    -- fails on low memory or on duplicate (for now)
    if not set_cookie_and_store(max_age, cookie_val) then
      return first_access()
    end

    -- TODO: strip service query param
  else
    return first_access()
  end
end

function validate_cookie(cookie)
  -- does the cookie exist in our store?
  if ngx.shared.cookie_store:get(cookie) == nil then
    return first_access()
  end
end

return {
  first_access = first_access;
  validate_with_CAS = validate_with_CAS;
  validate_cookie = validate_cookie;
}
