require 'ffi'

# @api private
module RbBug
  extend FFI::Library
  ffi_lib 'ruby'
  attach_function :rb_bug, %i[string varargs], :void

  # Call the test bug
  #
  # @return [undefined]
  def self.call
    rb_bug('%s', :string, 'test bug')
  end

end # RbBug
