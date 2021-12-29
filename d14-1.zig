const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("data/input14.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    var reader = file.reader();
    var buf: [100]u8 = undefined;
    
    var input: ?[]u8 = null;

    var statemap = std.StringHashMap(usize).init(alloc);
    var states = try ArrayList([]const u8).initCapacity(alloc, 100);
    var transitions = try ArrayList(ArrayList(usize)).initCapacity(alloc, 100);
    var transletter: [1000]ArrayList(u8) = undefined;

    for (transletter) |_, i| {
        transletter[i] = ArrayList(u8).init(alloc);
    }

    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (input == null) {
            input = try alloc.dupe(u8, line);
            continue;
        }

        if (line.len < 1) continue;

        var tokens = std.mem.tokenize(u8, line, " ");
        const lhs = tokens.next().?;
        _ = tokens.next().?;
        const rhs = tokens.next().?;

        const ls = try addIfNotContains(alloc, &statemap, &states, &transitions, lhs);
        const rs1 = try addIfNotContains(alloc, &statemap, &states, &transitions, &[2]u8{lhs[0], rhs[0]});
        const rs2 = try addIfNotContains(alloc, &statemap, &states, &transitions, &[2]u8{rhs[0], lhs[1]});

        try transletter[ls].append(rhs[0]);

        try transitions.items[ls].append(rs1);
        try transitions.items[ls].append(rs2);
    }

    var prevstate = try alloc.alloc(usize, states.items.len);
    var currstate = try alloc.alloc(usize, states.items.len);
    std.mem.set(usize, currstate, 0);

    var elemcnt: [26]usize = .{0} ** 26;

    for (input.?) |c, i| {
        elemcnt[c - 'A'] += 1;

        if (i==input.?.len - 1) break;
        const idx = statemap.get(&[2]u8{c, input.?[i+1]}).?;
        currstate[idx] += 1;
    }

    var step: u32 = 0;
    // XXX: Change this next line for d14-2
    while (step < 40) : (step += 1) {
        std.mem.copy(usize, prevstate, currstate);
        std.mem.set(usize, currstate, 0);

        for (prevstate) |p, i| {
            if (p==0) continue;
            for (transitions.items[i].items) |v| {
                currstate[v] += p;
            }
            for (transletter[i].items) |v| {
                elemcnt[v - 'A'] += p;
            }
        }
    }

    var minamt: usize = 0;
    var maxamt: usize = 0;
    for (elemcnt) |v| {
        if (v != 0) {
            if (minamt == 0 or v < minamt) {
                minamt = v;
            }
        }
        if (v > maxamt) maxamt = v;
    }

    print("min amount {}\n", .{minamt});
    print("max amount {}\n", .{maxamt});
    print("result {}\n", .{maxamt - minamt});
}

fn addIfNotContains(alloc: std.mem.Allocator, statemap: *std.StringHashMap(usize), states: *ArrayList([]const u8), transitions: *ArrayList(ArrayList(usize)), s: []const u8) !usize {
    if (!statemap.contains(s)) {
        const t = try alloc.dupe(u8, s);
        const idx = states.items.len;

        try states.append(t);
        try transitions.append(ArrayList(usize).init(alloc));
        try statemap.put(t, idx);
        return idx;
    }
    return statemap.get(s).?;
}