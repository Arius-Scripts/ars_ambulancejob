require 'resource.compatibility.txadmin.server'
require 'resource.commands.server'
require 'resource.modules.death.server'
require 'resource.modules.job.server.main'

Framework = lib.class("framework")


local path = ('resource.compatibility.frameworks.%s.server'):format(Config.Framework)
lib.load(path)
