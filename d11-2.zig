const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input11.txt", .{});
    defer file.close();

    var reader = file.reader();
    var buf: [100]u8 = undefined;

    var allboard: [1000]u8 = undefined;

    var linelength: u8 = 0;
    var curridx: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (linelength == 0) linelength = @intCast(u8, line.len);
        for (line) |c| {
            allboard[curridx] = c - '0';
            curridx += 1;
        }
    }

    var board = allboard[0..curridx];

    curridx = 0;

    main: while (true) : (curridx += 1) {
        var needsround = false;
        for (board) |_, i| {
            board[i] += 1;
            if (board[i] > 9)
                needsround = true;
        }
        while (needsround) {
            needsround = false;
            // Propagate flashes
            for (board) |v, i| {
                if (v <= 9) continue;
                board[i] = 0;
                
                for ([_]i32{-1, 0, 1}) |x| {
                    for ([_]i32{-1, 0, 1}) |y| {
                        var hleft = @intCast(i32, i % linelength);
                        if (y + hleft < 0 or y + hleft >= linelength) continue;

                        const newidx = @intCast(i32, i) + x*linelength + y;
                        if (newidx < 0 or newidx >= board.len) continue;
                        const idx = @intCast(usize, newidx);

                        if (board[idx] > 0) board[idx] += 1;
                        if (board[idx] > 9) needsround = true;
                    }
                }
            }
        }
        for (board) |v| {
            if (v!=0) {
                continue :main;
            }
        }
        print("total {}\n", .{curridx+1});
        break;
    }

}

fn printBoard(board: []const u8, len: u8) void {
    for (board) |v, i| {
        if (i % len == 0 and i > 0)
            print("\n", .{});
        print("{}", .{v});
    }
    print("\n", .{});
}