--------------------------------------------------------------------------------
-- INITIALIZE SCENE & LOAD LIBRARIES
--------------------------------------------------------------------------------
local scene = composer.newScene()
local devices = require('objects.devices')
local random = math.random
--------------------------------------------------------------------------------
-- VARIABLE DECLARATIONS
--------------------------------------------------------------------------------

----------------------------------------
-- DISPLAY OBJECTS
----------------------------------------
local group, bg, device, bubbleGroup

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

local function release_bubble()
  local bubble = display.newRect(bubbleGroup, random(screenLeft, screenRight), screenBottom + 20, random(4, 12), random(4,12))
  bubble.alpha = random() * .5
  bubble.blendMode = 'screen'
  bubble:setFillColor(random())
  transition.to(bubble, {y = screenTop - 20, x = bubble.x + random(-50, 50), time = random(3000, 8000), alpha = bubble.alpha * .1, transition = easing.outSine, onComplete = display.remove})
  timer.performWithDelay(random(10, 200), release_bubble)
end


--------------------------------------------------------------------------------
-- CREATE SCENE
--------------------------------------------------------------------------------
function scene:create( event )
	group = self.view

  bg = display.newImageRect(group, 'images/bg.png', screenWidth, screenHeight)
  bg:setFillColor(.5)
  bg.x, bg.y = centerX, centerY

  bubbleGroup = display.newGroup()
  group:insert(bubbleGroup)

  device = devices.new({
    parent = group,
  })

  release_bubble()


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
