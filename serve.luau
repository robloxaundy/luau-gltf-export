local net = require("@lune/net")
local fs = require("@lune/fs")
local task = require("@lune/task")

local currentFile = {}

local function writeFile()
    fs.writeFile("scene.gltf", table.concat(currentFile))
    currentFile = {}
    print("File written")
end

local handle
local stopped = true

local function startServe()
    stopped = false
    handle = net.serve(8080, function(request)
        if request.method == "POST" then
            if request.headers.chunktype == "content" then
                table.insert(currentFile, request.body)
                return { status = 200, body = "Content added"}
            elseif request.headers.chunktype == "complete" then
                writeFile()
                stopped = true
                handle:stop()
                return { status = 200, body = "File written"}
            else
                print("fail")
                return { status = 400, body = "Unkown chunktype"}
            end
        else
            print("fail")
            return {
                status = 400,
                body = "Method not allowed"
            }
        end
    end)
end

-- this sucks so bad, but it's the only way I can keep the thing from never returning after writing the file (lune plz fix)
while true do
    if stopped then
        startServe()
        print("Server running on http://localhost:8080")
    end
    task.wait(1)
end