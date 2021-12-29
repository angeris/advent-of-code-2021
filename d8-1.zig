const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input8.txt", .{});
    defer file.close();

    var buf: [1000]u8 = undefined;
    var reader = file.reader();

    var totalnum: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        var pastpipe: bool = false;
        while (tokens.next()) |token| {
            if (!pastpipe) {
                if (std.mem.eql(u8, token, "|")) {
                    pastpipe = true;
                }
                continue;
            }
            if (token.len == 2
                or token.len == 3
                or token.len == 4
                or token.len == 7) {
                    totalnum += 1;
            }
        }
    }
    print("total num: {}\n", .{totalnum});
}