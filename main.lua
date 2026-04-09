--- @since 25.5.28

local M = {}

function M:peek(job)
	if not job.file then
		return
	end

	local output, err = Command("bat")
		:arg("--style"):arg("numbers")
		:arg("--color"):arg("always")
		:arg("--paging"):arg("never")
		:arg(tostring(job.file.url))
		:output()

	if not output then
		return ya.preview_widget(job, ui.Text("Error: " .. tostring(err)):area(job.area))
	end

	local lines = {}
	local i = 0
	for line in output.stdout:gmatch("[^\n]*\n?") do
		i = i + 1
		if i > job.skip then
			lines[#lines + 1] = ui.Line.parse(line)
		end
		if #lines >= job.area.h then break end
	end

	if job.skip > 0 and #lines == 0 then
		ya.emit("peek", { math.max(0, job.skip - job.area.h), only_if = job.file.url, upper_bound = false })
		return
	end

	ya.preview_widget(job, ui.List(lines):area(job.area))
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
