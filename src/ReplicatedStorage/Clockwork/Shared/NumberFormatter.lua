--!strict

local NumberFormatter = {}

-- Each entry represents another group of three zeroes. Values beyond this list
-- fall back to scientific notation so formatting remains useful at any size.
local SUFFIXES = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Ocd",
	"Nod",
	"Vg",
}

local function trimTrailingZeroes(value: string): string
	return (value:gsub("(%..-)0+$", "%1"):gsub("%.$", ""))
end

function NumberFormatter.Format(value: number): string
	if value ~= value then
		return "0"
	end

	if value == math.huge then
		return "∞"
	elseif value == -math.huge then
		return "-∞"
	end

	local sign = if value < 0 then "-" else ""
	local absoluteValue = math.abs(value)

	if absoluteValue < 1_000 then
		if absoluteValue % 1 == 0 then
			return sign .. string.format("%.0f", absoluteValue)
		end

		return sign .. trimTrailingZeroes(string.format("%.2f", absoluteValue))
	end

	local suffixIndex = math.floor(math.log10(absoluteValue) / 3) + 1
	if suffixIndex > #SUFFIXES then
		return sign .. string.format("%.2e", absoluteValue)
	end

	local scaledValue = absoluteValue / (1_000 ^ (suffixIndex - 1))
	-- Promote values that would otherwise round to awkward output such as 1000K.
	if scaledValue >= 999.5 and suffixIndex < #SUFFIXES then
		suffixIndex += 1
		scaledValue /= 1_000
	end

	local formattedValue: string

	if scaledValue >= 100 then
		formattedValue = string.format("%.0f", scaledValue)
	elseif scaledValue >= 10 then
		formattedValue = string.format("%.1f", scaledValue)
	else
		formattedValue = string.format("%.2f", scaledValue)
	end

	return sign .. trimTrailingZeroes(formattedValue) .. SUFFIXES[suffixIndex]
end

return NumberFormatter
