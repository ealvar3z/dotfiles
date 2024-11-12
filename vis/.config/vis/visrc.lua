require('vis')

vis.events.subscribe(vis.events.INIT, function()
	vis:command('set escdelay 200')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function()
	vis:map(vis.modes.NORMAL, ';', ':')
	vis:map(vis.modes.INSERT, 'jk', '<Escape>h')
end)
