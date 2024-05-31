const std = @import("std");
const Answer = struct {
    part1: u64 = 0,
    part2: u64 = 0,
};
const LeftOrRight = struct { left: []const u8, right: []const u8 };

pub fn startProcess(input: []const u8) !Answer {
    var result: Answer = .{};
    result.part2 = 0;
    result.part1 = 35;

    const allocator = std.heap.page_allocator;

    var it = std.mem.tokenizeAny(u8, input, "\n");
    const firstRow: []const u8 = it.next() orelse return error.NoSuchElement; // Unwrap the optional or return an error if null
    std.debug.print("{s}\n", .{firstRow});
    // _ = it.next(); //Blankline
    var rulesLoad = std.StringHashMap(LeftOrRight).init(allocator);
    defer rulesLoad.deinit();
    var localRule: LeftOrRight = undefined;
    var key: []const u8 = undefined;
    var keysLooking = std.ArrayList([]const u8).init(allocator);
    defer keysLooking.deinit();

    while (it.next()) |dataLoading| {
        //std.debug.print("len: {}: ",.{dataLoading.len});
        key = dataLoading[0..3];
        if (key[2] == 'A') {
            try keysLooking.append(key);
        }
        localRule.left = dataLoading[7..10];
        localRule.right = dataLoading[12..15];
        //std.debug.print("{s}, {s}:{s}\n", .{key,localRule.left, localRule.right});
        try rulesLoad.put(key, localRule);
    }

    // std.debug.print("===========================\n",.{});

    var mainCounter: u64 = 1;
    for (keysLooking.items) |keyLooking| {
        std.debug.print("::{s}::\n", .{keyLooking});
        var position: usize = 0;
        var steps: u64 = 0;
        var currentKey = keyLooking;
        while (true) : (position = @mod(position + 1, firstRow.len)) {
            if (std.mem.endsWith(u8, currentKey, "Z")) {
                break;
            }
            //std.debug.print("K:{s}, P:{}, C:{} L:{}\n", .{ currentKey, position, steps, firstRow.len });
            const LorR = rulesLoad.get(currentKey) orelse return error.fff;
            const inst = firstRow[position];
            if (inst == 'L') {
                currentKey = LorR.left;
            } else {
                currentKey = LorR.right;
            }
            steps += 1;
        }
        std.debug.print("{} * {}\n", .{ mainCounter, steps });
        mainCounter = (mainCounter * steps) / std.math.gcd(mainCounter, steps);
    }
    result.part2 = mainCounter;
    return result;
}

pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 8: {any}\n", .{result});
}

test "part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part2Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 8: {any}\n", .{result});
    try std.testing.expect(result.part2 == 6);
}
