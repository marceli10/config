local mason_path = vim.fn.stdpath 'data' .. '/mason'

local environments = {
    [21] = 'JavaSE-21',
    [25] = 'JavaSE-25',
}

local function newer(a, b)
    local va, vb = vim.version.parse(a, { strict = false }), vim.version.parse(b, { strict = false })
    if va and vb then
        return vim.version.gt(va, vb)
    end
    return a > b
end

local function java_runtimes()
    local newest = {}
    for _, root in ipairs {
        '/Library/Java/JavaVirtualMachines',
        vim.fn.expand '~/Library/Java/JavaVirtualMachines',
    } do
        for entry in vim.fs.dir(root) do
            local home = ('%s/%s/Contents/Home'):format(root, entry)
            local release = io.open(home .. '/release')
            local version
            if release then
                version = release:read('*a'):match 'JAVA_VERSION="([%d%._]+)"'
                release:close()
            elseif vim.uv.fs_stat(home .. '/bin/java') then
                version = entry:match '(%d[%d%._]*)'
            end
            local major = tonumber(version and (version:match '^1%.(%d+)' or version:match '^(%d+)'))
            local name = major and environments[major]
            if name and (not newest[name] or newer(version, newest[name].version)) then
                newest[name] = { path = home, version = version }
            end
        end
    end

    local runtimes = {}
    for name, runtime in pairs(newest) do
        runtimes[#runtimes + 1] = { name = name, path = runtime.path }
    end
    return runtimes
end

local function bundles()
    local debug_glob = mason_path .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar'
    local jars = vim.fn.glob(debug_glob, false, true)
    return vim.list_extend(jars, vim.fn.glob(mason_path .. '/share/java-test/*.jar', false, true))
end

local cmd = { vim.fn.exepath 'jdtls', '--jvm-arg=-javaagent:' .. mason_path .. '/share/jdtls/lombok.jar' }
for _, arg in ipairs {
    '-Djava.import.generatesMetadataFilesAtProjectRoot=false',
    '-XX:+UseParallelGC',
    '-XX:GCTimeRatio=4',
    '-XX:AdaptiveSizePolicyWeight=90',
    '-Dsun.zip.disableMemoryMapping=true',
    '-Xmx2G',
} do
    cmd[#cmd + 1] = '--jvm-arg=' .. arg
end

local runtimes = java_runtimes()
local gradle_java_home
for _, runtime in ipairs(runtimes) do
    if runtime.name == 'JavaSE-21' then
        gradle_java_home = runtime.path
    end
end

---@type vim.lsp.Config
return {
    cmd = cmd,
    init_options = {
        bundles = bundles(),
    },
    settings = {
        java = {
            format = { enabled = true },
            inlayHints = {
                parameterNames = { enabled = 'all' },
            },
            completion = {
                importOrder = { 'java', 'javax', 'jakarta', 'org', 'com', '' },
            },
            configuration = {
                updateBuildConfiguration = 'automatic',
                runtimes = runtimes,
            },
            import = {
                gradle = { java = { home = gradle_java_home } },
            },
            autobuild = { enabled = true },
            saveActions = { organizeImports = true },
            referencesCodeLens = { enabled = true },
        },
    },
}
