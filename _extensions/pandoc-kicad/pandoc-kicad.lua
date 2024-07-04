local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- attribute constants
local include_link <const> = "include_link"
local above <const> = "above"
local below <const> = "below"
local ignore <const> = "ignore"

local function extract_kicad_attributes(el_attr_attributes)
  local kicad_attribures = {}
  for k, v in pairs(el_attr_attributes) do
    if k == include_link or k == ignore then
      kicad_attribures[k] = v
      el_attr_attributes[k] = nil
    end
  end
  return kicad_attribures
end

local function get_output_path()
  if not PANDOC_STATE.output_file then
    return pandoc.system.get_working_directory() .. pandoc.path.separator
  end
  return pandoc.path.directory(PANDOC_STATE.output_file) .. pandoc.path.separator
end

local function get_filetype_and_export_options(file_extension)
  if file_extension == ".kicad_sch" then
    return "sch", { "-e" }
  elseif file_extension == ".kicad_pcb" then
    return "pcb", { "--page-size-mode" }
  else
    return nil, nil
  end
  -- TODO: support for sym and fp files
end

local function export_svg(file_type, output_path, file_path, export_options)
  local args = { file_type, "export", "svg", "-o", output_path, file_path }
  for _, a in ipairs(export_options) do
    table.insert(args, a)
  end
  pandoc.pipe("kicad-cli", args, "")
end

function Link(el)
  local kicad_attribures = extract_kicad_attributes(el.attr.attributes)

  if not file_exists(el.target) then
    return el
  end

  if kicad_attribures[ignore] then
    return el
  end

  local file_path, file_extension = pandoc.path.split_extension(el.target)
  local file_name = table.remove(pandoc.path.split(file_path))

  local file_type, export_options = get_filetype_and_export_options(file_extension)
  if not file_type then
    return el
  end

  export_svg(file_type, get_output_path(), el.target, export_options)

  return {
    kicad_attribures[include_link] == above and el or "",
    pandoc.Image(el.content, file_name .. ".svg", file_name, el.attr),
    kicad_attribures[include_link] == below and el or "",
  }
end
