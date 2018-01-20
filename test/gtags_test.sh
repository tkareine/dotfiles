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
    '#less-id-simple'
    .less-class-simple
    less-div.class-with-elem
    '@less-font-size'
    scss-mixin-simple
    '#scss-id-simple'
    .scss-class-simple
    scss-div.class-with-elem
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
    jsFieldAssignDotNotation
    jsFieldSingleQuoted
    jsFieldDoubleQuoted
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
