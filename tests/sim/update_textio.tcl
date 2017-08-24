# Filter block textio files removal
remove_files -fileset sim_1 {../PandABox/fpga_sequences/adder_bus_in.txt
../PandABox/fpga_sequences/adder_reg_in.txt
../PandABox/fpga_sequences/adder_bus_out.txt
../PandABox/fpga_sequences/clocks_bus_in.txt
../PandABox/fpga_sequences/clocks_bus_out.txt
../PandABox/fpga_sequences/clocks_reg_in.txt
../PandABox/fpga_sequences/clocks_reg_out.txt
../PandABox/fpga_sequences/bits_bus_in.txt
../PandABox/fpga_sequences/bits_bus_out.txt
../PandABox/fpga_sequences/bits_reg_in.txt
../PandABox/fpga_sequences/bits_reg_out.txt
../PandABox/fpga_sequences/counter_bus_in.txt
../PandABox/fpga_sequences/counter_bus_out.txt
../PandABox/fpga_sequences/counter_reg_in.txt
../PandABox/fpga_sequences/counter_reg_out.txt
../PandABox/fpga_sequences/pgen_bus_in.txt
../PandABox/fpga_sequences/pgen_bus_out.txt
../PandABox/fpga_sequences/pgen_reg_in.txt
../PandABox/fpga_sequences/pgen_reg_out.txt
../PandABox/fpga_sequences/div_bus_in.txt
../PandABox/fpga_sequences/div_bus_out.txt
../PandABox/fpga_sequences/div_reg_in.txt
../PandABox/fpga_sequences/div_reg_out.txt
../PandABox/fpga_sequences/filter_bus_in.txt
../PandABox/fpga_sequences/filter_bus_out.txt
../PandABox/fpga_sequences/filter_reg_in.txt
../PandABox/fpga_sequences/filter_reg_out.txt
../PandABox/fpga_sequences/lut_bus_in.txt
../PandABox/fpga_sequences/lut_bus_out.txt
../PandABox/fpga_sequences/lut_reg_in.txt
../PandABox/fpga_sequences/lut_reg_out.txt
../PandABox/fpga_sequences/pcap_bit_bus.txt
../PandABox/fpga_sequences/pcap_bus_in.txt
../PandABox/fpga_sequences/pcap_bus_out.txt
../PandABox/fpga_sequences/pcap_reg_in.txt
../PandABox/fpga_sequences/pcap_reg_out.txt
../PandABox/fpga_sequences/pcap_pos_bus.txt
../PandABox/fpga_sequences/pcomp_bus_in.txt
../PandABox/fpga_sequences/pcomp_bus_out.txt
../PandABox/fpga_sequences/pcomp_reg_in.txt
../PandABox/fpga_sequences/pcomp_reg_out.txt
../PandABox/fpga_sequences/pulse_bus_in.txt
../PandABox/fpga_sequences/pulse_bus_out.txt
../PandABox/fpga_sequences/pulse_reg_in.txt
../PandABox/fpga_sequences/pulse_reg_out.txt
../PandABox/fpga_sequences/seq_bus_in.txt
../PandABox/fpga_sequences/seq_bus_out.txt
../PandABox/fpga_sequences/seq_reg_in.txt
../PandABox/fpga_sequences/seq_reg_out.txt
../PandABox/fpga_sequences/srgate_bus_in.txt
../PandABox/fpga_sequences/srgate_bus_out.txt
../PandABox/fpga_sequences/srgate_reg_in.txt
../PandABox/fpga_sequences/srgate_reg_out.txt
}

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse {../PandABox/fpga_sequences/adder_bus_in.txt
../PandABox/fpga_sequences/adder_reg_in.txt
../PandABox/fpga_sequences/adder_bus_out.txt
../PandABox/fpga_sequences/clocks_reg_in.txt
../PandABox/fpga_sequences/clocks_bus_in.txt
../PandABox/fpga_sequences/clocks_reg_out.txt
../PandABox/fpga_sequences/clocks_bus_out.txt
../PandABox/fpga_sequences/bits_bus_in.txt
../PandABox/fpga_sequences/bits_bus_out.txt
../PandABox/fpga_sequences/bits_reg_in.txt
../PandABox/fpga_sequences/bits_reg_out.txt
../PandABox/fpga_sequences/counter_bus_in.txt
../PandABox/fpga_sequences/counter_bus_out.txt
../PandABox/fpga_sequences/counter_reg_in.txt
../PandABox/fpga_sequences/counter_reg_out.txt
../PandABox/fpga_sequences/pgen_bus_in.txt
../PandABox/fpga_sequences/pgen_bus_out.txt
../PandABox/fpga_sequences/pgen_reg_in.txt
../PandABox/fpga_sequences/pgen_reg_out.txt
../PandABox/fpga_sequences/div_bus_in.txt
../PandABox/fpga_sequences/div_bus_out.txt
../PandABox/fpga_sequences/div_reg_in.txt
../PandABox/fpga_sequences/div_reg_out.txt
../PandABox/fpga_sequences/filter_reg_in.txt
../PandABox/fpga_sequences/filter_bus_in.txt
../PandABox/fpga_sequences/filter_reg_out.txt
../PandABox/fpga_sequences/filter_bus_out.txt
../PandABox/fpga_sequences/lut_bus_in.txt
../PandABox/fpga_sequences/lut_bus_out.txt
../PandABox/fpga_sequences/lut_reg_in.txt
../PandABox/fpga_sequences/lut_reg_out.txt
../PandABox/fpga_sequences/pcap_bit_bus.txt
../PandABox/fpga_sequences/pcap_bus_in.txt
../PandABox/fpga_sequences/pcap_bus_out.txt
../PandABox/fpga_sequences/pcap_reg_in.txt
../PandABox/fpga_sequences/pcap_reg_out.txt
../PandABox/fpga_sequences/pcap_pos_bus.txt
../PandABox/fpga_sequences/pcomp_bus_in.txt
../PandABox/fpga_sequences/pcomp_bus_out.txt
../PandABox/fpga_sequences/pcomp_reg_in.txt
../PandABox/fpga_sequences/pcomp_reg_out.txt
../PandABox/fpga_sequences/pulse_reg_in.txt
../PandABox/fpga_sequences/pulse_bus_in.txt
../PandABox/fpga_sequences/pulse_reg_out.txt
../PandABox/fpga_sequences/pulse_bus_out.txt
../PandABox/fpga_sequences/seq_bus_in.txt
../PandABox/fpga_sequences/seq_bus_out.txt
../PandABox/fpga_sequences/seq_reg_in.txt
../PandABox/fpga_sequences/seq_reg_out.txt
../PandABox/fpga_sequences/srgate_bus_in.txt
../PandABox/fpga_sequences/srgate_bus_out.txt
../PandABox/fpga_sequences/srgate_reg_in.txt
../PandABox/fpga_sequences/srgate_reg_out.txt
}
