function first_access()
  ngx.req.set_uri_args("service=" .. ngx.var.CAS_SERVICEREG)
  return ngx.redirect(ngx.var.CAS_HOSTNAME, ngx.HTTP_MOVED_TEMPORARILY)
end

function validate_with_CAS(token)
  -- send a subrequest to CAS/serviceValidate w/ the serviceToken
  local res = ngx.location.capture(ngx.var.CAS_HOSTNAME .. "/serviceValidate",
    { args = { serviceToken = token} })

  -- did the response from CAS have the string "success" in it?
  if string.find(res.body, "success") then
    local ck = require('cookie')
    local cookie = ck:new()

    cookie:set({
      key="JSESSIONID",
      value="asdasd"
    })
    ngx.shared.cookie_store:set("asdasd", true)
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
