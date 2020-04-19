local scene = composer.newScene(); local group

local launch_screen_color = {1, 1, 1}

local first_scene = 'scenes.home'
local first_scene_transition = 'crossFade'

-- define default settings state
local default_settings = {

}

-- special simulator-only conditions
local function simulator_conditions()
  --Settings.reset()
  --audio.setVolume(0)
end

-- special device-only conditions
local function device_conditions()
  Runtime:hideErrorAlerts()
  print = return_false
end

--------------------------------------------------------------------------------
-- TOP-PRIORITY LAUNCH VARIABLE DEFINITIONS
--------------------------------------------------------------------------------
-- hide status bar:
display.setStatusBar( display.HiddenStatusBar )

-- allow background music from other apps
if audio.supportsSessionProperty then
  -- audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

-- placement variables & functions:
centerX = display.contentCenterX
centerY = display.contentCenterY
screenTop = math.floor(display.screenOriginY)
screenBottom = math.ceil(display.contentHeight - screenTop)
screenHeight = screenBottom - screenTop
screenLeft = math.floor(display.screenOriginX)
screenRight = math.ceil(display.contentWidth - screenLeft)
screenWidth = screenRight - screenLeft
local t, l, b, r = display.getSafeAreaInsets()
safeLeft = screenLeft + l
safeRight = screenRight - r
safeTop = screenTop + t
safeBottom = screenBottom - b
safeWidth = screenWidth - l - r
safeHeight = screenHeight - t - b
t, l, b, r = nil, nil, nil, nil

--------------------------------------------------------------------------------
-- "PRE-LOAD" LIBRARIES & SET OTHER GLOBALS
--------------------------------------------------------------------------------
local function init()
  -- seed random function:
  math.randomseed( os.time() )

  -- global settings library
  if false then
    Settings = require ('utilities.settings')
    Settings.init(default_settings)
  end
  
  fonts = require('fonts.fonts')

  -- global placement functions
  function placeX(px)
    return screenLeft + screenWidth * px
  end
  function placeY(py)
    return screenTop + screenHeight * py
  end
  function placeXY(px, py)
    return placeX(px), placeY(py)
  end

  -- global comma_value function
  local math = math
  local floor = math.floor
  function comma_value(amount)
    local formatted = floor(tonumber(amount))
    while true do
      formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

  -- device/environment global variables:
  local platformName = system.getInfo('platformName')
  local environment = system.getInfo('environment')
  is_android = (platformName == 'Android')
  is_apple = (platformName == 'iPhone OS' or platformName == 'iOS')
  is_simulator = (environment == 'simulator')
  is_device = (environment == 'device')

  -- global return true/false functions:
  return_true = function() return true end
  return_false = function() return false end

  -- load environment-specific conditions`
  if is_simulator then
    simulator_conditions()
  elseif is_device then
    device_conditions()
  end

  timer.performWithDelay(100, function()
    composer.gotoScene(first_scene, first_scene_transition)
  end)
end

--------------------------------------------------------------------------------
-- CREATE SCENE
--------------------------------------------------------------------------------
function scene:create( event )
	group = self.view

  local bg = display.newRect(group, centerX, centerY, screenWidth, screenHeight)
  bg:setFillColor(unpack(launch_screen_color))

end

--------------------------------------------------------------------------------
-- SHOW SCENE
--------------------------------------------------------------------------------
function scene:show( event )
	if event.phase=="will" then

	elseif event.phase=="did" then
    timer.performWithDelay(100, init)
	end
end

--------------------------------------------------------------------------------
-- HIDE SCENE
--------------------------------------------------------------------------------
function scene:hide( event )
	if event.phase=="will" then

	elseif event.phase=="did" then

	end
end

--------------------------------------------------------------------------------
-- DESTROY SCENE
--------------------------------------------------------------------------------
function scene:destroy( event )

end

--------------------------------------------------------------------------------
-- COMPOSER LISTENERS
--------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
