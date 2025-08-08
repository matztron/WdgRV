## wdgrv_regs

* byte_size
    * 8
* bus_width
    * 32

|name|offset_address|
|:--|:--|
|[wdcsr](#wdgrv_regs-wdcsr)|0x0|
|[wdcnt](#wdgrv_regs-wdcnt)|0x4|

### <div id="wdgrv_regs-wdcsr"></div>wdcsr

* offset_address
    * 0x0
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|wden|[0]|rw|0x0|||this is wdcsr.wden|
|rvd1|[1]|ro|0x0||||
|s1wto|[2]|custom<br>sw_read: default<br>sw_write: clear_0<br>sw_write_once: false<br>hw_write: false<br>hw_set: true<br>hw_clear: false|0x0||||
|s2wto|[3]|custom<br>sw_read: default<br>sw_write: clear_0<br>sw_write_once: false<br>hw_write: false<br>hw_set: true<br>hw_clear: false|0x0||||
|wtocnt|[13:4]|rw|0x3ff||||
|rvd2|[31:14]|ro|0x00000||||

### <div id="wdgrv_regs-wdcnt"></div>wdcnt

* offset_address
    * 0x4
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|cnt|[31:0]|ro|0x00000000||||
