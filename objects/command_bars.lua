local _M = {}
local random = math.random
local indicator_lights = require('objects.indicator_lights')
--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    parent = display.currentStage,
    colors = {
      {1, 0, 0},
      {0, 1, 0},
      {0, 0, 1},
    },
    gap = 50,
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
  if self.device.active then
    for i, gem in pairs(self.gems) do
      if gem.y >= 0 then
        if i == 1 then
          gem.alpha = 1
        else
          gem.alpha = .4 - (1/20)*(i-1)
        end
      end
    end
    if #self.gems == 0 then
      self:drop_gem()
    end

    if not self.timer then
      self.timer = timer.performWithDelay((1-self.device.decaySpeed) * 1750, function()self:drop_gem() end)
    end
  else
    if self.timer then timer.cancel(self.timer) end
    for i, gem in pairs(self.gems) do
      display.remove(gem)
    end
    self.gems = {}
  end
end

local function drop_gem(self)
  if #self.gems >= 6 then
    self:dispatchEvent({name = 'overflow', target = self})
    self.last_x = self.last_x - self.gap
    local first_gem = self.gems[1]
    table.remove(self.gems, 1)
    display.remove(first_gem)
    for i, gem in pairs(self.gems) do
      transition.to(gem, {x = self.gap*(i-1), time = 100, transition = easing.inOutSine, delay = 20*(i-1)})
    end
  end
  if self.timer then timer.cancel(self.timer) end
  self.timer = nil
  local n = random(1, #self.colors)
  local x = self.gap * #self.gems
  local gem = display.newImageRect(self, 'images/gem.png', 35, 35)
  gem.rotation = random(-360, 360)
  gem.x, gem.y = x, -50
  gem.alpha = 0
  gem:setFillColor(unpack(self.colors[n]))
  gem.color_index = n
  self.gems[#self.gems +1] = gem
  transition.to(gem, {y = 0, alpha = .25, time = 200, transition = easing.outBack, rotation = random(43, 47)})
end

local function check_color(self, color_index)
  local gem = self.gems[1]
  local match = gem and (gem.color_index == color_index)
  table.remove(self.gems, 1)
  display.remove(gem)
  for i, gem in pairs(self.gems) do
    transition.to(gem, {x = self.gap*(i-1), time = 100, transition = easing.inOutSine, delay = 20*(i-1)})
  end
  return match
end

local function finalize(self)
  Runtime:removeEventListener('enterFrame', self)
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local bar = display.newGroup()
  bar.colors = params.colors
  bar.gems = {}
  bar.gap = params.gap
  bar.last_x = -params.gap

  bar.drop_gem = drop_gem
  bar.enterFrame = enter_frame
  Runtime:addEventListener('enterFrame', bar)
  bar.finalize = finalize
  bar:addEventListener('finalize')
  bar.check_color = check_color

  --bar.timer = timer.performWithDelay(1000, function()bar:drop_gem() end)

  bar.x, bar.y = params.x, params.y
  params.parent:insert(bar)
  return bar
end


return _M
