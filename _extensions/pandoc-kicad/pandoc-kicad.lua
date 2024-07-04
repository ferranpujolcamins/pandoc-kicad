local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function Link(el)
  if not file_exists(el.target) then
    return nil
  end

  local file_path, file_extension = pandoc.path.split_extension(el.target)
  local file_name = table.remove(pandoc.path.split(file_path))
  local output_path = pandoc.path.directory(PANDOC_STATE.output_file) .. pandoc.path.separator


  local file_type
  local export_options
  if file_extension == ".kicad_sch" then
    file_type = "sch"
    export_options = { "-e" }
  elseif file_extension == ".kicad_pcb" then
    file_type = "pcb"
    export_options = { "--page-size-mode" }
  else
    return nil
  end
  -- TODO: support for sym and fp files

  local args = { file_type, "export", "svg", "-o", output_path, el.target }
  for _, a in ipairs(export_options) do
    table.insert(args, a)
  end

  pandoc.pipe("kicad-cli", args, "")
  return pandoc.Image(el.content, file_name .. ".svg", file_name, el.attr)
end
