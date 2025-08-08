# frozen_string_literal: true

# Software:
# -> periodically writes(!) 0 to WDCSR
# -> can read fields as normal
# Hardware:
# -> trigger when SW writes
# ->

register_block {
  name 'wdgrv_regs'
  byte_size 8

  # RISC-V spec register
  register {
    name 'wdcsr'
    bit_field { name 'wden'; bit_assignment width: 1; type :rw  ; initial_value 0; comment 'this is <%= bit_field.full_name %>' }
    bit_field { name 'rvd1'; bit_assignment width: 1; type :ro  ; initial_value 0 }
    bit_field { name 's1wto'; bit_assignment width: 1; type [:custom, sw_read: :default, sw_write: :clear_0, hw_set: :true, write_trigger: :true]; initial_value 0 }
    bit_field { name 's2wto'; bit_assignment width: 1; type [:custom, sw_read: :default, sw_write: :clear_0, hw_set: :true, write_trigger: :true]; initial_value 0 }
    bit_field { name 'wtocnt'; bit_assignment width: 10; type :rw ; initial_value 1023 }
    bit_field { name 'rvd2'; bit_assignment width: 18; type :ro ; initial_value 0 }
  }

  # Plattform specific register
  # > (current count)
  register {
    name 'wdcnt'
    bit_field { name 'cnt'; bit_assignment width: 32; type :ro; initial_value 0 }
  }
}