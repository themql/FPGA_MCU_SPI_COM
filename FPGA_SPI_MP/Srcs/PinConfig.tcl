set_location_assignment PIN_T2   -to clk
set_location_assignment PIN_W13  -to rst_n
set_location_assignment PIN_W22  -to spi_scl
set_location_assignment PIN_B9   -to spi_sdi
set_location_assignment PIN_A7   -to spi_sdo
set_location_assignment PIN_A6   -to spi_cs_cmd
set_location_assignment PIN_B6   -to spi_cs_data

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rst_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_scl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_sdi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_sdo
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_cs_cmd
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_cs_data