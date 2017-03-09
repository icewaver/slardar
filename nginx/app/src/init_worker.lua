-- Copyright (C) 2015-2016, UPYUN Inc.

local checkups = require "resty.checkups.api"
local mload    = require "modules.load"

checkups.prepare_checker(slardar)

--启动checkups
-- only one checkups timer is active among all the nginx workers
checkups.create_checker()

--创建自动同步lua module的时钟
mload.create_load_syncer()
