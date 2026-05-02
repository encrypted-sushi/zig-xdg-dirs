# zig-xdg-dirs
XDG Base Directory Specification implementation for Zig 0.16.0. 
Resolves:
  - XDG_CONFIG_HOME
  - XDG_DATA_HOME
  - XDG_STATE_HOME
  - XDG_CACHE_HOME
  - XDG_RUNTIME_DIR

Other than XDG_RUNTIME_DIR, these will fallback defaults, and creates the directories if they don't exist.

## How to use this
```
const XdgDirs = @import("XdgDirs.zig");

pub fn main(init: std.process.Init) !void {
    const xdg = try XdgDirs.init(init.io, init.gpa, init.environ_map);
    defer xdg.deinit(init.gpa);
    
    // now use xdg.config_home, xdg.data_home, etc.
}
```

## Fields
- `config_home` — XDG_CONFIG_HOME or `~/.config`
- `data_home`   — XDG_DATA_HOME or `~/.local/share`
- `state_home`  — XDG_STATE_HOME or `~/.local/state`
- `cache_home`  — XDG_CACHE_HOME or `~/.cache`
- `runtime_dir` — XDG_RUNTIME_DIR or `null`

## Requirements
Zig 0.16.0 or later
