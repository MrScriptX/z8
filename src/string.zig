pub fn compare(a: []const u8, b: []const u8) bool {
    if (a.len != b.len)
        return false;

    if (a.ptr == b.ptr)
        return true;

    for (a, b) |a_byte, b_byte| {
        if (a_byte != b_byte)
            return false;
    }

    return true;
}

pub fn partial_compare(a: []const u8, b: []const u8) bool {
    if (a.len > b.len)
        return false;

    var i: usize = 0;
    while (i < a.len) {
        if (a[i] != b[i])
            return false;

        i += 1;
    }

    return true;
}
