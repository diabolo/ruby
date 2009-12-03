require_relative 'test_base'
require_relative '../ruby/envutil'
require 'dl/callback'
require 'dl/func'

module DL
  class TestCallback < TestBase
    include DL

    def test_callback_return_value
      addr = set_callback(TYPE_VOIDP, 1) do |str|
        str
      end
      func = CFunc.new(addr, TYPE_VOIDP, 'test')
      f = Function.new(func, [TYPE_VOIDP])
      ptr = CPtr['blah']
      assert_equal ptr, f.call(ptr)
    end

    def test_callback_return_arbitrary
      addr = set_callback(TYPE_VOIDP, 1) do |ptr|
        CPtr['foo'].to_i
      end
      func = CFunc.new(addr, TYPE_VOIDP, 'test')
      f = Function.new(func, [TYPE_VOIDP])

      ptr = CPtr['foo']
      assert_equal 'foo', f.call(ptr).to_s
    end

    def test_callback_with_string
      called_with = nil
      addr = set_callback(TYPE_VOID, 1) do |str|
        called_with = dlunwrap(str)
      end
      func = CFunc.new(addr, TYPE_VOID, 'test')

      func.call([dlwrap('foo')])
      assert_equal 'foo', called_with
    end

    def test_call_callback
      called = false

      addr = set_callback(TYPE_VOID, 0) do
        called = true
      end

      func = CFunc.new(addr, TYPE_VOID, 'test')
      func.call([])

      assert called, 'function should be called'
    end
  end
end
