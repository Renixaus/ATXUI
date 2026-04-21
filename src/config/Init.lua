--!strict
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))

local Window

local ConfigManager
ConfigManager = {
	Folder = nil,
	Path = nil,
	Configs = {},
	Parser = {
		Colorpicker = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Default:ToHex(),
					transparency = obj.Transparency or nil,
				}
			end,
			Load = function(element, data)
				if element and element.Update then
					element:Update(Color3.fromHex(data.value), data.transparency or nil)
				end
			end,
		},
		Dropdown = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element and element.Select then
					element:Select(data.value)
				end
			end,
		},
		Input = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element and element.Set then
					element:Set(data.value)
				end
			end,
		},
		Keybind = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element and element.Set then
					element:Set(data.value)
				end
			end,
		},
		Slider = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value.Default,
				}
			end,
			Load = function(element, data)
				if element and element.Set then
					element:Set(tonumber(data.value))
				end
			end,
		},
		Toggle = {
			Save = function(obj)
				return {
					__type = obj.__type,
					value = obj.Value,
				}
			end,
			Load = function(element, data)
				if element and element.Set then
					element:Set(data.value)
				end
			end,
		},
	},
}

function ConfigManager:Init(WindowTable)
	if not WindowTable.Folder then
		warn("[ ATXUI.ConfigManager ] Window.Folder is not specified.")
		return false
	end
	if RunService:IsStudio() or not writefile then
		warn("[ ATXUI.ConfigManager ] The config system doesn't work in the studio.")
		return false
	end

	Window = WindowTable
	ConfigManager.Folder = Window.Folder
	ConfigManager.Path = "ATXUI/" .. tostring(ConfigManager.Folder) .. "/config/"

	-- Strip trailing slash when passing to isfolder/makefolder — some executors
	-- (Velocity, Wave on PC) reject or silently fail on paths with trailing slash.
	local function stripTrailingSlash(p)
		if type(p) ~= "string" then
			return p
		end
		while #p > 0 and (p:sub(-1) == "/" or p:sub(-1) == "\\") do
			p = p:sub(1, -2)
		end
		return p
	end
	local function safeMakeFolder(path)
		path = stripTrailingSlash(path)
		if not path or path == "" then
			return false
		end
		local okIs, exists = pcall(isfolder, path)
		if okIs and exists then
			return true
		end
		local okMk, errMk = pcall(makefolder, path)
		if not okMk then
			warn(
				"[ ATXUI.ConfigManager ] Failed to create folder '"
					.. tostring(path)
					.. "': "
					.. tostring(errMk)
			)
			return false
		end
		return true
	end

	-- Ensure parents exist before the deepest folder (some executors require this).
	safeMakeFolder("ATXUI")
	safeMakeFolder("ATXUI/" .. tostring(ConfigManager.Folder))
	safeMakeFolder(ConfigManager.Path)

	local files = ConfigManager:AllConfigs()

	for _, f in next, files do
		if isfile and readfile and isfile(f .. ".json") then
			ConfigManager.Configs[f] = readfile(f .. ".json")
		end
	end

	return ConfigManager
end

function ConfigManager:SetPath(customPath)
	if not customPath then
		warn("[ ATXUI.ConfigManager ] Custom path is not specified.")
		return false
	end

	ConfigManager.Path = customPath
	if not customPath:match("/$") then
		ConfigManager.Path = customPath .. "/"
	end

	-- Strip trailing slash when calling makefolder/isfolder (some executors fail on it).
	local folderPath = ConfigManager.Path
	while #folderPath > 0 and (folderPath:sub(-1) == "/" or folderPath:sub(-1) == "\\") do
		folderPath = folderPath:sub(1, -2)
	end

	local okIs, exists = pcall(isfolder, folderPath)
	if not (okIs and exists) then
		local okMk, errMk = pcall(makefolder, folderPath)
		if not okMk then
			warn(
				"[ ATXUI.ConfigManager ] Failed to create folder '"
					.. tostring(folderPath)
					.. "': "
					.. tostring(errMk)
			)
			return false
		end
	end

	return true
end

function ConfigManager:CreateConfig(configFilename, autoload)
	local ConfigModule = {
		Path = ConfigManager.Path .. configFilename .. ".json",
		Elements = {},
		CustomData = {},
		AutoLoad = autoload or false,
		Version = 1.2,
	}

	if not configFilename then
		return false, "No config file is selected"
	end

	function ConfigModule:SetAsCurrent()
		Window:SetCurrentConfig(ConfigModule)
	end

	function ConfigModule:Register(Name, Element)
		ConfigModule.Elements[Name] = Element
	end

	function ConfigModule:Set(key, value)
		ConfigModule.CustomData[key] = value
	end

	function ConfigModule:Get(key)
		return ConfigModule.CustomData[key]
	end

	function ConfigModule:SetAutoLoad(Value)
		ConfigModule.AutoLoad = Value
	end

	function ConfigModule:Save()
		if Window.PendingFlags then
			for flag, element in next, Window.PendingFlags do
				ConfigModule:Register(flag, element)
			end
		end

		local saveData = {
			__version = ConfigModule.Version,
			__elements = {},
			__autoload = ConfigModule.AutoLoad,
			__custom = ConfigModule.CustomData,
		}

		for name, element in next, ConfigModule.Elements do
			if ConfigManager.Parser[element.__type] then
				saveData.__elements[tostring(name)] = ConfigManager.Parser[element.__type].Save(element)
			end
		end

		local jsonData = HttpService:JSONEncode(saveData)
		if writefile then
			local okWrite, errWrite = pcall(writefile, ConfigModule.Path, jsonData)
			if not okWrite then
				warn(
					"[ ATXUI.ConfigManager ] Failed to write config '"
						.. tostring(ConfigModule.Path)
						.. "': "
						.. tostring(errWrite)
				)
			end
		end

		return saveData
	end

	function ConfigModule:Load()
		if isfile and not isfile(ConfigModule.Path) then
			return false, "Config file does not exist"
		end

		local success, loadData = pcall(function()
			local readfile = readfile
				or function()
					warn("[ ATXUI.ConfigManager ] The config system doesn't work in the studio.")
					return nil
				end
			return HttpService:JSONDecode(readfile(ConfigModule.Path))
		end)

		if not success then
			return false, "Failed to parse config file"
		end

		if not loadData.__version then
			local migratedData = {
				__version = ConfigModule.Version,
				__elements = loadData,
				__custom = {},
			}
			loadData = migratedData
		end

		if Window.PendingFlags then
			for flag, element in next, Window.PendingFlags do
				ConfigModule:Register(flag, element)
			end
		end

		for name, data in next, (loadData.__elements or {}) do
			if ConfigModule.Elements[name] and ConfigManager.Parser[data.__type] then
				task.spawn(function()
					ConfigManager.Parser[data.__type].Load(ConfigModule.Elements[name], data)
				end)
			end
		end

		ConfigModule.CustomData = loadData.__custom or {}

		return ConfigModule.CustomData
	end

	function ConfigModule:Delete()
		if not delfile then
			return false, "delfile function is not available"
		end

		if not isfile(ConfigModule.Path) then
			return false, "Config file does not exist"
		end

		local success, err = pcall(function()
			delfile(ConfigModule.Path)
		end)

		if not success then
			return false, "Failed to delete config file: " .. tostring(err)
		end

		ConfigManager.Configs[configFilename] = nil

		if Window.CurrentConfig == ConfigModule then
			Window.CurrentConfig = nil
		end

		return true, "Config deleted successfully"
	end

	function ConfigModule:GetData()
		return {
			elements = ConfigModule.Elements,
			custom = ConfigModule.CustomData,
			autoload = ConfigModule.AutoLoad,
		}
	end

	if isfile(ConfigModule.Path) then
		local success, configData = pcall(function()
			return HttpService:JSONDecode(readfile(ConfigModule.Path))
		end)

		if success and configData and configData.__autoload then
			ConfigModule.AutoLoad = true

			task.spawn(function()
				task.wait(0.5)
				local success, result = pcall(function()
					return ConfigModule:Load()
				end)
				if success then
					if Window.Debug then
						print("[ ATXUI.ConfigManager ] AutoLoaded config: " .. configFilename)
					end
				else
					warn(
						"[ ATXUI.ConfigManager ] Failed to AutoLoad config: "
							.. configFilename
							.. " - "
							.. tostring(result)
					)
				end
			end)
		end
	end

	ConfigModule:SetAsCurrent()
	ConfigManager.Configs[configFilename] = ConfigModule
	return ConfigModule
end

function ConfigManager:Config(configFilename, autoload)
	return ConfigManager:CreateConfig(configFilename, autoload)
end

function ConfigManager:GetAutoLoadConfigs()
	local autoloadConfigs = {}

	for configName, configModule in pairs(ConfigManager.Configs) do
		if configModule.AutoLoad then
			table.insert(autoloadConfigs, configName)
		end
	end

	return autoloadConfigs
end

function ConfigManager:DeleteConfig(configName)
	if not delfile then
		return false, "delfile function is not available"
	end

	local configPath = ConfigManager.Path .. configName .. ".json"

	if not isfile(configPath) then
		return false, "Config file does not exist"
	end

	local success, err = pcall(function()
		delfile(configPath)
	end)

	if not success then
		return false, "Failed to delete config file: " .. tostring(err)
	end

	ConfigManager.Configs[configName] = nil

	if Window.CurrentConfig and Window.CurrentConfig.Path == configPath then
		Window.CurrentConfig = nil
	end

	return true, "Config deleted successfully"
end

function ConfigManager:AllConfigs()
	if not listfiles then
		return {}
	end

	local files = {}
	local folderPath = ConfigManager.Path
	if type(folderPath) == "string" then
		while #folderPath > 0 and (folderPath:sub(-1) == "/" or folderPath:sub(-1) == "\\") do
			folderPath = folderPath:sub(1, -2)
		end
	end
	local okIs, exists = pcall(isfolder, folderPath)
	if not (okIs and exists) then
		local okMk = pcall(makefolder, folderPath)
		if not okMk then
			return files
		end
		return files
	end

	local okList, listed = pcall(listfiles, ConfigManager.Path)
	if not okList or not listed then
		return files
	end
	for _, file in next, listed do
		local name = file:match("([^\\/]+)%.json$")
		if name then
			table.insert(files, name)
		end
	end

	return files
end

function ConfigManager:GetConfig(configName)
	return ConfigManager.Configs[configName]
end

return ConfigManager
