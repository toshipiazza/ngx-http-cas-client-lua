local handlers = require('cas_handlers')
local ck = require('resty.cookie')

-- we read the body before we do anything
ngx.req.read_body()

-- direct browser interaction, destroy cookie
local cookie = ck:new()
local cookie_val = ngx.var.cookie_NGXCAS
handlers.destroy_cookie(cookie_val)

-- expire session immediately
cookie:set({
  key="NGXCAS",
  value="",
  max_age=-1
})

-- redirect to cas logout
return ngx.redirect(ngx.var.CAS_URI .. "/logout")
