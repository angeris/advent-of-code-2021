const std = @import("std");
const print = std.debug.print;


pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input8.txt", .{});
    defer file.close();

    var buf: [1000]u8 = undefined;
    var reader = file.reader();

    var totalnum: i32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");
        // var pastpipe: bool = false;
        var tokenlist: [10][]const u8 = undefined;
        var idx: u8 = 0;
        while (tokens.next()) |token| {
            if (std.mem.eql(u8, token, "|"))
                break;

            tokenlist[idx] = token;
            idx += 1;
        }

        var val: [10]usize = undefined;
        // Find the 1, 4, 7, 8
        for (tokenlist) |token, i| {
            if (token.len == 2) {
                val[1] = i;
            } else if (token.len == 3) {
                val[7] = i;
            } else if (token.len == 4) {
                val[4] = i;
            } else if (token.len == 7) {
                val[8] = i;
            }
        }
        
        for (tokenlist) |token, i| {
            if (token.len == 5) {
                // Find the 2, 3, and 5
                const oneoverlap = overlap(token, tokenlist[val[1]]);

                if (oneoverlap == 2) {
                    val[3] = i;
                } else if (oneoverlap == 1) {
                    const fouroverlap = overlap(token, tokenlist[val[4]]);

                    if (fouroverlap == 3) {
                        val[5] = i;
                    } else {
                        val[2] = i;
                    }
                }
            } else if (token.len == 6) {
                // Find the 0, 6, and 9
                const fouroverlap = overlap(token, tokenlist[val[4]]);
                const sevenoverlap = overlap(token, tokenlist[val[7]]);

                if (fouroverlap == 3 and sevenoverlap == 3) {
                    val[0] = i;
                } else if (fouroverlap == 3 and sevenoverlap == 2) {
                    val[6] = i;
                } else if (fouroverlap == 4 and sevenoverlap == 3) {
                    val[9] = i;
                }
            }
        }

        var idxval: [10]usize = undefined;
        // Map indices to values
        for (val) |v, i| {
            idxval[v] = i;
        }

        idx = 0;
        var total: i32 = 0;
        while (tokens.next()) |token| {
            const num = for (tokenlist) |t, i| {
                if (isperm(t, token)) break idxval[i];
            } else unreachable;
            total *= 10;
            total += @intCast(i32, num);
        }

        totalnum += total;
    }

    print("total: {}\n", .{totalnum});
}

fn overlap(a: []const u8, b: []const u8) u8 {
    var total: u8 = 0;
    for (a) |av| {
        for (b) |bv| {
            total += @boolToInt(av == bv);
        }
    }
    return total;
}

fn isperm(a: []const u8, b: []const u8) bool {
    if (a.len != b.len)
        return false;
    main: for (a) |av| {
        for (b) |bv| {
            if (bv == av)
                continue :main;
        }
        return false;
    }
    return true;
}