const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input6.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [1000]u8 = undefined;

    var line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var tokens = std.mem.tokenize(u8, line, ",");

    var curr_num: [9]u64 = .{0}**9;
    var prev_num: [9]u64 = .{0}**9;

    while (tokens.next()) |token| {
        var idx: u8 = try std.fmt.parseInt(u8, token, 0);
        curr_num[idx] += 1;
    }

    var days: u32 = 0;
    // XXX: Change this next line for d6-2
    while (days < 32) : (days += 1) {
        std.mem.copy(u64, &prev_num, &curr_num);
        for (curr_num) |_, i| {
            curr_num[i] = 0;
        }
        // Propagate all 0s
        curr_num[8] += prev_num[0];
        curr_num[6] += prev_num[0];
        // Move everything by 1
        for (prev_num) |n, i| {
            if (i==0) continue;
            curr_num[i-1] += n;
        }
    }

    var total: u64 = 0;
    for (curr_num) |num| {
        total += num;
    }

    print("total {}\n", .{total});
}
