--------------------------------------------------------------------------------
-- INITIALIZE SCENE & LOAD LIBRARIES
--------------------------------------------------------------------------------
local scene = composer.newScene()
local cranks = require('objects.cranks')

--------------------------------------------------------------------------------
-- VARIABLE DECLARATIONS
--------------------------------------------------------------------------------

----------------------------------------
-- DISPLAY GROUPS
----------------------------------------
local group

----------------------------------------
-- DISPLAY OBJECTS
----------------------------------------
local objects

----------------------------------------
-- FUNCTIONS
----------------------------------------
local functions

----------------------------------------
-- SOUNDS
----------------------------------------
local sounds = {}

----------------------------------------
-- OTHER
----------------------------------------


--------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
-- CREATE SCENE
--------------------------------------------------------------------------------
function scene:create( event )
	group = self.view

  local crank = cranks.new()


end

--------------------------------------------------------------------------------
-- SHOW SCENE
--------------------------------------------------------------------------------
function scene:show( event )
	----------------------------------------
	-- WILL SHOW
	----------------------------------------
	if event.phase=="will" then

	----------------------------------------
	-- DID SHOW
	----------------------------------------
	elseif event.phase=="did" then

	end
end

--------------------------------------------------------------------------------
-- HIDE SCENE
--------------------------------------------------------------------------------
function scene:hide( event )
	----------------------------------------
	-- WILL HIDE
	----------------------------------------
	if event.phase=="will" then

	----------------------------------------
	-- DID HIDE
	----------------------------------------
	elseif event.phase=="did" then

	end
end

--------------------------------------------------------------------------------
-- DESTROY SCENE
--------------------------------------------------------------------------------
function scene:destroy( event )
	----------------------------------------
	-- DISPOSE LOADED AUDIO FILES
	----------------------------------------
	for k,v in pairs(sounds) do
		audio.dispose(sounds[k])
		sounds[k] = nil
	end

end

--------------------------------------------------------------------------------
-- COMPOSER LISTENERS
--------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
