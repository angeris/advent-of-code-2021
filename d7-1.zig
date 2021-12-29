const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input7.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [10000]u8 = undefined;

    var line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var tokens = std.mem.tokenize(u8, line, ",");

    const MaxPosLen = 1000;
    var allpositions: [MaxPosLen]i64 = undefined;
    var lastpos: usize = 0;
    while (tokens.next()) |token| {
        std.debug.assert(lastpos < MaxPosLen);
        allpositions[lastpos] = try std.fmt.parseInt(i64, token, 0);
        lastpos += 1;
    }

    var positions = allpositions[0..lastpos];
    std.sort.sort(i64, positions, {}, comptime std.sort.asc(i64));
    var median = positions[(positions.len - 1)/2];

    var totalfuel: u64 = 0;
    for (positions) |p| {
        totalfuel += @intCast(u64, try std.math.absInt(p - median));
    }
    print("total: {}\n", .{totalfuel});
}