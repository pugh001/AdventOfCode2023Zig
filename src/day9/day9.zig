const std = @import("std");
const Answer = struct {
    part1: i128 = 0,
    part2: i128 = 0,
};
const LeftOrRight = struct { left: []const u8, right: []const u8 };

pub fn startProcess(input: []const u8) !Answer {
    var result: Answer = .{};
    result.part2 = 0;
    result.part1 = 0;

    const allocator = std.heap.page_allocator;
    var numbers = std.ArrayList(i128).init(allocator);
    defer numbers.deinit();
    var lastDigit: i128 = 0;
    var firstDigit: i128 = 0;
    var TotallastDigit: i128 = 0;
    var TotalFirstDigit: i128 = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |dataRow| {
        var numberSplit = std.mem.tokenizeAny(u8, dataRow, " ");
        while (numberSplit.next()) |number| {
            const numberValue: i128 = try std.fmt.parseInt(i128, number, 10);
            try numbers.append(numberValue);
            lastDigit = numberValue;
        }
        firstDigit = numbers.items[0];
        const getSumValue =  try calculateDifferenceLast( numbers.items);
        const getMinusValue =  try calculateDifferenceFirst( numbers.items);
        TotallastDigit = TotallastDigit + lastDigit + getSumValue;
        TotalFirstDigit = TotalFirstDigit + (firstDigit - getMinusValue);
        //std.debug.print("History: {}/{} = {} \n", .{lastDigit, getSumValue,TotallastDigit});
        std.debug.print("History: {}-{} = {} \n", .{firstDigit, getMinusValue,TotalFirstDigit});
        numbers.clearRetainingCapacity();
    }

    std.debug.print("===========================\n", .{});

    result.part1 = TotallastDigit;
    result.part2 = TotalFirstDigit;
    return result;
}
pub fn calculateDifferenceLast( ranges: []i128) !i128 {
    const allocator = std.heap.page_allocator;
    var differences = std.ArrayList(i128).init(allocator);
    defer differences.deinit();
    var low: i128 = ranges[0];
    var sumDiff: i128 = 0;
    var lastDigit: i128 = 0;
    var isZero: bool = true;
    //var x: usize = ranges.len - 1;
    for (ranges[1..]) |range| {
        const high: i128 = range;

        const diff: i128 = high - low;
        //std.debug.print("high: {} low {} diff:{}\n", .{ high, low, diff });
        try differences.append(diff);
        sumDiff += diff;
        low = range;
        if (lastDigit == 0 and diff == 0 and isZero){
            isZero = true;
        }
        else {
            isZero = false;
        }
        lastDigit = diff;
    }
    if (isZero == false) {
        //std.debug.print("Last is: {}\n ", .{lastDigit});
        lastDigit = lastDigit + try calculateDifferenceLast(differences.items);
    }
    return lastDigit;
}


pub fn calculateDifferenceFirst( ranges: []i128) !i128 {
    const allocator = std.heap.page_allocator;
    var differences = std.ArrayList(i128).init(allocator);
    defer differences.deinit();
    var low: i128 = ranges[0];
    var sumDiff: i128 = 0;
    var lastDigit: i128 = 0;
    var isZero: bool = true;
    //var x: usize = ranges.len - 1;
    for (ranges[1..]) |range| {
        const high: i128 = range;

        const diff: i128 = high - low;
        //std.debug.print("high: {} low {} diff:{}\n", .{ high, low, diff });
        try differences.append(diff);
        sumDiff += diff;
        low = range;
        if (lastDigit == 0 and diff == 0 and isZero){
            isZero = true;
        }
        else {
            isZero = false;
        }
        lastDigit = diff;
    }
    std.debug.print(" Data {any}::", .{differences.items});
    if (isZero == false) {

        lastDigit = try calculateDifferenceFirst(differences.items);
        std.debug.print("Last is: {} value: {} :: ", .{lastDigit, differences.items[0]});
        differences.items[0] = differences.items[0] - lastDigit;
    }
    std.debug.print("{} \n", .{differences.items[0]});
    return differences.items[0];
}

pub fn main() !void {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 8: {any}\n", .{result});
}

test "part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 8: {any}\n", .{result});
    try std.testing.expect(result.part1 == 114);
}
test "part2_test" {
    std.debug.print("\nTest 2\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try startProcess(input);
    std.debug.print("Result Day 8: {any}\n", .{result});
    try std.testing.expect(result.part2 == 2);
}
