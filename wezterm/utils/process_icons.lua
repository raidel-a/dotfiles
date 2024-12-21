local wezterm = require("wezterm")

local function dev_icon(name)
    return wezterm.nerdfonts["dev_" .. name]
end

local function custom_icon(name)
    return wezterm.nerdfonts["custom_" .. name]
end


local process_and_extensions = {
    {'nvim', '.vim'},
    {'nvim', '.lua'},
    {'node', '.js'},
    {'python', '.py'},
    {'ruby', '.rb'},
    {'java', '.java'},
    {'html', '.html'},
    {'css', '.css'},
    {'rust', '.rs'},
    {'go', '.go'},
    {'php', '.php'},
    {'swift', '.swift'},
    {'typescript', '.ts'},
    {'c', '.c'},
    {'cpp', '.cpp'},
    {'csharp', '.cs'},
    {'scala', '.scala'},
    {'kotlin', '.kt'},
    {'markdown', '.md'},
}

local process_icons = {
    -- Development environments and tools
    ["nvim"] = custom_icon("vim"),
    ["vim"] = dev_icon("vim"),
    ["code"] = dev_icon("code"),
    ["sublime"] = dev_icon("sublime"),
    ["atom"] = dev_icon("atom"),
    ["intellij"] = dev_icon("intellij"),
    ["eclipse"] = dev_icon("eclipse"),
    ["visual studio"] = dev_icon("visualstudio"),

    -- Programming languages
    ["node"] = dev_icon("nodejs_small"),
    ["python"] = dev_icon("python"),
    ["ruby"] = dev_icon("ruby"),
    ["java"] = dev_icon("java"),
    ["scala"] = dev_icon("scala"),
    ["go"] = dev_icon("go"),
    ["rust"] = dev_icon("rust"),
    ["swift"] = dev_icon("swift"),
    ["lua"] = dev_icon("lua"),
    ["perl"] = dev_icon("perl"),
    ["php"] = dev_icon("php"),
    ["csharp"] = dev_icon("dotnet"),
    ["fsharp"] = dev_icon("fsharp"),
    ["clojure"] = dev_icon("clojure"),
    ["haskell"] = dev_icon("haskell"),
    ["erlang"] = dev_icon("erlang"),

    -- Shell and terminal
    ["zsh"] = wezterm.nerdfonts.oct_rel_file_path,
    ["bash"] = wezterm.nerdfonts.oct_rel_file_path,
    ["fish"] = wezterm.nerdfonts.oct_rel_file_path,
    ["powershell"] = wezterm.nerdfonts.oct_rel_file_path,

    -- Version control
    ["git"] = dev_icon("git"),
    ["svn"] = dev_icon("code_badge"),

    -- Databases
    ["mysql"] = dev_icon("mysql"),
    ["postgresql"] = dev_icon("postgresql"),
    ["mongodb"] = dev_icon("mongodb"),
    ["redis"] = dev_icon("redis"),

    -- Web technologies
    ["html"] = dev_icon("html5"),
    ["css"] = dev_icon("css3"),
    ["sass"] = dev_icon("sass"),
    ["less"] = dev_icon("less"),
    ["javascript"] = dev_icon("javascript"),
    ["typescript"] = dev_icon("javascript_badge"),
    ["angular"] = dev_icon("angular"),
    ["react"] = dev_icon("react"),
    ["vue"] = dev_icon("javascript_shield"),
    ["ember"] = dev_icon("ember"),

    -- Build tools and package managers
    ["npm"] = dev_icon("npm"),
    ["yarn"] = dev_icon("yarn"),
    ["gradle"] = dev_icon("gradle"),
    ["maven"] = dev_icon("code_badge"),

    -- Cloud and DevOps
    ["docker"] = dev_icon("docker"),
    ["kubernetes"] = dev_icon("kubernetes"),
    ["aws"] = dev_icon("aws"),
    ["azure"] = dev_icon("azure"),
    ["google cloud"] = dev_icon("google_cloud_platform"),

    -- Operating Systems
    ["linux"] = dev_icon("linux"),
    ["ubuntu"] = dev_icon("ubuntu"),
    ["debian"] = dev_icon("debian"),
    ["fedora"] = dev_icon("fedora"),
    ["centos"] = dev_icon("centos"),
    ["apple"] = dev_icon("apple"),
    ["windows"] = dev_icon("windows"),

    -- Miscellaneous
    ["spotify_player"] = wezterm.nerdfonts.md_spotify,
}

local custom_mappings = {}
local icon_cache = {}

local function add_custom_mapping(process, extension, icon)
    custom_mappings[extension] = {process, icon}
end

local function get_icon(process_name, file_extension)
    local cache_key = process_name .. (file_extension or "")
    if icon_cache[cache_key] then
        return icon_cache[cache_key]
    end

    local icon

    -- Check custom mappings first
    if file_extension and custom_mappings[file_extension] then
        icon = custom_mappings[file_extension][2]
    else
        -- Then check process_and_extensions
        for _, tuple in ipairs(process_and_extensions) do
            if tuple[2] == file_extension then
                icon = process_icons[tuple[1]]
                break
            end
        end
    end

    -- If still no icon, use process icon or default
    if not icon then
        icon = process_icons[process_name] or wezterm.nerdfonts.custom_v_lang
    end

    icon_cache[cache_key] = icon
    return icon
end

return {
    icons = process_icons,
    get_icon = get_icon,
    add_custom_mapping = add_custom_mapping
}
