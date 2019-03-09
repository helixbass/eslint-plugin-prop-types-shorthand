rule = require '../../rules/no-string-prop-types'
{RuleTester} = require 'eslint'

ruleTester = new RuleTester()

error = (key) ->
  message: "String prop type found: #{key}"

tests =
  valid: [
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.string,
      }
    '''
  ,
    code: '''
      const Foo = ({a}) => <div>{a}</div>
    '''
  ]
  invalid: [
    # simple type
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: 'string',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.string,
      }
    '''
    errors: [error('a')]
  ,
    # required type
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: 'Bool!',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.bool.isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # simple array
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '[]',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.array,
      }
    '''
    errors: [error('a')]
  ,
    # required array
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '[]!',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.array.isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # array of type
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '[string]',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.arrayOf(PropTypes.string),
      }
    '''
    errors: [error('a')]
  ,
    # array of required type
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '[string!]',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.arrayOf(PropTypes.string.isRequired),
      }
    '''
    errors: [error('a')]
  ,
    # required array of
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '[string]!',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.arrayOf(PropTypes.string).isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # simple object
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '{}',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.object,
      }
    '''
    errors: [error('a')]
  ,
    # required object
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '{}!',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.object.isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # shape
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '{b: string}',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.shape({b: PropTypes.string}),
      }
    '''
    errors: [error('a')]
  ,
    # required shape
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '{b: string}!',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.shape({b: PropTypes.string}).isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # shape multiple single line
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: '{b: string, c: number!}',
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.shape({b: PropTypes.string, c: PropTypes.number.isRequired}),
      }
    '''
    errors: [error('a')]
  ,
    # shape multiple multi line
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: `{
          b: string,
          c: number!
        }`,
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.shape({b: PropTypes.string, c: PropTypes.number.isRequired}),
      }
    '''
    errors: [error('a')]
  ,
    # nesting
    code: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: `[{
          b: string,
        }]!`,
      }
    '''
    output: '''
      const Foo = ({a}) => <div>{a}</div>

      Foo.propTypes = {
        a: PropTypes.arrayOf(PropTypes.shape({b: PropTypes.string})).isRequired,
      }
    '''
    errors: [error('a')]
  ,
    # addPropTypes()
    code: '''
      const Foo = flowMax(
        addProps({a: 'b'}),
        addPropTypes({
          a: 'string',
        }),
        ({a}) => <div>{a}</div>
      )
    '''
    output: '''
      const Foo = flowMax(
        addProps({a: 'b'}),
        addPropTypes({
          a: PropTypes.string,
        }),
        ({a}) => <div>{a}</div>
      )
    '''
    errors: [error('a')]
  ,
    # setPropTypes()
    code: '''
      const enhance = compose(
        withProps({a: 'b'}),
        setPropTypes({
          a: 'string',
        }),
      )
    '''
    output: '''
      const enhance = compose(
        withProps({a: 'b'}),
        setPropTypes({
          a: PropTypes.string,
        }),
      )
    '''
    errors: [error('a')]
  ,
    # flow()
    code: '''
      const Foo = flow(
        addProps({a: 'b'}),
        ({a}) => <div>{a}</div>
      )

      Foo.propTypes = {
        a: 'string',
      }
    '''
    output: '''
      const Foo = flow(
        addProps({a: 'b'}),
        ({a}) => <div>{a}</div>
      )

      Foo.propTypes = {
        a: PropTypes.string,
      }
    '''
    errors: [error('a')]
  ,
    # flowMax()
    code: '''
      const Foo = flowMax(
        addProps({a: 'b'}),
        ({a}) => <div>{a}</div>
      )

      Foo.propTypes = {
        a: 'string',
      }
    '''
    output: '''
      const Foo = flowMax(
        addProps({a: 'b'}),
        ({a}) => <div>{a}</div>
      )

      Foo.propTypes = {
        a: PropTypes.string,
      }
    '''
    errors: [error('a')]
  ]

config =
  parser: 'babel-eslint'
  parserOptions:
    ecmaVersion: 2018
    ecmaFeatures:
      jsx: yes

Object.assign(test, config) for test in [...tests.valid, ...tests.invalid]

ruleTester.run 'no-string-prop-types', rule, tests
