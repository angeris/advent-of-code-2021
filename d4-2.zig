const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var alloc = arena.allocator();

    var buf: [1000]u8 = undefined;

    var file = try std.fs.cwd().openFile("data/input4.txt", .{});
    defer file.close();

    var reader = file.reader();

    // Parse initial numbers line
    var bingonumbers = try ArrayList(u8).initCapacity(alloc, 1000);
    {
        var firstline = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
        var tokennumbers = std.mem.tokenize(u8, firstline, ",");

        while (tokennumbers.next()) |num| {
            try bingonumbers.append(try std.fmt.parseInt(u8, num, 0));
        }
    }

    var allboards = try ArrayList([]?u8).initCapacity(alloc, 1000);
    // Parse bingo tables
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |_| {
        try allboards.append(try parseNextLines(reader, alloc, &buf));
    }

    var num_left = allboards.items.len;
    var notinplay = try alloc.alloc(bool, num_left);

    done: for (bingonumbers.items) |num| {
        for (allboards.items) |board, bidx| {
            if (notinplay[bidx]) continue;

            for (board) |n, idx| {
                if (n == num) {
                    board[idx] = null;
                }
            }
            if (isComplete(board)) {
                num_left -= 1;
                if (num_left == 0) {
                    print("last one {}\n", .{num});
                    var board_left_idx: usize = 0;
                    for (notinplay) |b, idx| {
                        if (!b) {
                            board_left_idx = idx;
                            break;
                        }
                    }
                    var fboard = allboards.items[board_left_idx];
                    printBoard(fboard);
                    var sumall: usize = 0;
                    for (fboard) |n| {
                        if (n != null) {
                            sumall += n.?;
                        }
                    }
                    print("solution {}\n", .{num*sumall});
                    break :done;
                }
                notinplay[bidx] = true;
            }
        }
    }

}

fn parseNextLines(reader: anytype, alloc: std.mem.Allocator, buf: []u8) ![]?u8 {
    var lineidx: u8 = 0;
    var bingoBoard = try ArrayList(?u8).initCapacity(alloc, 25);

    while (try reader.readUntilDelimiterOrEof(buf, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        while (tokens.next()) |num| {
            try bingoBoard.append(try std.fmt.parseInt(u8, num, 0));
        }
        lineidx += 1;
        if (lineidx >= 5) {
            break;
        }
    }

    return bingoBoard.toOwnedSlice();
}

fn isComplete(board: []?u8) bool {
    var i: u8 = 0;

    main: while (i < 5) : (i += 1) {
        var j: u8 = 0;
        var hasbingov: bool = true;
        var hasbingoh: bool = true;

        while (j < 5) : (j += 1) {
            if (board[i*5 + j] != null) {
                hasbingov = false;
            }
            if (board[j*5 + i] != null) {
                hasbingoh = false;
            }
            if (!hasbingov and !hasbingoh) {
                continue :main;
            }
        }

        return true;
    }

    return false;
}

fn printBoard(board: []?u8) void {
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        var j: u8 = 0;
        while (j < 5) : (j += 1) {
            print("{:5} ", .{board[i*5 + j]});
        }
        print("\n", .{});
    }
}

test "iscomplete" {
    var board: [25]?u8 = .{
        null, 0, 0, 0, 0,
        0, null, 0, 0, 0,
        0, 0, null, 0, 0,
        0, 0, 0, null, 0,
        0, 0, 0, 0, null,
    };
    std.debug.assert(isComplete(&board));

    board = .{
        0, 0, 0, 0, null,
        0, 0, 0, null, 0,
        0, 0, null, 0, 0,
        0, null, 0, 0, 0,
        null, 0, 0, 0, 0,
    };

    std.debug.assert(isComplete(&board));

    board = .{
        0, 0, 0, 0, 0,
        0, 0, 0, null, 0,
        null, null, null, null, null,
        0, null, 0, 0, 0,
        null, 0, 0, 0, 0,
    };

    std.debug.assert(isComplete(&board));

    board = .{
        0, 0, 0, 0, 0,
        0, 0, 0, null, 0,
        0, null, null, null, null,
        0, null, 0, 0, 0,
        null, 0, 0, 0, 0,
    };

    std.debug.assert(!isComplete(&board));
}