const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Point = struct {
    x: u32,
    y: u32
};

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input13.txt", .{});
    defer file.close();
    
    var reader = file.reader();
    var buf: [100]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var alloc = arena.allocator();

    var mx: u32 = 0;
    var my: u32 = 0;

    var pointlist = try ArrayList(Point).initCapacity(alloc, 1000);

    // Scan through and find max values
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len < 1) break;
        var tokens = std.mem.tokenize(u8, line, ",");
        const x = try std.fmt.parseInt(usize, tokens.next().?, 10);
        const y = try std.fmt.parseInt(usize, tokens.next().?, 10);

        if (x+1 > mx) {
            mx = @intCast(u32, x + 1);
        }
        if (y+1 > my) {
            my = @intCast(u32, y + 1);
        }
        try pointlist.append(Point{.x=@intCast(u32, x), .y=@intCast(u32, y)});

    }

    // Fold
    {
        var line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
        var stokens = std.mem.tokenize(u8, line, " ");
        _ = stokens.next();
        _ = stokens.next();
        var tokens = std.mem.tokenize(u8, stokens.next().?, "=");
        const direction = (tokens.next().?[0] == 'x');
        const foldidx = try std.fmt.parseInt(u32, tokens.next().?, 10);
        if (direction) {
            mx = foldidx;
        } else {
            my = foldidx;
        }

        for (pointlist.items) |p, i| {
            if (direction and p.x > foldidx)
                pointlist.items[i].x = 2*foldidx - p.x;
            if (!direction and p.y > foldidx)
                pointlist.items[i].y = 2*foldidx - p.y;
        }
    }
    var allpoints = try alloc.alloc(bool, mx*my);
    for (allpoints) |_, i| {
        allpoints[i] = false;
    }
    for (pointlist.items) |p| {
        allpoints[p.x + mx*p.y] = true;
    }

    // for (allpoints) |v, i| {
    //     if (v) {
    //         print("#", .{});
    //     } else {
    //         print(".", .{});
    //     }
    //     if ((i+1) % mx == 0)
    //         print("\n", .{});
    // }

    var total: u32 = 0;
    for (allpoints) |v| {
        total += @boolToInt(v);
    }
    print("total {}\n", .{total});
}