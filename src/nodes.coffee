class Type
  constructor: ({@name, @required}) ->

  print: ->
    "PropTypes.#{@name.toLowerCase()}#{if @required then '.isRequired' else ''}"

class ArrayOf
  constructor: ({@inner, @required}) ->

  print: ->
    "PropTypes.arrayOf(#{@inner.print()})#{if @required then '.isRequired' else ''}"

class Property
  constructor: ({@name, @value}) ->

  print: ->
    "#{@name}: #{@value.print()}"

class Shape
  constructor: ({@properties, @required}) ->

  print: ->
    "PropTypes.shape({#{
      (property.print() for property in @properties).join(', ')
    }})#{if @required then '.isRequired' else ''}"

module.exports = {Type, ArrayOf, Property, Shape}
