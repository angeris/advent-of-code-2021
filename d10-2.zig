const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input10.txt", .{});
    defer file.close();

    var reader = file.reader();
    
    var buf: [1000]u8 = undefined;

    var scoreidx: usize = 0;
    var scores: [1000]usize = undefined;

    main: while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var stackidx: usize = 0;
        var stack: [100]u8 = undefined;

        for (line) |c| {
            if (c == '(' or c == '[' or c == '{' or c == '<') {
                stack[stackidx] = c;
                stackidx += 1;
            } else {
                const lastopen = stack[stackidx-1];
                if (c == ')' and lastopen != '(') {
                    continue :main;
                } else if (c == ']' and lastopen != '[') {
                    continue :main;
                } else if (c == '}' and lastopen != '{') {
                    continue :main;
                } else if (c == '>' and lastopen != '<') {
                    continue :main;
                } else {
                    if (stackidx == 0) continue :main;
                    stackidx -= 1;
                }
            }
        }

        var currscore: usize = 0;
        while (stackidx > 0) : (stackidx -= 1) {
            const currletter = stack[stackidx-1];
            currscore *= 5;
            currscore += @as(usize, switch (currletter) {
                '(' => 1,
                '[' => 2,
                '{' => 3,
                '<' => 4,
                else => unreachable,
            });
        }
        scores[scoreidx] = currscore;
        scoreidx += 1;
    }

    var newscores = scores[0..scoreidx];

    std.sort.sort(usize, newscores, {}, comptime std.sort.asc(usize));

    print("result {}\n", .{newscores[newscores.len / 2]});
}

