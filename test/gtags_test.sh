#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 2

global_should_find_one() {
    local result symbol
    symbol=$1
    set +e
    global -x --literal "$symbol" | wc -l | grep 1 >/dev/null
    result=$?
    set -e
    if [[ $result -ne 0 ]]; then
        echo "Test failed: $symbol"
        global -x --literal "$symbol"
        exit 1
    fi
}

SYMBOLS=(
    # CSS
    '#less-id-simple'
    .less-class-simple
    less-div.class-with-elem
    '@less-font-size'
    scss-mixin-simple
    '#scss-id-simple'
    .scss-class-simple
    scss-div.class-with-elem
    '$scss-font-size'

    # JS
    jsFunctionNoParams
    jsFunctionOneParam
    jsFunctionManyParams
    JsFunctionCapitalized
    jsFunctionAsync
    jsFunctionGenerator
    jsFunctionIIFE
    jsFunctionAssignFunctionNoParams
    jsFunctionAssignFunctionOneParam
    jsFunctionAssignFunctionManyParams
    jsFunctionAssignAsync
    jsFunctionAssignGenerator
    jsFunctionAssignArrow
    jsNullSimple
    jsBooleanTrue
    jsBooleanFalse
    jsNumberSimple
    jsStringSingleQuoted
    jsStringDoubleQuoted
    jsRegexSimple
    jsArraySimple
    JsArrayCapitalized
    jsObjectSimple
    JsObjectCapitalized
    jsFieldSimple
    JsFieldCapitalized
    jsFieldAssignDotNotation
    jsFieldSingleQuoted
    jsFieldDoubleQuoted
    JsKlassSimple
    JsKlassExtends
    JsKlassReactCreate
    jsMethodNoParams
    jsMethodOneParam
    jsMethodManyParams
    JsMethodCapitalized
    jsMethodStatic
    jsMethodAsync
    jsMethodStaticAsync
    jsMethodGenerator
    jsMethodStaticGenerator

    # Ruby
    RUBY_CONSTANT_SIMPLE
)

gtags

for symbol in "${SYMBOLS[@]}"; do
    global_should_find_one "$symbol"
done

echo "gtags tests passed."
