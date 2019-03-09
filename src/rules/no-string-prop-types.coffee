Components = require 'eslint-plugin-react/lib/util/Components'
{isString} = require 'lodash'
{parser} = require '../parser'

parser.yy = require '../nodes'

isStringLiteral = (node) ->
  return yes if node.type is 'Literal' and isString node.value
  return yes if node.type is 'TemplateLiteral' and not node.expressions.length
  no

parse = (node) ->
  stringVal =
    if node.type is 'Literal'
      node.value
    else
      node.quasis[0].value.raw
  parsed = parser.parse stringVal
  # console.log {parsed}
  parsed

reportPropType = ({propType, context}) ->
  {name, node, node: {value}} = propType
  context.report
    node: node,
    message: "String prop type found: #{name}"
    fix: (fixer) ->
      fixer.replaceText value, parse(value).print()

isPropTypesInFlow = (node) ->
  {parent} = node
  return no unless parent.type is 'CallExpression' and node is parent.arguments[0]
  {callee} = parent
  return no unless callee.name in ['addPropTypes', 'setPropTypes']
  yes

isPropTypesInAssignment = (node) ->
  {parent} = node
  return unless parent.type is 'AssignmentExpression'
  return unless parent.left.type is 'MemberExpression'
  return unless parent.left.property.type is 'Identifier'
  return unless parent.left.property.name is 'propTypes'
  yes

module.exports =
  meta:
    docs:
      description: 'Enforce that no strings are used as the value of prop types'
      category: 'Possible Errors'
      recommended: yes
    schema: []
    fixable: yes

  create: Components.detect (context, components) ->
    alreadyChecked = []
    checkPropType = (propType) ->
      return if propType.node in alreadyChecked
      alreadyChecked.push propType.node
      {node: {value}} = propType
      return unless isStringLiteral value
      reportPropType {propType, context}

    checkPropTypes = (component) ->
      checkPropType(propType) for _, propType of component.declaredPropTypes

    'Program:exit': ->
      list = components.list()
      checkPropTypes(component) for _, component of list

    ObjectExpression: (node) ->
      return unless isPropTypesInFlow(node) or isPropTypesInAssignment node
      checkPropTypes
        declaredPropTypes:
          {name: property.key.name, node: property} for property in node.properties when property.key.type is 'Identifier'
