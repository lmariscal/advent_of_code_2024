#import "Basic";
#import "File";
#import "Sort";
#import "String";
#import "Math";
#import "Hash_Table";

EXAMPLE_INPUT :: #string DONE
3   4
4   3
2   5
1   3
3   9
3   3
DONE

EXAMPLE_ANSWER_FIRST :: 11;
EXAMPLE_ANSWER_SECOND :: 31;

first_star :: (left_list: []s64, right_list: []s64) -> total: s64 {
    assert(left_list.count == right_list.count, "Lists must have the same length");

    total := 0;
    for 0..left_list.count - 1 {
        left := left_list[it];
        right := right_list[it];
        dist := abs(right - left);
        total += dist;
    }

    return total;
}

second_star :: (left_list: []s64, right_list: []s64) -> total: s64 {
    assert(left_list.count == right_list.count, "Lists must have the same length");

    table: Table(s64, s64);
    defer deinit(*table);
    table_ensure_space(*table, left_list.count);

    for right_list {
        count := find_or_add(*table, it);
        count.* += 1;
    }

    total := 0;
    for left_list {
        item := 0;
        count := table_find_pointer(*table, it);
        if count != null  item = it * count.*;
        total += item;
    }

    return total;
}

next_token :: (str: string, cursor: *s64) -> token: string {
    SEPARATORS :: u8.[#char " ", #char "\t", #char "\n", #char "\r"];
    result: string = .{ data = str.data + cursor.*, count = 0 };
    if cursor.* >= str.count return result;

    while cursor.* < str.count {
        if array_find(SEPARATORS, str[cursor.*]) {
            result.count = cursor.* - (result.data - str.data);
            while cursor.* < str.count - 1 && array_find(SEPARATORS, str[cursor.*]) cursor.* += 1;
            break;
        }
        cursor.* += 1;
    }

    return result;
}

parse_input :: (input: string) -> left_list: []s64, right_list: []s64 {
    left_list: [..]s64; array_reserve(*left_list, 1000);
    right_list: [..]s64; array_reserve(*right_list, 1000);

    cursor := 0;
    token := next_token(input, *cursor);
    while token.count > 0 {
        array_add(*left_list, string_to_int(token));
        token = next_token(input, *cursor);
        array_add(*right_list, string_to_int(token));
        token = next_token(input, *cursor);
    }

    quick_sort(left_list, x => x);
    quick_sort(right_list, x => x);

    return left_list, right_list;
}

validate_example :: () {
    input := EXAMPLE_INPUT;

    left_list, right_list := parse_input(input);
    defer array_free(left_list);
    defer array_free(right_list);

    first := first_star(left_list, right_list);
    second := second_star(left_list, right_list);

    assert(first == EXAMPLE_ANSWER_FIRST);
    assert(second == EXAMPLE_ANSWER_SECOND);
}

main :: () {
    validate_example();

    input := read_entire_file("./inputs/01.txt");
    left_list, right_list := parse_input(input);
    defer array_free(left_list);
    defer array_free(right_list);

    first := first_star(left_list, right_list);
    second := second_star(left_list, right_list);

    print("First star: %\n", first);
    print("Second star: %\n", second);
}
