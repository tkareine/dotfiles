function jsFunctionNoParams() {
  return 42
}

function jsFunctionOneParam(a) {
  return 42
}

function jsFunctionManyParams(a, {b, c}) {
  return 42
}

function jsFunctionMultilineParams(
  a,
  {b, c}
) {
  return 42
}

function jsFunctionSpaceBeforeParams (a) {
  return 42
}

function JsFunctionCapitalized() {
  return 42
}

async function jsFunctionAsync() {
  return 42
}

async function* jsFunctionAsyncGenerator() {
  return 42
}

function *jsFunctionGeneratorSpaceBeforeAsterisk() {
  return 42
}

function* jsFunctionGeneratorSpaceAfterAsterisk() {
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

const jsFunctionAssignFunctionMultilineParams = function(
  a,
  {b, c}
) {
  return 42
}

const jsFunctionAssignFunctionSpaceBeforeParams = function (a) {
  return 42
}

const jsFunctionAssignAsync = async function() {
  return 42
}

const jsFunctionAssignAsyncGenerator = async function*() {
  return 42
}

const jsFunctionAssignGeneratorSpaceBeforeAsterisk = function *() {
  return 42
}

const jsFunctionAssignGeneratorSpaceAfterAsterisk = function* () {
  return 42
}

const jsFunctionAssignArrow = () =>
  42

jsFunctionCall()

const jsNullSimple = null

const jsBooleanTrue = true

const jsBooleanFalse = false

const jsNumberSimple = 42

const jsStringSingleQuoted = 'lol'

const jsStringDoubleQuoted = "bal"

const jsStringTemplateLiteral = `
man ${jsBooleanTrue} zap`

const jsStringTaggedTemplateLiteral = sql`
man ${jsBooleanTrue} zap`

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

  jsMethodMultilineParams(
    a,
    b
  ) {
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

  async * jsMethodAsyncGenerator() {
    return 42
  }

  static async jsMethodStaticAsync() {
    return 42
  }

  static async * jsMethodStaticAsyncGenerator() {
    return 42
  }

  *jsMethodGeneratorNoSpaceAfterAsterisk() {
    return 42
  }

  * jsMethodGeneratorSpaceAfterAsterisk() {
    return 42
  }

  static *jsMethodStaticGeneratorSpaceBeforeAsterisk() {
    return 42
  }

  static* jsMethodStaticGeneratorSpaceAfterAsterisk() {
    return 42
  }
}

class JsKlassExtends extends JsKlassSimple {
}

const JsKlassReactCreate = React.createClass({})
