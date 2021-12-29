const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input5.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [50]u8 = undefined;
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const alloc = gpa.allocator();

    var alllines = try ArrayList([]u64).initCapacity(alloc, 1000);
    defer alllines.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parsedline = try parseLine(alloc, line);
        if (isAxisAligned(parsedline))
            try alllines.append(parsedline);
    }
    
    var points = try alloc.alloc([]u64, 1000);
    for (points) |_, i| {
        points[i] = try alloc.alloc(u64, 1000);
        for (points[i]) |_, j| {
            points[i][j] = 0;
        }
    }

    for (alllines.items) |line| {
        if (line[0] == line[2]) {
            var y: usize = std.math.min(line[1], line[3]);
            const max = std.math.max(line[1], line[3]);
            while (y <= max) : (y += 1) {
                points[line[0]][y] += 1;
            }
        } else {
            var x: usize = std.math.min(line[0], line[2]);
            const max = std.math.max(line[0], line[2]);
            while (x <= max) : (x += 1) {
                points[x][line[1]] += 1;
            }
        }
    }

    var total: usize = 0;
    for (points) |line| {
        for (line) |n| {
            if (n > 1) {
                total += 1;
            }
        }
    }
    
    print("total amount {}\n", .{total});
}

fn isAxisAligned(line: []const u64) bool {
    return (line[0] == line[2]) or (line[1] == line[3]);
}

fn parseLine(alloc: std.mem.Allocator, line: []const u8) ![]u64 {
    var tokens = std.mem.tokenize(u8, line, " ");

    var nums = try ArrayList(u64).initCapacity(alloc, 4);
    try parsePair(&nums, tokens.next().?);
    _ = tokens.next();
    try parsePair(&nums, tokens.next().?);

    return nums.toOwnedSlice();
}

fn parsePair(nums: *ArrayList(u64), buf: []const u8) !void {
    var tokens = std.mem.tokenize(u8, buf, ",");
    try nums.append(try std.fmt.parseInt(u64, tokens.next().?, 0));
    try nums.append(try std.fmt.parseInt(u64, tokens.next().?, 0));
}


fn in(arr: ArrayList([]u64), elem: []u64) bool {
    for (arr) |e| {
        if (std.mem.eql(u64, e, elem)) {
            return true;
        }
    }
    return false;
}
