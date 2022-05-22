#!/usr/bin/env bash

set -euo pipefail

source test/support/assertions.sh

test_input_from_stdin() {
    local expected actual
    expected=$(__print_json)
    actual=$(__print_yaml | yaml2json)
    assert_equal "$actual" "$expected"
}

test_input_from_file() {
    local expected actual
    expected=$(__print_json)
    actual=$(yaml2json <(__print_yaml))
    assert_equal "$actual" "$expected"
}

__print_json() {
    cat << END
{
  "string": "foo",
  "list": [
    "bar",
    42
  ],
  "map": {
    "a": "s",
    "b": 2
  }
}
END
}

__print_yaml() {
    cat << END
string: foo
list:
- bar
- 42
map:
  a: s
  b: 2
END
}

TEST_SOURCE=$0 source test/support/suite.sh
