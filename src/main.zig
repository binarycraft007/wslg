const std = @import("std");
const mem = std.mem;
const posix = std.posix;

pub fn main() !void {
    var buf: [4096 * 4]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    if (posix.argv.len != 3) {
        usage();
    }
    const operation = std.mem.span(posix.argv[1]);
    const uid = std.mem.span(posix.argv[2]);
    if (std.mem.eql(u8, operation, "start")) {
        try wslgStart(uid, fba.allocator());
    } else if (std.mem.eql(u8, operation, "stop")) {
        try wslgStop(uid, fba.allocator());
    } else {
        usage();
    }
}

fn usage() void {
    const usageMsg =
        \\usage: {s} <operations> <UID>
        \\operations:
        \\    start <UID>
        \\    stop <UID>
        \\
    ;
    std.debug.print(usageMsg, .{posix.argv[0]});
    std.posix.exit(1);
}

fn isAccessOk(path: []const u8) bool {
    posix.access(path, posix.F_OK) catch |err| {
        std.log.warn("access file {s} {}", .{ path, err });
        return false;
    };
    return true;
}

fn wslgStop(uid: []const u8, gpa: mem.Allocator) !void {
    inline for (symlinkMap) |symlink| {
        const target = try symlink.target.path(.{ .uid = uid, .gpa = gpa });
        if (isAccessOk(target)) {
            posix.unlink(target) catch |err| {
                std.log.err("delete symlink {}: {}", .{ symlink, err });
            };
        }
    }
}

fn wslgStart(uid: []const u8, gpa: mem.Allocator) !void {
    inline for (symlinkMap) |symlink| {
        const source = try symlink.source.path(.{ .uid = uid, .gpa = gpa });
        const target = try symlink.target.path(.{ .uid = uid, .gpa = gpa });
        if (!isAccessOk(target)) {
            posix.symlink(source, target) catch |err| {
                std.log.err("create symlink {}: {}", .{ symlink, err });
            };
        }
    }
}

const Path = struct {
    dir: []const u8,
    file: []const u8,
    need_uid: bool = false,

    const PathOptions = struct {
        uid: []const u8,
        gpa: mem.Allocator,
    };

    pub fn path(self: Path, options: PathOptions) ![]const u8 {
        if (self.need_uid) {
            return try std.fs.path.join(
                options.gpa,
                &.{ self.dir, options.uid, self.file },
            );
        }
        return try std.fs.path.join(options.gpa, &.{ self.dir, self.file });
    }
};

const SymlinkMap = struct {
    source: Path,
    target: Path,
    need_uid: bool = false,
};

const symlinkMap = [_]SymlinkMap{
    .{
        .source = .{ .dir = "/mnt/wslg/.X11-unix", .file = "X0" },
        .target = .{ .dir = "/tmp/.X11-unix", .file = "X0" },
    },
    .{
        .source = .{ .dir = "/mnt/wslg/runtime-dir", .file = "wayland-0" },
        .target = .{ .dir = "/run/user", .file = "wayland-0", .need_uid = true },
    },
    .{
        .source = .{ .dir = "/mnt/wslg/runtime-dir", .file = "wayland-0.lock" },
        .target = .{ .dir = "/run/user", .file = "wayland-0.lock", .need_uid = true },
    },
};
