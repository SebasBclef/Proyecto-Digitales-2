`ifndef TABLAS_CODE_GROUPS
    `define TABLAS_CODE_GROUPS

    // Tabla de los Code Groups ESPECIALES Validos segun el estandar, en 8 bits
    `define K28_0_8bits 8'h1C
    `define K28_1_8bits 8'h3C
    `define K28_2_8bits 8'h5C
    `define K28_3_8bits 8'h7C
    `define K28_4_8bits 8'h9C
    `define K28_5_8bits 8'hBC // Para cuando se envie /COMMA/
    `define K28_6_8bits 8'hDC
    `define K28_7_8bits 8'hFC
    `define K23_7_8bits 8'hF7 // Para cuando se envie /R/
    `define K27_7_8bits 8'hFB // Para cuando se envie /S/
    `define K29_7_8bits 8'hFD // Para cuando se envie /T/
    `define K30_7_8bits 8'hFE // Para cuando se envie /V/
    // Tabla de los Code Groups ESPECIALES Validos segun el estandar, en 10 bits
    `define K28_0_10bits 10'b11_0000_1011
    `define K28_1_10bits 10'b11_0000_0110
    `define K28_2_10bits 10'b11_0000_1010
    `define K28_3_10bits 10'b11_0000_1100
    `define K28_4_10bits 10'b11_0000_1101
    `define K28_5_10bits 10'b11_0000_0101 // Para cuando se envie una /COMMA/
    `define K28_6_10bits 10'b11_0000_1001
    `define K28_7_10bits 10'b11_0000_0111
    `define K23_7_10bits 10'b00_0101_0111 // Para cuando se envie /R/
    `define K27_7_10bits 10'b00_1001_0111 // Para cuando se envie /S/
    `define K29_7_10bits 10'b01_0001_0111 // Para cuando se envie /T/
    `define K30_7_10bits 10'b10_0001_0111 // Para cuando se envie /V/

    // Tabla de los Code Groups Validos segun el estandar
    `define D00_0_8bits 8'h00 //Para D0.0, 00
    `define D01_0_8bits 8'h01 //Para D1.0, 01
    `define D02_0_8bits 8'h02 // Para D2.0 , 02
    `define D05_0_8bits 8'h05 //Para D5.0, 05
    `define D10_0_8bits 8'h0A //Para D10.0, 0A
    `define D21_0_8bits 8'h14 //Para D21.0, 15
    `define D11_1_8bits 8'h2B //Para D11.1, 2B
    `define D20_2_8bits 8'h54 //Para D20.2, 54
    `define D21_4_8bits 8'h95 //Para D21.4, 95
    `define D10_5_8bits 8'hAA //Para D10.5, AA

    `define D05_6_8bits 8'hC5 //Para D05.6, C5
    `define D16_2_8bits 8'h50 //Para D16.2, 50

    // Para rx_code-group<9:0> (en el modulo como code_group_10b_recibido)
    `define D00_0_10bits 10'b10_0111_0100 // Para 00
    `define D01_0_10bits 10'b01_1101_0100 // Para 01
    `define D02_0_10bits 10'b10_1101_0100 // Para 02
    `define D05_0_10bits 10'b10_1001_1011 // Para 05
    `define D10_0_10bits 10'b01_0101_1011 // Para 0A
    `define D21_0_10bits 10'b10_1010_1011 // Para 15
    `define D11_1_10bits 10'b11_0100_1001 // Para 2B
    `define D20_2_10bits 10'b00_1011_0101 // Para 54
    `define D21_4_10bits 10'b10_1010_1101 // Para 95
    `define D10_5_10bits 10'b01_0101_1010 // Para AA

    `define D05_6_10bits 10'b10_1001_0110 // D5.6 rd- = rd+
    `define D16_2_10bits 10'b01_1011_0101 // D16.2 rd- 
    `define D16_2_m_10bits 10'b10_0100_0101 // D16.2 rd+




`endif
