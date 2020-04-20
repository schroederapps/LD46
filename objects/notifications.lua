local _M = {}
local random = math.random
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    parent = display.currentStage,
    text = '',
    font = fonts.system_bold,
    fontSize = 18,
    color = {1, 1, 1},
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end



local function enter_frame(self)

end

local function finalize(self)
  Runtime:removeEventListener('enterFrame', self)
end
--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local notification = display.newGroup()
  notification.alpha = 1
  notification.xScale, notification.yScale = .5, .5
  notification.rotation = random(-4, 4)

  local text = display.newText({
    parent = notification,
    text = params.text,
    font = params.font,
    fontSize = params.fontSize,
    align = 'center',
  })
  text:setFillColor(unpack(params.color))
  text.blendMode = 'add'

  notification.x, notification.y = params.x, params.y
  params.parent:insert(notification)

  transition.to(notification, {alpha = 0, xScale = 1.2, yScale = 1.2, y = params.y - random(80, 120), x = params.x + random(-8, 8), rotation = random(-8, 8), onComplete = display.remove, time = random(800, 1500)})
  return notification
end


return _M
