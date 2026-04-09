--- @since 25.5.28

local M = {}

function M:peek(job)
	if not job.file then
		return
	end

	local start = job.skip + 1
	local finish = job.skip + job.area.h

	local output, err = Command("bat")
		:arg("--style"):arg("numbers")
		:arg("--color"):arg("always")
		:arg("--paging"):arg("never")
		:arg("--line-range"):arg(start .. ":" .. finish)
		:arg(tostring(job.file.url))
		:output()

	if not output then
		return ya.preview_widget(job, ui.Text("Error: " .. tostring(err)):area(job.area):wrap(ui.Wrap.YES))
	end

	local s = output.stdout:gsub("\t", string.rep(" ", rt.preview.tab_size))

	if job.skip > 0 and s == "" then
		ya.emit("peek", { math.max(0, job.skip - job.area.h), only_if = job.file.url, upper_bound = false })
		return
	end

	local wrap = rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO
	ya.preview_widget(job, ui.Text.parse(s):area(job.area):wrap(wrap))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

return M
