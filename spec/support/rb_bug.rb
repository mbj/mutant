require 'ffi'

module RbBug
  extend FFI::Library
  ffi_lib 'ruby'
  attach_function :rb_bug, [:string, :varargs], :void

  # Call the test bug
  #
  # @return [undefined]
  #
  # @api private
  #
  def self.call
    rb_bug('%s', :string, 'test bug')
  end

end # RbBug
