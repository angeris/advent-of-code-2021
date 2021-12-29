const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input3.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [50]u8 = undefined;

    var total: i32 = 0;
    const digitcount: u5 = 12;
    var digitamount: [digitcount]u32 = .{0} ** digitcount;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        total += 1;
        for (line) |c, idx| {
            digitamount[idx] += @boolToInt(c == '1');
        }
    }

    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    for (digitamount) |d, idx| {
        var res: u32 = @boolToInt(2*d > total);
        var i: u5 = @intCast(u5, idx);
        gamma += res<<(digitcount - i - 1);
        epsilon += (1-res)<<(digitcount - i - 1);
    }

    print("gamma*epsilon: {}\n", .{gamma*epsilon});
}