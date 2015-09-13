local ck = require('cookie')

function first_access()
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
    cookie:set({
      key="JSESSIONID",
      value="asdasd"
    })
    ngx.shared.cookie_store:set("asdasd", true,
      (ngx.var.COOKIE_EXPIRY or 3600))
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
