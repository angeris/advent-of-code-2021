const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input10.txt", .{});
    defer file.close();

    var reader = file.reader();
    
    var buf: [1000]u8 = undefined;
    var total: usize = 0;

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
                    total += 3;
                    continue :main;
                } else if (c == ']' and lastopen != '[') {
                    total += 57;
                    continue :main;
                } else if (c == '}' and lastopen != '{') {
                    total += 1197;
                    continue :main;
                } else if (c == '>' and lastopen != '<') {
                    total += 25137;
                    continue :main;
                } else {
                    if (stackidx == 0) continue :main;
                    stackidx -= 1;
                }
            }
        }
    }

    print("total {}\n", .{total});
}

