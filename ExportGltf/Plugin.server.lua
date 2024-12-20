local GltfExporter = require(script.Parent.Source.Gltf.GltfExporter)

local HttpService = game:GetService("HttpService")

local CHUNK_LENGTH = 20000
local SERVER_ADDRESS = "http://localhost:8080"

local function exportWorkspace()
	print("Exporting Workspace...")
	local exporter = GltfExporter.new()
	exporter:populateScene("Workspace", game.Workspace)
	
	local result = exporter:WriteToJson()
	
	local chunkCount = math.ceil(string.len(result) / CHUNK_LENGTH)
	print(chunkCount)
	
	for i = 1, chunkCount do
		local chunk = string.sub(result, (i - 1) * CHUNK_LENGTH + 1, i * CHUNK_LENGTH)
		HttpService:PostAsync(SERVER_ADDRESS, chunk, Enum.HttpContentType.TextPlain, false, {chunkType = "content"})
	end
	
	HttpService:PostAsync(SERVER_ADDRESS, "n/a", Enum.HttpContentType.TextPlain, false, {chunkType = "complete"})
	
	exporter:Destroy()
	
	print("Done")
end

local toolbar = plugin:CreateToolbar("Export")
local button = toolbar:CreateButton("Export To glTF", "Exports your scene to a script file in game.ServerStorage", "")

button.Click:Connect(exportWorkspace)