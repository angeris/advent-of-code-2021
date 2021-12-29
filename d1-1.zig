const std = @import("std");
const os = std.os;
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input1.txt", .{});
    defer file.close();

    var reader = file.reader();

    var buf: [4096]u8 = undefined;

    var prev: ?u32 = null;
    var curr: u32 = undefined;

    var total: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        curr = try std.fmt.parseInt(u32, line, 0);
        if (prev != null) {
            total += @boolToInt(curr > prev.?);
        }
        prev = curr;
    }

    print("Total increases {}\n", .{total});
}