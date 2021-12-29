const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input2.txt", .{});
    defer file.close();

    var reader = file.reader();

    var buf: [4096]u8 = undefined;

    var hpos: u32 = 0;
    var ypos: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splitter = std.mem.tokenize(u8, line, " ");

        var move = splitter.next().?;
        var amount = try std.fmt.parseInt(u32, splitter.next().?, 0);

        if (std.mem.eql(u8, move, "forward")) {
            hpos += amount;
        } else if (std.mem.eql(u8, move, "backward")) {
            hpos -= amount;
        } else if (std.mem.eql(u8, move, "down")) {
            ypos += amount;
        } else {
            ypos -= amount;
        }
    }

    print("prod {}", .{hpos*ypos});
}