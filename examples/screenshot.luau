--!strict

-- Capture an instrumented egui app for agent review.
--
-- `script_eval` keeps every `ImageRef` that stays reachable from the returned
-- value as MCP image content blocks, so an agent inspects the real frame
-- instead of scraping the screen. The CLI writes the same images to disk:
--
--   edev eval examples/screenshot.luau --out-dir tmp/eguidev-screenshots
--   edev eval examples/screenshot.luau --out-dir tmp/eguidev-screenshots \
--     --arg fixture=basic.empty --arg widget=basic.preview.image
--
-- Both args are optional. `fixture` applies one registered fixture first, so
-- the capture shows a known state. `widget` replaces the per-viewport captures
-- with one widget crop, which is the cheapest way to give an agent a focused
-- visual target.

local fixture_name = eguidev.args.fixture
if type(fixture_name) == "string" then
    eguidev.fixture(fixture_name)
end

local widget_id = eguidev.args.widget
if type(widget_id) == "string" then
    return {
        [widget_id] = eguidev.widget(widget_id):screenshot({ format = "png" }),
    }
end

eguidev.root:wait_capture()

local images: { [string]: ImageRef } = {}
for _, viewport in ipairs(eguidev.viewports()) do
    local label: string = viewport.id
    local state = viewport:state()
    if state ~= nil and state.name ~= nil then
        label = state.name
    end
    images[label] = viewport:screenshot({ format = "png" })
end

return images
