# frozen_string_literal: true

# UNUSED
register_block {
  name 'machine_time'
  byte_size 8

  register {
    name 'mtime'
    bit_field { name 'tim'; bit_assignment width: 64; type :rwhw  ; initial_value 0; comment 'this is <%= bit_field.full_name %>' }
  }

  # Plattform specific register
  # TODO:
  # According to RISC-V these values here should be discoverable by the plattform:
  # > MTIME resolution
  # > MTIME bit position
}