const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    var alloc = arena.allocator();

    _ = try std.ArrayList(u8).initCapacity(alloc, 100);
}