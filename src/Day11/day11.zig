const std = @import("std");
const Answer = struct {
    part1: u128 = 0,
    part2: u128 = 0,
};
const keyXY = struct {
    x: usize = 0,
    y: usize = 0,

    pub fn hash(self: keyXY) i128 {
        var hasher = std.hash.Fnv1a_128.init();
        hasher.hash(self.x);
        hasher.hash(self.y);
        return hasher.final();
    }
    pub fn eql(a: keyXY, b: keyXY) bool {
        return a.x == b.x and a.y == b.y;
    }
};

const galaxyMap = std.ArrayList(keyXY);
//const Adjustments = std.ArrayList(i128);
//const IsGalaxy = std.ArrayList(bool);

pub fn startProcess(input: []const u8, factor: usize) !Answer {
    const sizeRow2: usize = 141;
    var result: Answer = .{ .part2 = 0, .part1 = 0 };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var starMap = galaxyMap.init(allocator);

    var rowAdjuster = [_]usize{0} ** sizeRow2;
    var colAdjuster = [_]usize{0} ** sizeRow2;
    var isGalaxyInColumn = [_]bool{false} ** sizeRow2;

    //Read each row, store the # with a postion row,col
    //As read char store isCol[col] = isCol[col] or (char == '#')
    // store current adjustment counter
    //If end of row all . then increment adjustment counter
    // After read all isCol[..] = true set col[] adjustment counter.
    //loop galaxy [..n-1] and inner galaxy+1..n x+adj - x + xAdjust + y+adj - y + yAdjust == part1 answer

    var it = std.mem.tokenizeAny(u8, input, "\n");
    var rowAdjustment: usize = 0;
    var row: usize = 0;

    while (it.next()) |dataRow| {
        var row_Is_empty: bool = false;
        var col: usize = 0;
        for (dataRow) |char| {
            if (char == '#') {
                row_Is_empty = true;
                isGalaxyInColumn[col] = true;
                const key: keyXY = .{ .x = row, .y = col };
                try starMap.append(key);
            }
            col += 1;
        }
        if (row_Is_empty == false) {
            rowAdjustment += factor;
        }
        rowAdjuster[row] = rowAdjustment;
        row += 1;

        col = 1;
    }
    var colAdjustment: usize = 0;
    for (isGalaxyInColumn, 0..) |value, i| {
        if (value == false) {
            colAdjustment += factor;
        }
        colAdjuster[i] = colAdjustment;
    }
    var counter: i128 = 0;
    for (0..starMap.items.len - 1) |idx| {
        for (idx + 1..starMap.items.len) |idx2| {

            var v1: i128 = starMap.items[idx2].x;
            v1 += rowAdjuster[starMap.items[idx2].x];
            var v2: i128 = starMap.items[idx].x;
            v2 += rowAdjuster[starMap.items[idx].x];
            const a: u128 = @abs(v1 - v2);

            var v3: i128 = starMap.items[idx].y;
            v3 += colAdjuster[starMap.items[idx].y];
            var v4: i128 = starMap.items[idx2].y;
            v4 += colAdjuster[starMap.items[idx2].y];

            const b: u128 = @abs(v3 - v4);
            const rowCalc = a + b;

            if (factor == 1) {
                result.part1 += rowCalc;
            } else {
                result.part2 += rowCalc;
            }
            counter += 1;
        }
    }

    return result;
}
pub fn main() !void {
    //const sizeRow: usize = 140;
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input, (1000000 - 1));
    std.debug.print("Result: {any}\n", .{result});
}

test "part1_test" {
    const input = @embedFile("Part1Example.txt");
    //const rowSize = 10;
    const result: Answer = try startProcess(input, 1);
    std.debug.print("Result: {any}\n", .{result});
    try std.testing.expect(result.part1 == 374);
}
test "part2_test" {
    const input = @embedFile("Part1Example.txt");
    //const rowSize = 10;
    const result: Answer = try startProcess(input, 9);
    std.debug.print("Result: {any}\n", .{result});
    try std.testing.expect(result.part2 == 1030);
}
