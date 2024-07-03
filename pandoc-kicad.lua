local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
      io.close(f)
      return true
    else
      return false
    end
end

local function get_file_name(url)
  return url:match("^.+/(.+)%..+$")
end

local function get_file_extension(url)
  return url:match("^.+(%..+)$")
end

function Link(el)
    if not file_exists(el.target) then
        return nil
    end

    local file_extension = get_file_extension(el.target)
    local file_type
    local export_options
    if file_extension == ".kicad_sch" then
      file_type = "sch"
      export_options = {"-e"}
    elseif file_extension == ".kicad_pcb" then
      file_type = "pcb"
      export_options = {"--page-size-mode"}
    else
      return nil
    end
    -- TODO: support for sym and fp files


    local fileName = get_file_name(el.target)
    local outputPath = "/home/ferran/Development/pandoc-kicad/"

    local args = {file_type, "export", "svg", "-o", outputPath, el.target}
    for _, a in ipairs(export_options) do
      table.insert(args, a)
    end

    pandoc.pipe("kicad-cli", args, "")
    return pandoc.Image(el.content, outputPath .. fileName .. ".svg", fileName, el.attr)
end