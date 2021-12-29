const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const math = std.math;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input5.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [50]u8 = undefined;
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const alloc = gpa.allocator();

    var alllines = try ArrayList([]i64).initCapacity(alloc, 1000);
    defer alllines.deinit();

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parsedline = try parseLine(alloc, line);
        try alllines.append(parsedline);
    }
    
    var points = try alloc.alloc([]i64, 1000);
    for (points) |_, i| {
        var arr = try alloc.alloc(i64, 1000);
        for (arr) |_, j| {
            arr[j] = 0;
        }
        points[i] = arr;
    }

    for (alllines.items) |line| {
        var curr_x = line[0];
        var curr_y = line[1];

        var step_x = signum(line[2] - line[0]);
        var step_y = signum(line[3] - line[1]);

        if (step_x != 0) {
            while (step_x*curr_x <= step_x*line[2]) {
                points[@intCast(usize, curr_x)][@intCast(usize, curr_y)] += 1;
                curr_x += step_x;
                curr_y += step_y;
            }
        } else if (step_y != 0) {
            while (step_y*curr_y <= step_y*line[3]) {
                points[@intCast(usize, curr_x)][@intCast(usize, curr_y)] += 1;
                curr_x += step_x;
                curr_y += step_y;
            }
        } else {
            points[@intCast(usize, curr_x)][@intCast(usize, curr_y)] += 1;
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

fn signum(n: i64) i64 {
    if (n > 0) {
        return 1;
    } else if (n < 0) {
        return -1;
    }
    return 0;
}

fn parseLine(alloc: std.mem.Allocator, line: []const u8) ![]i64 {
    var tokens = std.mem.tokenize(u8, line, " ");

    var nums = try ArrayList(i64).initCapacity(alloc, 4);
    try parsePair(&nums, tokens.next().?);
    _ = tokens.next();
    try parsePair(&nums, tokens.next().?);

    return nums.toOwnedSlice();
}

fn parsePair(nums: *ArrayList(i64), buf: []const u8) !void {
    var tokens = std.mem.tokenize(u8, buf, ",");
    try nums.append(try std.fmt.parseInt(i64, tokens.next().?, 0));
    try nums.append(try std.fmt.parseInt(i64, tokens.next().?, 0));
}


fn in(arr: ArrayList([]i64), elem: []i64) bool {
    for (arr) |e| {
        if (std.mem.eql(i64, e, elem)) {
            return true;
        }
    }
    return false;
}
