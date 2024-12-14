#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
DONE

EXAMPLE_ANSWER_FIRST :: 12;

INPUT_FILE :: "./inputs/14.txt";

Vec2 :: struct {
    x: s64;
    y: s64;
}

Robot :: struct {
    pos: Vec2;
    vel: Vec2;
}

first_star :: (robots_src: []Robot, $width: u32, $height: u32, $time: u32 = 100) -> u32 {
    robots := array_copy(robots_src);
    defer array_free(robots);

    for * r: robots {
        using r;
        pos.x = mod(pos.x + (vel.x * time), width);
        pos.y = mod(pos.y + (vel.y * time), height);
    }

    quadrants := u32.[0, 0, 0, 0];
    for robots {
        half := Vec2.{ width / 2, height / 2 };
        if it.pos.x == half.x || it.pos.y == half.y  continue;

        q := ifx it.pos.x < half.x then 0 else 1;
        q += ifx it.pos.y < half.y then 0 else 2;
        quadrants[q] += 1;
    }

    safety_factor: u32 = 1;
    for quadrants  safety_factor *= it;

    return safety_factor;
}

second_star :: (robots_src: []Robot, $width: u32, $height: u32) -> u32 {
    robots := array_copy(robots_src);
    defer array_free(robots);

    // build map, and check if there is a frame of robots
    check_frame :: (robots: []Robot) -> bool {
        map := NewArray(width * height, u32);
        defer array_free(map);

        for robots  map[(it.pos.y * width) + it.pos.x] += 1;

        for r: robots {
            using r;
            if pos.x > width - 10  continue;

            for i: 0..10 - 1 {
                if map[(pos.y * width) + pos.x + i] == 0  continue r;
            }
            return true;
        }
        return false;
    }

    time: u32 = 1_000_000;
    for i: 0..time - 1 {
        for * r: robots {
            using r;
            pos.x = mod(pos.x + vel.x, width);
            pos.y = mod(pos.y + vel.y, height);
        }

        if check_frame(robots) {
            print_map(robots, width, height);
            return i + 1;
        }
    }

    return 0;
}

print_map :: (robots: []Robot, $width: u32, $height: u32, $quad: bool = false) {
    map := NewArray(width * height, u32);
    defer array_free(map);

    for robots  map[(it.pos.y * width) + it.pos.x] += 1;

    print("\n");
    for map {
        defer if (it_index + 1) % width == 0  print("\n");

        #if quad {
            half := Vec2.{ width / 2, height / 2 };
            pos := Vec2.{ it_index % width, it_index / width };
            if pos.x == half.x || pos.y == half.y {
                print(" ");
                continue;
            }
        }

        if it == 0  print("-");
        else print("%", it);
    }
    print("\n");
}

mod :: inline (a: s64, b: s64) -> s64 {
    res := a % b;
    if res < 0  res += b;
    return res;
}

parse_input :: (input: string) -> []Robot {
    delimeters :: u8.[#char " ", #char "\n"];
    cursor := 0;
    robots: [..]Robot;
    tmp: Robot;

    while cursor < input.count {
        token, is_new_line := next_token(input, *cursor, delimeters);
        defer if is_new_line {
            array_add(*robots, tmp);
        }

        dest := ifx token[0] == #char "p" then *tmp.pos else *tmp.vel;
        comma_pos := find_index_from_left(token, #char ",");
        first_digit_str := slice(token, 2, comma_pos - 2);
        second_digit_str := slice(token, comma_pos + 1, token.count - comma_pos - 1);
        first_digit := string_to_int(first_digit_str);
        second_digit := string_to_int(second_digit_str);
        dest.* = Vec2.{ first_digit, second_digit };
    }
    return robots;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    robots := parse_input(input);
    defer array_free(robots);

    first := first_star(robots, 11, 7);

    assert(first == EXAMPLE_ANSWER_FIRST);
}

main :: () {
    validate_example();
    if !file_exists(INPUT_FILE) {
        print("Input file for day 14 not found: '%'\n", INPUT_FILE);
        return;
    }

    input := read_entire_file(INPUT_FILE);

    robots := parse_input(input);
    defer array_free(robots);

    first := first_star(robots, 101, 103);
    second := second_star(robots, 101, 103);

    print("First star: %\n", first);
    print("Second star: %\n", second);
}
