local _M = {}

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------------------------------------------------
local function set_defaults(params)
  local defaults = {
    x = centerX,
    y = centerY,
    width = 300,
    height = 50,
    cornerRadius = 20,
    parent = display.currentStage,
  }
  local params = params or {}
  for k,v in pairs(defaults) do
    if params[k] == nil then
      params[k] = v
    end
  end
  return params
end

local function set_level(self)
  for i, bar in pairs(self.bars) do
    bar.isVisible = i/#self.bars <= self.level / 100
  end
end

local function finalize(self)
  Runtime:removeEventListener('enterFrame', self)
end

--------------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
--------------------------------------------------------------------------------
function _M.new(params)
  local params = set_defaults(params)
  local meter = display.newGroup()
  meter.x, meter.y = params.x, params.y
  params.parent:insert(meter)

  local border = display.newRoundedRect(meter, 0, 0, params.width, params.height, params.cornerRadius)
  border:setFillColor(0, 0, 0, 0)
  border:setStrokeColor(0)
  border.strokeWidth = params.cornerRadius * .33

  local base = display.newRoundedRect(meter, 0, 0, params.width, params.height, params.cornerRadius)
  base:setFillColor(0)
  base.blendMode = 'multiply'
  base.alpha = .75

  local bars = {}
  local barGroup = display.newGroup()
  meter.barGroup = barGroup
  barGroup.anchorChildren = true
  meter:insert(barGroup)
  local num_bars = 20
  local bar_width = (params.width - params.cornerRadius*2) / (num_bars * 2)
  for i = 1, num_bars do
    local bar = display.newRoundedRect(barGroup, (bar_width * i * 2), 0, bar_width, params.height - params.cornerRadius, bar_width * .25)
    bars[i] = bar
    local g = (2.25-(num_bars/i - 1))
    local r = (num_bars/i - 1)
    bar:setFillColor(r, g, 0)
    bar.blendMode = 'screen'
    bar.alpha = .5 + (i/num_bars*.33)
  end
  meter.bars = bars

  meter.level = 100
  meter.enterFrame = set_level
  Runtime:addEventListener('enterFrame', meter)

  meter.finalize = finalize
  meter:addEventListener('finalize')

  return meter
end


return _M
