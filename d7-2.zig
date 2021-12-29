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
    var maxpos: i64 = 0;
    while (tokens.next()) |token| {
        std.debug.assert(lastpos < MaxPosLen);
        var currpos = try std.fmt.parseInt(i64, token, 0);
        allpositions[lastpos] = currpos;
        if (currpos > maxpos) {
            maxpos = currpos;
        }
        lastpos += 1;
    }

    var positions = allpositions[0..lastpos];

    var minfuel: i64 = std.math.maxInt(i64);

    var p: i64 = 0;
    while (p < maxpos) : (p += 1) {
        var fuel: i64 = 0;
        for (positions) |q| {
            fuel += @divFloor((p-q)*(p-q) + try std.math.absInt(p-q), 2);
        }
        if (fuel < minfuel) {
            minfuel = fuel;
        }
    }

    print("total: {}\n", .{minfuel});
}
