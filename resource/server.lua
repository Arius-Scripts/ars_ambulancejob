require 'resource.compatibility.txadmin.server'
require 'resource.commands.server'
require 'resource.modules.death.server'

Framework = lib.class("framework")


local path = ('resource.compatibility.frameworks.%s.server'):format(Config.Framework)
lib.load(path)
