#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 2

global_should_find() {
    local expect_num_matches symbol result
    expect_num_matches=$1
    symbol=$2

    set +e
    global -x --literal "$symbol" | wc -l | grep "$expect_num_matches" >/dev/null
    result=$?
    set -e

    if [[ $result -ne 0 ]]; then
        echo "Test failed (expect $expect_num_matches match): $symbol"
        global -x --literal "$symbol"
        exit 1
    fi
}

SYMBOLS_GLOBAL_SHOULD_FIND_ONE=(
    '@less-str'
    '#less-id-line1'
    '#less-id-line2'
    .less-class-line1
    .less-class-line2
    less-div.class-with-elem1
    less-div.class-with-elem2
    '@less-font-size'

    '$scss-str'
    scss-mixin-simple
    '#scss-id-line1'
    '#scss-id-line2'
    .scss-class-line1
    .scss-class-line2
    scss-div.class-with-elem1
    scss-div.class-with-elem2
    '$scss-font-size'

    jsFunctionNoParams
    jsFunctionOneParam
    jsFunctionManyParams
    jsFunctionMultilineParams
    jsFunctionSpaceBeforeParams
    JsFunctionCapitalized
    jsFunctionAsync
    jsFunctionAsyncGenerator
    jsFunctionGeneratorSpaceBeforeAsterisk
    jsFunctionGeneratorSpaceAfterAsterisk
    jsFunctionIIFE
    jsFunctionAssignFunctionNoParams
    jsFunctionAssignFunctionOneParam
    jsFunctionAssignFunctionManyParams
    jsFunctionAssignFunctionMultilineParams
    jsFunctionAssignFunctionSpaceBeforeParams
    jsFunctionAssignAsync
    jsFunctionAssignAsyncGenerator
    jsFunctionAssignGeneratorSpaceBeforeAsterisk
    jsFunctionAssignGeneratorSpaceAfterAsterisk
    jsFunctionAssignArrow
    jsNullSimple
    jsBooleanTrue
    jsBooleanFalse
    jsNumberSimple
    jsStringSingleQuoted
    jsStringDoubleQuoted
    jsStringTemplateLiteral
    jsStringTaggedTemplateLiteral
    jsRegexSimple
    jsArraySimple
    JsArrayCapitalized
    jsObjectSimple
    JsObjectCapitalized
    jsFieldSimple
    JsFieldCapitalized
    jsFieldCommaBefore
    jsFieldAssignDotNotation
    jsFieldSingleQuoted
    jsFieldDoubleQuoted
    jsFieldJSXAttribute
    JsClassStatementNoExtends
    JsClassStatementExtends
    JsClassStatementNewlineBeforeOpeningBrace
    JsClassExpressionAnonymousSpaceAfterClass
    JsClassExpressionAnonymousNoSpaceAfterClass
    JsClassExpressionNameInClassScope
    JsClassExpressionReactCreate
    jsMethodNoParams
    jsMethodOneParam
    jsMethodManyParams
    JsMethodCapitalized
    jsMethodStatic
    jsMethodAsync
    jsMethodAsyncGenerator
    jsMethodStaticAsync
    jsMethodStaticAsyncGenerator
    jsMethodGeneratorNoSpaceAfterAsterisk
    jsMethodGeneratorSpaceAfterAsterisk
    jsMethodStaticGeneratorSpaceBeforeAsterisk
    jsMethodStaticGeneratorSpaceAfterAsterisk

    RUBY_CONSTANT_SIMPLE
)

SYMBOLS_GLOBAL_SHOULD_FIND_ZERO=(
    '#less-id-@{less-str}'
    less-elem
    '.less-class-@{less-str}'

    '#scss-id-#{$scss-str}'
    scss-elem
    '.scss-class-#{$scss-str}'

    jsFunctionCall

    # must not find, otherwise would make definition out of a function call
    jsMethodMultilineParams
)

gtags

for symbol in "${SYMBOLS_GLOBAL_SHOULD_FIND_ONE[@]}"; do
    global_should_find 1 "$symbol"
done

for symbol in "${SYMBOLS_GLOBAL_SHOULD_FIND_ZERO[@]}"; do
    global_should_find 0 "$symbol"
done

echo "gtags tests passed."
