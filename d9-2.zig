const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    // var file = try std.fs.cwd().openFile("data/input-sketch.txt", .{});
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
    var largest: [3]usize = undefined;
    for (largest) |_, i| {
        largest[i] = 0;
    }

    var exploredall: [1_000_000]bool = undefined;
    var explored = exploredall[0..idx];
    for (explored) |_, id| {
        explored[id] = false;
    }

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

        var size = findBasin(digits, i, len, explored);

        for (explored) |_, id| {
            explored[id] = false;
        }

        if (size > largest[0]) {
            largest[2] = largest[1];
            largest[1] = largest[0];
            largest[0] = size;
        } else if (size > largest[1]) {
            largest[2] = largest[1];
            largest[1] = size;
        } else if (size > largest[2]) {
            largest[2] = size;
        }
    }

    print("total {}\n", .{largest[0]*largest[1]*largest[2]});
}

fn findBasin(d: []const u8, i: usize, len: usize, explored: []bool) u32 {
    if (explored[i] or d[i] >= 9) return 0;
    explored[i] = true;

    var hpos = i % len;
    const v = d[i];

    var total: u32 = 1;

    if (hpos + 1 < len and i+1 < d.len and d[i+1] >= v) {
        total += findBasin(d, i+1, len, explored);
    }
    if (hpos > 0 and d[i-1] >= v) {
        total += findBasin(d, i-1, len, explored);
    }
    if (i + len < d.len and d[i+len] >= v) {
        total += findBasin(d, i+len, len, explored);
    }
    if (i >= len and d[i-len] >= v) {
        total += findBasin(d, i-len, len, explored);
    }

    return total;
}
