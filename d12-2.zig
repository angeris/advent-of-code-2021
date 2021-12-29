const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input12.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var alloc = arena.allocator();

    var buf: [50]u8 = undefined;

    var namemap = std.StringHashMap(usize).init(alloc);
    var nmap = try ArrayList(ArrayList(usize)).initCapacity(alloc, 100);
    var isupper = try ArrayList(bool).initCapacity(alloc, 100);

    var reader = file.reader();

    var curridx: usize = 0;
    var endidx: usize = 0;
    var startidx: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokens = std.mem.tokenize(u8, line, "-");

        var nidx: [2]usize = undefined;
        var idx: usize = 0;

        while (tokens.next()) |token| {
            if (!namemap.contains(token)) {
                var currname = try alloc.alloc(u8, token.len);
                std.mem.copy(u8, currname, token);

                try namemap.put(currname, curridx);
                try nmap.append(try ArrayList(usize).initCapacity(alloc, 100));
                try isupper.append(token[0] >= 'A' and token[0] <= 'Z');

                if (std.mem.eql(u8, currname, "end")) endidx = curridx;
                if (std.mem.eql(u8, currname, "start")) startidx = curridx;

                curridx += 1;
            }

            nidx[idx] = namemap.get(token).?;
            idx += 1;
        }

        try nmap.items[nidx[0]].append(nidx[1]);
        try nmap.items[nidx[1]].append(nidx[0]);
    }

    var visited = try alloc.alloc(bool, nmap.items.len);
    for (visited) |_, i| {
        visited[i] = false;
    }
    const total = countPaths(nmap, isupper.items, startidx, visited, startidx, endidx, false);

    print("total {}\n", .{total});
}

fn countPaths(nmap: ArrayList(ArrayList(usize)), isupper: []bool, currpos: usize, visited: []bool, start: usize, end: usize, hassmall: bool) usize {
    var newsmall: bool = false;

    if (!isupper[currpos] and visited[currpos]) {
        if (currpos == start) return 0;

        if (hassmall) {
            return 0;
        } else {
            newsmall = true;
        }
    }
    if (currpos == end) return 1;

    visited[currpos] = true;
    var total: usize = 0;

    for (nmap.items[currpos].items) |neighbor| {
        total += countPaths(nmap, isupper, neighbor, visited, start, end, hassmall or newsmall);
    }

    if (!newsmall) 
        visited[currpos] = false;

    return total;
}