next_token :: (
    str: string,
    cursor: *s64,
    $delimiters: []u8 = u8.[#char " ", #char "\n", #char "\t", #char "\r"],
    $skip_extra: bool = true
) -> token: string, new_line: bool {
    result: string = .{ data = str.data + cursor.*, count = 0 };
    is_new_line: bool = false;

    while cursor.* < str.count {
        defer cursor.* += 1;
        if array_find(delimiters, str[cursor.*]) {
            data_offset := result.data - str.data;
            result.count = cursor.* - data_offset;
            if str[cursor.*] == #char "\n"  is_new_line = true;
            break;
        }
    }

    #if skip_extra {
        while cursor.* < str.count && array_find(delimiters, str[cursor.*]) {
            if str[cursor.*] == #char "\n"  is_new_line = true;
            cursor.* += 1;
        }
    }

    return result, is_new_line;
}
