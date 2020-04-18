local _M = {}
local math = math
local sqrt = math.sqrt
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    parent = display.currentStage,
    width = screenWidth * .6,
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local function distance(obj1, obj2)
  local dx = obj1.x - obj2.x
  local dy = obj1.y - obj2.y
  return sqrt(dx^2 + dy^2)
end

local function angleBetween ( srcObj, dstObj )
	local xDist = dstObj.x-srcObj.x ; local yDist = dstObj.y-srcObj.y
	local angleBetween = math.deg( math.atan( yDist/xDist ) )
	if ( srcObj.x < dstObj.x ) then angleBetween = angleBetween+90 else angleBetween = angleBetween+270 end
	return angleBetween
end

local function touch_spin(event)
  local handle = event.target
  local phase = event.phase
  local crank = handle.parent
  local x, y = crank:contentToLocal(event.x, event.y)
  local angle = angleBetween(crank, event)
  local distance = distance(crank, event)
  local deltaRotation = angle - crank.rotation
  print(math.abs(deltaRotation))

  if phase == 'began' then
    handle.hasFocus = true
    display.currentStage:setFocus(handle, event.id)
  elseif phase == 'moved' and handle.hasFocus then
    if distance < handle.width*.4 or distance > crank.width * .6 then
      handle.hasFocus = nil
      display.currentStage:setFocus(nil, event.id)
      print('whoops')
    else
      crank.rotation = crank.rotation + deltaRotation
    end
  elseif phase == 'cancelled' or phase == 'ended' then
    handle.hasFocus = nil
    display.currentStage:setFocus(nil, event.id)
  end
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)

  local crank = display.newGroup()
  crank.anchorChildren = true
  crank.x, crank.y = params.x, params.y
  params.parent:insert(crank)

  local base = display.newCircle(crank, 0, 0, params.width * .5)
  local handle = display.newCircle(crank, 0, -params.width * .5 + 2, params.width * .17)
  handle.anchorY = 0
  handle:setFillColor(1, 0, 0)
  handle:addEventListener('touch', touch_spin)
  return crank
end


return _M
