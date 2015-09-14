local ck = require('cookie')

function first_access()
  -- CAS_HOSTNAME and CAS_SERVICEREG are both trusted
  return ngx.redirect(
    ngx.var.CAS_HOSTNAME .. "?service=" .. ngx.var.CAS_SERVICEREG,
    ngx.HTTP_MOVED_TEMPORARILY)
end

function validate_with_CAS(token)
  -- send a subrequest to CAS/serviceValidate w/ the serviceToken
  local res = ngx.location.capture(ngx.var.CAS_HOSTNAME .. "/serviceValidate",
    { args = { serviceToken = token} })

  -- did the response from CAS have the string "success" in it?
  if string.find(res.body, "success") then
    local cookie = ck:new()
    local max_age = (ngx.var.COOKIE_EXPIRY or 3600)
    local cookie_val = "asdasd" -- TODO: randomly generated

    -- place cookie into cookie store
    local ok, err = ngx.shared.cookie_store:safe_add(
      cookie_val, true, max_age)
    if ok == nil and err == "no memory" then
      ngx.log(ngx.EMERG, "Cookie store is out of memory")
      return first_access()
    elseif ok == nil and err == "exists" then
      -- TODO: what to do about duplicate
    end

    -- if that was okay, then place cookie into the browser
    cookie:set({
      key="JSESSIONID",
      value=cookie_val,
      max_age=max_age
    })

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
