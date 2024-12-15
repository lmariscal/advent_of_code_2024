#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
DONE


EXAMPLE_ANSWER_FIRST :: 10092;
EXAMPLE_ANSWER_SECOND :: 9021;

INPUT_FILE :: "./inputs/15.txt";

Vec2 :: struct {
    x: s64;
    y: s64;
}

Map :: struct {
    size: Vec2;
    robot: Vec2;
    data: []u8;
}

first_star :: (map_src: Map, moves: []Vec2) -> s64 {
    map := map_copy(map_src);
    defer free(map);

    for m: moves  r := try_move(*map, map.robot, m);

    sum := 0;
    for map.data {
        if it != #char "O"  continue;
        pos := Vec2.{ it_index % map.size.x, it_index / map.size.x };
        sum += 100 * pos.y + pos.x;
    }

    return sum;
}

second_star :: (map_src: Map, moves: []Vec2) -> s64 {
    map := double_width(map_src);
    defer free(map);

    for m: moves  r := try_move(*map, map.robot, m);

    sum := 0;
    for map.data {
        if it != #char "["  continue;
        pos := Vec2.{ it_index % map.size.x, it_index / map.size.x };
        sum += 100 * pos.y + pos.x;
    }

    return sum;
}

clear_both_sides :: (map: Map, a: Vec2, b: Vec2, move: Vec2) -> bool {
    new_a := Vec2.{ a.x + move.x, a.y + move.y };
    new_b := Vec2.{ b.x + move.x, b.y + move.y };

    a_index := a.y * map.size.x + a.x;
    b_index := b.y * map.size.x + b.x;
    new_a_index := new_a.y * map.size.x + new_a.x;
    new_b_index := new_b.y * map.size.x + new_b.x;

    new_a_char := map.data[new_a_index];
    new_b_char := map.data[new_b_index];

    if new_a_char == #char "#" || new_b_char == #char "#"  return false;
    if new_a_char == #char "." && new_b_char == #char "."  return true;

    clear := true;
    if new_a_char == #char "]" || new_a_char == #char "[" {
        other_a := ifx new_a_char == #char "[" then new_a else Vec2.{ new_a.x - 1, new_a.y };
        other_b := ifx new_a_char == #char "]" then new_a else Vec2.{ new_a.x + 1, new_a.y };

        if !clear_both_sides(map, other_a, other_b, move)  clear = false;
    }
    if new_b_char == #char "]" || new_b_char == #char "[" {
        other_a := ifx new_b_char == #char "[" then new_b else Vec2.{ new_b.x - 1, new_b.y };
        other_b := ifx new_b_char == #char "]" then new_b else Vec2.{ new_b.x + 1, new_b.y };

        if !clear_both_sides(map, other_a, other_b, move)  clear = false;
    }

    return clear;
}

make_move :: (map: *Map, pos: Vec2, new_pos: Vec2) {
    pos_index := pos.y * map.size.x + pos.x;
    new_pos_index := new_pos.y * map.size.x + new_pos.x;
    pos_char := map.data[pos_index];
    new_pos_char := map.data[new_pos_index];

    map.data[new_pos_index] = pos_char;
    map.data[pos_index] = #char ".";

    if pos_char == #char "@"  map.robot = new_pos;
}

try_move :: (map: *Map, pos: Vec2, move: Vec2) -> bool {
    new_pos := Vec2.{ pos.x + move.x, pos.y + move.y };

    if new_pos.x < 0 || new_pos.x >= map.size.x || new_pos.y < 0 || new_pos.y >= map.size.y {
        log("Tried to move out of bounds: %\n", new_pos, flags = .ERROR);
        return false;
    }

    pos_index := pos.y * map.size.x + pos.x;
    new_pos_index := new_pos.y * map.size.x + new_pos.x;
    pos_char := map.data[pos_index];
    new_pos_char := map.data[new_pos_index];

    if new_pos_char == #char "#"  return false;

    if new_pos_char == #char "." {
        make_move(map, pos, new_pos);
        return true;
    }

    if new_pos_char == #char "O" {
        if !try_move(map, new_pos, move)  return false;
        make_move(map, pos, new_pos);
        return true;
    }

    if new_pos_char == #char "]" || new_pos_char == #char "[" {
        if move.y == 0 {
            if !try_move(map, new_pos, move)  return false;
            make_move(map, pos, new_pos);
            return true;
        } else {
            part_a := ifx new_pos_char == #char "[" then new_pos else Vec2.{ new_pos.x - 1, new_pos.y };
            part_b := ifx new_pos_char == #char "]" then new_pos else Vec2.{ new_pos.x + 1, new_pos.y };

            if !clear_both_sides(map, part_a, part_b, move)  return false;

            try_move(map, part_a, move);
            try_move(map, part_b, move);
            make_move(map, pos, new_pos);
            return true;
        }
    }

    return false;
}

double_width :: (map_src: Map) -> Map {
    map: Map = ---;
    map.size = Vec2.{ map_src.size.x * 2, map_src.size.y };
    map.robot = Vec2.{ map_src.robot.x * 2, map_src.robot.y };
    map.data = NewArray(map.size.x * map.size.y, u8);

    for map_src.data {
        new_index := it_index * 2;
        if it == {
            case #char "#";
                map.data[new_index] = #char "#";
                map.data[new_index + 1] = #char "#";
            case #char ".";
                map.data[new_index] = #char ".";
                map.data[new_index + 1] = #char ".";
            case #char "O";
                map.data[new_index] = #char "[";
                map.data[new_index + 1] = #char "]";
            case #char "@";
                map.data[new_index] = #char "@";
                map.data[new_index + 1] = #char ".";
        }
    }

    return map;
}

parse_input :: (input: string) -> map: Map, moves: []Vec2 {
    result := Map.{
        size = .{ -1, -1 }
    };

    state: u32 = 0; // 0 - parsing map, 1 - parsing moves
    grid: [..]u8;
    moves: [..]Vec2;

    for input {
        if it == #char "\n" {
            if result.size.x == -1  result.size.x = it_index;
            if it_index < input.count - 1 && input[it_index + 1] == #char "\n" {
                result.size.y = ((it_index + 1) / result.size.x) - 1; // -1 because we don't count new line char
                state = 1;
                continue;
            }
            continue;
        }

        if state == 0 {
            array_add(*grid, it);

            if it == #char "@"  result.robot = Vec2.{ grid.count % result.size.x - 1, grid.count / result.size.x };
        } else if state == 1 {
            if it == {
                case #char "^";  array_add(*moves, .{  0, -1 });
                case #char "v";  array_add(*moves, .{  0,  1 });
                case #char "<";  array_add(*moves, .{ -1,  0 });
                case #char ">";  array_add(*moves, .{  1,  0 });
            }
        }
    }

    result.data = grid;
    return result, moves;
}

map_copy :: (map: Map) -> Map {
    return .{
        size = map.size,
        robot = map.robot,
        data = array_copy(map.data)
    };
}

free :: (map: Map) {
    array_free(map.data);
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    map, moves := parse_input(input);
    defer free(map);
    defer array_free(moves);

    first := first_star(map, moves);
    second := second_star(map, moves);

    assert(first == EXAMPLE_ANSWER_FIRST);
    assert(second == EXAMPLE_ANSWER_SECOND);
}

main :: () {
    validate_example();
    if !file_exists(INPUT_FILE) {
        print("Input file for day 15 not found: '%'\n", INPUT_FILE);
        return;
    }

    input := read_entire_file(INPUT_FILE);

    map, moves := parse_input(input);
    defer free(map);
    defer array_free(moves);

    first := first_star(map, moves);
    second := second_star(map, moves);

    print("First star: %\n", first);
    print("Second star: %\n", second);
}
