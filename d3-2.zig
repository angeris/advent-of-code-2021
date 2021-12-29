const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input-sketch.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [50]u8 = undefined;

    var allstrings: [1000][12]u8 = undefined;
    var allstrings2: [1000][12]u8 = undefined;
    var idx: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.mem.copy(u8, &allstrings[idx], std.mem.span(line));
        allstrings[idx][line.len] = 0;
        std.mem.copy(u8, &allstrings2[idx], std.mem.span(line));
        allstrings2[idx][line.len] = 0;
        idx += 1;
    }

    var cstrings: [][12]u8 = allstrings[0..idx];
    var cstrings2: [][12]u8 = allstrings2[0..idx];

    idx = 0;
    while (cstrings.len > 1) : (idx += 1) {
        var most = findmost(cstrings, idx);
        cstrings = keep(cstrings, idx, most);
    }

    idx = 0;
    while (cstrings2.len > 1) : (idx += 1) {
        var least: u8 = if (findmost(cstrings2, idx) == '0') '1' else '0';
        cstrings2 = keep(cstrings2, idx, least);
    }

    var oxygen = try std.fmt.parseInt(u32, std.mem.sliceTo(&cstrings[0], 0), 2);
    print("oxygen {}\n", .{oxygen});
    var co2 = try std.fmt.parseInt(u32, std.mem.sliceTo(&cstrings2[0], 0), 2);
    print("co2 {}\n", .{co2});

    print("final {}\n", .{oxygen*co2});
}

fn keep(str: [][12]u8, idx: usize, which: u8) [][12]u8 {
    var lastidx: usize = 0;

    for (str) |elem| {
        if (elem[idx] == which) {
            str[lastidx] = elem;
            lastidx += 1;
        }
    }

    return str[0..lastidx];
}

fn findmost(str: [][12]u8, idx: usize) u8 {
    var count: u32 = 0;
    for (str) |s| {
        count += @boolToInt(s[idx] == '1');
    }
    if (2*count >= str.len) {
        return '1';
    }
    return '0';
}

