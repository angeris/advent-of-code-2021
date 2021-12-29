const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input1.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [4096]u8 = undefined;

    var vals: [3]u32 = .{0} ** 3;
    var curridx: u32 = 0;

    var prevsum: u32 = 0;
    var complete: bool = false;

    var totalincrease: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        vals[curridx] = try std.fmt.parseInt(u32, line, 0);
        curridx = (curridx + 1) % 3;
        if (!complete and curridx == 0) {
            prevsum = sum(vals);
            complete = true;
            continue;
        }
        if (!complete) {
            continue;
        }
        var currsum = sum(vals);
        if (currsum > prevsum) {
            totalincrease += 1;
        }
        prevsum = currsum;
    }
    print("total {}\n", .{totalincrease});
}

fn sum(vals: [3]u32) u32 {
    return vals[0] + vals[1] + vals[2];
}