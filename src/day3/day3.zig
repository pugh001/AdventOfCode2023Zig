const std = @import("std");
const Grid = struct { value: []const u8 };

const Answer = struct {
    part1: i32 = 0,
    part2: i32 = 0,
};

pub fn getGames(input: []const u8) !Answer {
    var memArenaAllocated = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer memArenaAllocated.deinit();
    const allocator = memArenaAllocated.allocator();

    var myGridData = std.ArrayList(Grid).init(allocator);
    defer myGridData.deinit();

    var result: Answer = .{};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |lineLoading| {
        try myGridData.append(Grid{ .value = lineLoading });
    }

    var totaldigits: i32 = 0;
    var counter: usize = 0;
    var isValid: bool = false;
    while (counter < myGridData.items.len) {
        for (myGridData.items[counter].value, 0..myGridData.items[counter].value.len) |text, position| {
            //Part 2
            if (text == '*') {
                var resultPart2 = [_]i32{0 , 0 };
                const maxRows: usize = myGridData.items.len - 1;
                var rowOn: usize = counter - 1;
                var rowData: []const u8 = myGridData.items[rowOn].value;
                var foundValue: i32 = 0;
                var foundCounter: u8 = 0;
                if (rowOn < 0) {
                    rowOn = 0;
                }
                while (foundCounter < 2) {
                    rowData = myGridData.items[rowOn].value;
                    var startAt: usize = position;
                    var isANumber: bool = false;
                    while (startAt > 0) {
                        startAt = startAt - 1;
                        if (rowData[startAt] < '0' or rowData[startAt] > '9') {
                            startAt += 1;
                            break;
                        }
                        isANumber = true;
                    }

                    if (isANumber) {
                       for (rowData[startAt..]) |foundData| {
                            if (foundData >= '0' and foundData <= '9') {
                                foundValue = foundValue * 10 + (foundData - '0');
                                startAt += 1;
                            } else {
                                break;
                            }
                        }
                                               if (foundValue > 0) {
                            resultPart2[foundCounter] = foundValue;
                            foundCounter += 1;
                            foundValue = 0;
                        }
                    }
                    if (startAt <= position) {
                        startAt = position;
                        for (rowData[startAt..]) |foundData| {
                            if (foundData >= '0' and foundData <= '9') {
                                foundValue = foundValue * 10 + (foundData - '0');
                                startAt += 1;
                            } else {
                                break;
                            }
                        }
                        if (foundValue > 0) {
                            resultPart2[foundCounter] = foundValue  ;
                            foundCounter += 1;
                            foundValue = 0;
                        }
                    }

                    if (startAt == position) {
                        startAt = position+1;
                        for (rowData[startAt..]) |foundData| {
                            if (foundData >= '0' and foundData <= '9') {
                                foundValue = foundValue * 10 + (foundData - '0');
                                startAt += 1;
                            } else {
                                break;
                            }
                        }
                        if (foundValue > 0) {
                            resultPart2[foundCounter] =  foundValue;
                            foundCounter += 1;
                            foundValue = 0;
                        }
                    }
                    rowOn += 1;
                    if (rowOn > counter + 1 or rowOn > maxRows) {
                        break;
                    }
                }
                result.part2 += (resultPart2[0] * resultPart2[1]);
            }

            //Part 1
            if (text >= '0' and text <= '9') {
                totaldigits = totaldigits * 10 + (text - '0');
                if (isValid == false) {
                    if (counter > 0) {
                        isValid = checkValue(position, myGridData.items[counter - 1].value.len, myGridData.items[counter - 1].value);
                    }
                }
                if (isValid == false) {
                    if (counter + 1 < myGridData.items.len) {
                        isValid = checkValue(position, myGridData.items[counter + 1].value.len, myGridData.items[counter + 1].value);
                    }
                }
                if (isValid == false) {
                    if (counter > 0) {
                        isValid = checkValue(position, myGridData.items[counter].value.len, myGridData.items[counter].value);
                    }
                }

                if (position == myGridData.items[counter].value.len - 1) {
                    if (isValid == true) {

                        result.part1 += totaldigits;
                        totaldigits = 0;
                        isValid = false;
                    }
                } else {
                    if (myGridData.items[counter].value[position + 1] < '0' or myGridData.items[counter].value[position + 1] > '9') {
                        if (isValid == true) {

                            result.part1 += totaldigits;
                        }

                        totaldigits = 0;
                        isValid = false;

                    }
                }
            }
        }
        totaldigits = 0;
        isValid = false;
        counter += 1;
    }
    return result;
}
pub fn checkValue(location: u64, lastRight: u64, data: []const u8) bool {
    if (location > 0) {
        //Can check left
        const left: u8 = data[location - 1];
        if ((left < '0' or left > '9') and left != '.') {

            return true;
        }
    }
    if (location < lastRight - 1) {
        //Can check right
        const right: u8 = data[location + 1];
        if ((right < '0' or right > '9') and right != '.') {

            return true;
        }
    }
    //Can check above
    const above: u8 = data[location];
    if ((above < '0' or above > '9') and above != '.') {

        return true;
    }
    return false;
}

pub fn main() !void  {
    const input = @embedFile("puzzleInput.txt");
    const result: Answer = try getGames(input);
    std.debug.print("Result Day 3: {any}\n", .{result});
}

test "part1_test" {
    std.debug.print("\nTest 1\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try getGames(input);
    std.debug.print("Result Day 3: {any}\n", .{result});
    try std.testing.expect(result.part1 == 4361);
}

test "part2_test" {
    std.debug.print("\nTest 2\n", .{});
    const input = @embedFile("Part1Example.txt");
    const result: Answer = try getGames(input);
    std.debug.print("Result Day 3: {any}\n", .{result});
    try std.testing.expect(result.part2 == 467835);
}
