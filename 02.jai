#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File_Utilities";

#load "utils.jai";

EXAMPLE_INPUT :: #string DONE
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
DONE

EXAMPLE_ANSWER_FIRST :: 2;
EXAMPLE_ANSWER_SECOND :: 4;

INPUT_FILE :: "./inputs/02.txt";

first_star :: (levels: [][]s64) -> total: s64 {
    safe_reports := 0;
    for levels  if is_safe(it)  safe_reports += 1;
    return safe_reports;
}

second_star :: (levels: [][]s64) -> total: s64 {
    safe_reports := 0;
    for lvl: levels  {
        if is_safe(lvl) {
            safe_reports += 1;
            continue;
        }

        for 0..lvl.count - 1 {
            sub_lvl := NewArray(lvl.count - 1, s64, initialized = false);
            defer array_free(sub_lvl);
            if it != 0
                memcpy(sub_lvl.data, lvl.data, it * size_of(s64));
            if it != lvl.count - 1
                memcpy(sub_lvl.data + it, lvl.data + it + 1, (lvl.count - it - 1) * size_of(s64));

            if is_safe(sub_lvl)  {
                safe_reports += 1;
                break;
            }
        }
    }
    return safe_reports;
}

is_safe :: (reports: []s64) -> safe: bool {
    trend := 0;
    for reports {
        if it_index == 0  continue;
        if it > reports[it_index - 1] {
            if trend == -1  return false;
            trend = 1;
        } else if it < reports[it_index - 1] {
            if trend == 1  return false;
            trend = -1;
        }

        dist := abs(it - reports[it_index - 1]);
        if dist > 3 || dist < 1  return false;
    }
    return true;
}

parse_input :: (input: string) -> levels: [][]s64 {
    levels: [..][]s64;

    cursor := 0;
    reports: [..]s64;
    token, is_new_line := next_token(input, *cursor);
    while token.count > 0 {
        number := string_to_int(token);
        array_add(*reports, number);

        if is_new_line {
            array_add(*levels, array_copy(reports));
            array_reset(*reports);
        }

        token, is_new_line = next_token(input, *cursor);
    }

    return levels;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    levels := parse_input(input);
    defer array_free(levels);

    first := first_star(levels);
    second := second_star(levels);

    assert(first == EXAMPLE_ANSWER_FIRST);
    assert(second == EXAMPLE_ANSWER_SECOND);

    for levels  array_free(it);
}

main :: () {
    validate_example();
    if !file_exists(INPUT_FILE) {
        print("Input file for day 02 not found: '%'\n", INPUT_FILE);
        return;
    }

    input := read_entire_file(INPUT_FILE);

    levels := parse_input(input);
    defer array_free(levels);

    first := first_star(levels);
    second := second_star(levels);

    print("First star %\n", first);
    print("Second star %\n", second);

    for levels  array_free(it);
}
