local helpers = {}

helpers.left_bar = "\u{258F}" -- ▏
helpers.right_bar = "\u{2595}" -- ▕

function helpers.get_last_segment(str)
  return string.match(str, "([^/\\]+)$") or str
end

function helpers.get_project_dirs()
  local home = os.getenv("HOME")
  return {
    home .. "/projects",
    home .. "/work",
    -- Add more project directories here
  }
end

return helpers