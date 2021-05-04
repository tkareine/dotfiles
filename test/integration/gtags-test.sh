#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}/../fixture/gtags/" || exit 2

global_should_find() {
    local expect_num_matches symbol
    expect_num_matches=$1
    symbol=$2

    if ! global -x --literal "$symbol" | wc -l | grep -q "\<$expect_num_matches\>" ; then
        echo "Test failed (expect $expect_num_matches match): $symbol"
        global -x --literal "$symbol"
        exit 1
    fi
}

SYMBOLS_GLOBAL_SHOULD_FIND_ONE=(
    less-var-str
    less-var-font-size
    less-id-line1
    less-id-line2
    less-id-with-elem
    less-class-line1
    less-class-line2
    less-class-with-elem1
    less-class-with-elem2

    scss-var-str
    scss-var-font-size
    scss-mixin-no-params
    scss-mixin-one-param
    scss-mixin-many-params
    scss-id-line1
    scss-id-line2
    scss-id-with-elem
    scss-class-line1
    scss-class-line2
    scss-class-with-elem1
    scss-class-with-elem2

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
    jsMethodAtStartOfLine
    jsMethodStatic
    jsMethodStaticAtStartOfLine
    jsMethodAsync
    jsMethodAsyncAtStartOfLine
    jsMethodAsyncGenerator
    jsMethodStaticAsync
    jsMethodStaticAsyncAtStartOfLine
    jsMethodGeneratorNoSpaceAfterAsterisk
    jsMethodGeneratorSpaceAfterAsterisk
    jsMethodGeneratorAtStartOfLine
    jsMethodStaticGeneratorSpaceBeforeAsterisk
    jsMethodStaticGeneratorSpaceAfterAsterisk
    jsMethodStaticAsyncGenerator

    RUBY_CONSTANT_SIMPLE

    yaml_mapping_plain
    yaml_mapping_single_quoted
    yaml_mapping_double_quoted
    yaml_ansible_register_key_plain_value_plain
    yaml_ansible_register_key_plain_value_single_quoted
    yaml_ansible_register_key_plain_value_double_quoted
    yaml_ansible_register_key_single_quoted_value_plain
    yaml_ansible_register_key_double_quoted_value_plain
    yaml_anchor-dedicated_line
    yaml_anchor-map
    yaml_anchor-list_elem
    yaml_anchor-before_block_scalar
)

# shellcheck disable=SC2016
SYMBOLS_GLOBAL_SHOULD_FIND_ZERO=(
    less-elem
    'less-id-@{less-str}'
    'less-class-@{less-str}'

    scss-elem
    'scss-id-#{$scss-str}'
    'scss-class-#{$scss-str}'

    jsFunctionCall

    # must not find, otherwise would make definition out of a function call
    jsMethodMultilineParams

    # must not leak from JS method definition
    'function'
)

gtags .

for symbol in "${SYMBOLS_GLOBAL_SHOULD_FIND_ONE[@]}"; do
    global_should_find 1 "$symbol"
done

for symbol in "${SYMBOLS_GLOBAL_SHOULD_FIND_ZERO[@]}"; do
    global_should_find 0 "$symbol"
done
