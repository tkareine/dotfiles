function jsFunctionNoParams() {
  return 42
}

function jsFunctionOneParam(a) {
  return 42
}

function jsFunctionManyParams(a, {b, c}) {
  return 42
}

function JsFunctionCapitalized() {
  return 42
}

async function jsFunctionAsync() {
  return 42
}

function *jsFunctionGenerator() {
  return 42
}

(function jsFunctionIIFE() {
  return 42
})()

const jsFunctionAssignFunctionNoParams = function() {
  return 42
}

const jsFunctionAssignFunctionOneParam = function(a) {
  return 42
}

const jsFunctionAssignFunctionManyParams = function(a, {b, c}) {
  return 42
}

const jsFunctionAssignAsync = async function() {
  return 42
}

const jsFunctionAssignGenerator = function * () {
  return 42
}

const jsFunctionAssignArrow = () =>
  42

const jsNullSimple = null

const jsBooleanTrue = true

const jsBooleanFalse = false

const jsNumberSimple = 42

const jsStringSingleQuoted = 'lol'

const jsStringDoubleQuoted = "bal"

const jsStringInterpolation = `man ${jsBooleanTrue} zap`

const jsRegexSimple = /man/

const jsArraySimple = [
  42
]

const JsArrayCapitalized = [
  42
]

const jsObjectSimple = {
  jsFieldSimple: 42,
  JsFieldCapitalized: 42,
  "jsFieldSingleQuoted": 42,
  "jsFieldDoubleQuoted": 42
}

jsObjectSimple.jsFieldAssignDotNotation = 42

const JsObjectCapitalized = {
}

class JsKlassSimple {
  jsMethodNoParams() {
    return 42
  }

  jsMethodOneParam(a) {
    return 42
  }

  jsMethodManyParams(a, b) {
    return 42
  }

  JsMethodCapitalized() {
    return 42
  }

  static jsMethodStatic() {
    return 42
  }

  async jsMethodAsync() {
    return 42
  }

  static async jsMethodStaticAsync() {
    return 42
  }

  *jsMethodGenerator() {
    return 42
  }

  static *jsMethodStaticGenerator() {
    return 42
  }
}

class JsKlassExtends extends JsKlassSimple {
}

const JsKlassReactCreate = React.createClass({})
