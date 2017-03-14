-- Copyright (C) 2015-2016, UPYUN Inc.

local cjson  = require "cjson.safe"
local consul = require "modules.consul"
local mload  = require "modules.load"

slardar = require "config" -- global config variable

slardar.global.version = "1.0.0"

--slardar包装额ngx.exit()函数
slardar.exit = function(err)
    if ngx.headers_sent then
        return ngx.exit(ngx.status)
    end

    local status, discard_body_err = pcall(ngx.req.discard_body)
    if not status then
        ngx.log(ngx.ERR, "discard_body err:", discard_body_err)
    end

    local code = err.code
    if ngx.var.x_error_code then
        ngx.var.x_error_code = code
    end
    -- standard http code, exit as usual
    if code >= 200 and code < 1000 then
        return ngx.exit(code)
    end

    local httpcode = err.httpcode
    ngx.status = httpcode
    local req_headers = ngx.req.get_headers()
    ngx.header["X-Error-Code"] = code
    ngx.header["Content-Type"] = "application/json"
    local body = cjson.encode({
        code = code,
        msg = err.msg,
    })
    ngx.header["Content-Length"] = #body
    ngx.print(body)
    return ngx.exit(httpcode)
end


local no_consul = slardar.global.no_consul

--调用consul.init初始化consul模块
-- if init config failed, abort -t or reload.
local ok, init_ok = pcall(consul.init, slardar)
if no_consul ~= true then
    if not ok then
        error("Init config failed, " .. init_ok .. ", aborting !!!!")
    elseif not init_ok then
        error("Init config failed, aborting !!!!")
    end
end

调用mload.init初始化mload模块
local ok, init_ok = pcall(mload.init, slardar)
if no_consul ~= true then
    if not ok then
        error("Init lua script failed, " .. init_ok .. ", aborting !!!!")
    elseif not init_ok then
        error("Init lua script failed, aborting !!!!")
    end
end

setmetatable(slardar, {
    __index = consul.load_config,
})
