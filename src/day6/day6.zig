const std = @import("std");
const Answer = struct {
    part1: i64 = 0,
    part2: i64 = 0,
};

const Race = struct { time: i64, distance: i64 };

pub fn mainData() !Race {
   //const time = [_]i64{ 50, 74, 86, 85 };
    //const distance = [_]i64{ 242, 1017, 1691, 1252 } ;
    return Race{.time = 50748685, .distance = 242101716911252};
}

//pub fn testData() !Race {
//    const time = [_]i64{ 7, 15, 30, 0 };
//    const distance = [_]i64{ 9, 40, 200, 0 };
//    return Race{.time = time, .distance = distance};
//}
pub fn testData2() !Race {

    return Race{.time = 71530, .distance = 940200};
}
pub fn startProcess(input: Race) !Answer {
    var result: Answer = .{};
    result.part2 = 1;
    result.part1 = 1;
    var counter: i64 = 1;
    //for(input.time, 0..) |times, idx| {
    const times = input.time;
        var index: i64 = 0;
        while (index < times)  {

            if (((times - index) * index) > input.distance) {

                counter += 1;
            }

            index += 1;
        }

        if (counter > 1) {
            result.part2 *= (counter - 1);
        }

        counter = 1;
    //}
   return result;
}

test "answer_test" {

    const result: Answer = try startProcess(try mainData());
    std.debug.print("Result: {any}\n", .{result});
}

//test "day1_part1_test" {
//    std.debug.print("Part1\n", .{});

//    const result: Answer = try startProcess(try testData());
//    std.debug.print("Result: {any}\n", .{result});

//    try std.testing.expect(result.part1 == 288);
//}

test "day1_part2_test" {
    std.debug.print("Part2\n", .{});

    const result: Answer = try startProcess(try testData2());
    std.debug.print("Result: {any}\n", .{result});

    try std.testing.expect(result.part2 == 71503);
}
