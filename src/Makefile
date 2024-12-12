make:
	iverilog -o out PCS_tb.v
	vvp out
	gtkwave tb_PCS.vcd
clean:
	rm -f tb_PCS.vcd out 