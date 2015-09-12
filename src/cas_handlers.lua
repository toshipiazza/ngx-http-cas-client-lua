local os = require("os")

function first_access()
  ngx.req.set_uri_args("service=" .. os.getenv(CAS_SERVICEREG))
  return ngx.redirect(os.getenv("CAS_HOSTNAME"), ngx.HTTP_MOVED_TEMPORARILY)
end

function validate_with_CAS(token)
  -- TODO: verify token is UUID
  local res = ngx.location.capture(ngx.var.CAS_HOSTNAME,
    { args = { serviceToken = token} })

  if res.body.find("success") then
    return -- we're good
  end
  -- we redirect back to CAS
  return first_access()
end

return {
  first_access = first_access;
  validate_with_CAS = validate_with_CAS;
}
