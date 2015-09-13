function first_access()
  ngx.req.set_uri_args("service=" .. ngx.var.CAS_SERVICEREG)
  return ngx.redirect(ngx.var.CAS_HOSTNAME, ngx.HTTP_MOVED_TEMPORARILY)
end

function validate_with_CAS(token)
  local res = ngx.location.capture(ngx.var.CAS_HOSTNAME .. "/validateService",
    { args = { serviceToken = token} })

  if string.find(res.body, "success") then
    local ck = require('cookie')
    local cookie = ck:new()

    cookie:set({
      key="JSESSIONID",
      value="asdasd"
    })
    ngx.shared.cookie_store:set("asdasd", true)
    return -- we're good
  end

  -- we redirect back to CAS
  return first_access()
end

function validate_cookie(cookie)
  if (ngx.shared.cookie_store:get(cookie) ~= nil) then
    return
  end

  return first_access()
end

return {
  first_access = first_access;
  validate_with_CAS = validate_with_CAS;
  validate_cookie = validate_cookie;
}
