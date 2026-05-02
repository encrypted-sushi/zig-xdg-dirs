const XdgDirs = @This();

const std = @import("std");

config_home: []const u8, // XDG_CONFIG_HOME  or ~/.config
data_home: []const u8, // XDG_DATA_HOME    or ~/.local/share
state_home: []const u8, // XDG_STATE_HOME   or ~/.local/state
cache_home: []const u8, // XDG_CACHE_HOME   or ~/.cache
runtime_dir: ?[]const u8, // XDG_RUNTIME_DIR  or null (not created)

pub fn init(io: std.Io, allocator: std.mem.Allocator, environ_map: *const std.process.Environ.Map) !XdgDirs {
    const home = environ_map.get("HOME") orelse return error.HomeDirNotSet;

    //XDG_CONFIG_HOME
    const config_home = if (environ_map.get("XDG_CONFIG_HOME")) |xdg|
        try allocator.dupe(u8, xdg)
    else
        try std.fmt.allocPrint(allocator, "{s}/.config", .{home});
    errdefer allocator.free(config_home); // only frees if we error out later in this function

    std.Io.Dir.createDirAbsolute(io, config_home, .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {}, // already there, that's fine
        else => return err, // something else went wrong
    };

    //XDG_DATA_HOME
    const data_home = if (environ_map.get("XDG_DATA_HOME")) |xdg|
        try allocator.dupe(u8, xdg)
    else
        try std.fmt.allocPrint(allocator, "{s}/.local/share", .{home});
    errdefer allocator.free(data_home); // only frees if we error out later in this function

    std.Io.Dir.createDirAbsolute(io, data_home, .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {}, // already there, that's fine
        else => return err, // something else went wrong
    };

    //XDG_STATE_HOME
    const state_home = if (environ_map.get("XDG_STATE_HOME")) |xdg|
        try allocator.dupe(u8, xdg)
    else
        try std.fmt.allocPrint(allocator, "{s}/.local/state", .{home});
    errdefer allocator.free(state_home); // only frees if we error out later in this function

    std.Io.Dir.createDirAbsolute(io, state_home, .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {}, // already there, that's fine
        else => return err, // something else went wrong
    };

    //XDG_CACHE_HOME
    const cache_home = if (environ_map.get("XDG_CACHE_HOME")) |xdg|
        try allocator.dupe(u8, xdg)
    else
        try std.fmt.allocPrint(allocator, "{s}/.cache", .{home});
    errdefer allocator.free(cache_home); // only frees if we error out later in this function

    std.Io.Dir.createDirAbsolute(io, cache_home, .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {}, // already there, that's fine
        else => return err, // something else went wrong
    };

    //XDG_RUNTIME_DIR
    const runtime_dir = if (environ_map.get("XDG_RUNTIME_DIR")) |xdg|
        try allocator.dupe(u8, xdg)
    else
        null;
    errdefer if (runtime_dir) |dir| allocator.free(dir);

    return XdgDirs{
        .config_home = config_home,
        .data_home = data_home,
        .state_home = state_home,
        .cache_home = cache_home,
        .runtime_dir = runtime_dir,
    };
}

pub fn deinit(self: XdgDirs, allocator: std.mem.Allocator) void {
    inline for (@typeInfo(XdgDirs).@"struct".fields) |field| {
        if (field.type == []const u8) {
            allocator.free(@field(self, field.name));
        }
    }
    if (self.runtime_dir) |dir| allocator.free(dir);
}

