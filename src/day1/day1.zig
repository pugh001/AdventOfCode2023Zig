const std = @import("std");

var digits = [_]u32{0,1,2,3,4,5,6,7,8,9 };
pub fn checkStringDigit(inputString: []const u8) i32 {
    var digit: i32 = -1;
    if (std.mem.startsWith(u8, inputString,"one")){
        digit = 1;
    }
    if (std.mem.startsWith(u8, inputString,"two")){
        digit = 2;
    }
    if (std.mem.startsWith(u8, inputString,"three")){
        digit = 3;
    }
    if (std.mem.startsWith(u8, inputString,"four")){
        digit = 4;
    }
    if (std.mem.startsWith(u8, inputString,"five")){
        digit = 5;
    }
    if (std.mem.startsWith(u8, inputString,"six")){
        digit = 6;
    }
    if (std.mem.startsWith(u8, inputString,"seven")){
        digit = 7;
    }
    if (std.mem.startsWith(u8, inputString,"eight")){
        digit = 8;
    }
    if (std.mem.startsWith(u8, inputString,"nine")){
        digit = 9;
    }
    if (std.mem.startsWith(u8, inputString,"zero")){
        digit = 0;
    }
    return digit;

}
pub fn getDigit(input:  []const u8) i32{
    var result: i32 = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");
    std.debug.print("\n", .{});
    while (it.next()) |line| {
        var first: i32 = -99;
        var last: i32 = 0;

        for (line, 0..) |char, index| {
            var digit: i32 = -1;
            if (char >= '0' and char <= '9') {
                digit = char - '0';
            } else {
                digit = checkStringDigit(line[index..]);
            }
            if (digit >= 0) {
                if (first == -99) {
                    first = digit;
                }
                last = digit;
            }
        }
        result += (first * 10 + last);

    }
    return result;
}
pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: i32 = getDigit(input);
    std.debug.print("Result: {any}\n", .{result});

}

test "day1_part1_test" {
    const input = @embedFile("Part1Example.txt");
    const result: i32 = getDigit(input);
    try std.testing.expect(result == 142);
}

test "day1_part2_test" {
    std.debug.print("day1_part2_test\n", .{});
    const input = @embedFile("Part2Example.txt");
    const result: i32 = getDigit(input);
    try std.testing.expect(result == 281);
}
