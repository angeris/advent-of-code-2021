const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input9.txt", .{});
    defer file.close();

    var reader = file.reader();

    var linesize: ?usize = null;
    var digitsall: [1_000_000]u8 = undefined;

    var idx: usize = 0;
    var buf: [100]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (linesize == null) {
            linesize = line.len;
        }
        for (line) |v| {
            digitsall[idx] = v - '0';
            idx += 1;
        }
    }

    var digits = digitsall[0..idx];

    const len = linesize.?;
    var total: usize = 0;
    for (digits) |d, i| {
        var hpos = i % len;
        if (hpos + 1 < len and i+1 < digits.len and digits[i+1] <= d)
            continue;
        if (hpos > 0 and i > 0 and digits[i-1] <= d)
            continue;
        if (i + len < digits.len and digits[i+len] <= d)
            continue;
        if (i >= len and digits[i-len] <= d)
            continue;
        
        total += d + 1;
    }

    print("total {}\n", .{total});
}