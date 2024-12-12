`include "CodeGroups.v"
`define TRUE  1'b1
`define FALSE 1'b0

///////////////// Funciones para decodificar según el estándar 36.2.5.1.4  /////////////////
    // Módulo que decodifica los códigos que van en grupos
    module DECODE (
        input [9:0] code_group_10b_recibido,
        output reg [7:0] CodeGroup8bits
    );

    always @(code_group_10b_recibido) begin
        //Grupos de códigos válidos
        if (code_group_10b_recibido == `D00_0_10bits)
            CodeGroup8bits = `D00_0_10bits; // D0.0
        else if (code_group_10b_recibido == `D01_0_10bits)
            CodeGroup8bits = `D01_0_10bits; // D1.0
        else if (code_group_10b_recibido == `D02_0_10bits)
            CodeGroup8bits = `D02_0_10bits; // D2.0
        else if (code_group_10b_recibido == `D05_0_10bits)
            CodeGroup8bits = `D05_0_10bits; // D5.0
        else if (code_group_10b_recibido == `D10_0_10bits)
            CodeGroup8bits = `D10_0_10bits; // D10.0
        else if (code_group_10b_recibido == `D21_0_10bits)
            CodeGroup8bits = `D21_0_10bits; // D21.0
        else if (code_group_10b_recibido == `D11_1_10bits)
            CodeGroup8bits = `D11_1_10bits; // D11.1
        else if (code_group_10b_recibido == `D20_2_10bits)
            CodeGroup8bits = `D20_2_10bits; // D20.2
        else if (code_group_10b_recibido == `D21_4_10bits)
            CodeGroup8bits = `D21_4_10bits; // D21.4
        else if (code_group_10b_recibido == `D10_5_10bits)
            CodeGroup8bits = `D10_5_10bits; // D010.5

        //Grupos de códigos especiales 
        else if (code_group_10b_recibido == `K28_0_10bits)
            CodeGroup8bits = `K28_0_8bits; // K28.0
        else if (code_group_10b_recibido == `K28_1_10bits)
            CodeGroup8bits = `K28_1_8bits; // K28.1
        else if (code_group_10b_recibido == `K28_2_10bits)
            CodeGroup8bits = `K28_2_8bits; // K28.2
        else if (code_group_10b_recibido == `K28_3_10bits)
            CodeGroup8bits = `K28_3_8bits; // K28.3
        else if (code_group_10b_recibido == `K28_4_10bits)
            CodeGroup8bits = `K28_4_8bits; // K28.4
        else if (code_group_10b_recibido == `K28_5_10bits)
            CodeGroup8bits = `K28_5_8bits; // K28.5
        else if (code_group_10b_recibido == `K28_6_10bits)
            CodeGroup8bits = `K28_6_8bits; // K28.6
        else if (code_group_10b_recibido == `K28_7_10bits)
            CodeGroup8bits = `K28_7_8bits; // K28.7
        else if (code_group_10b_recibido == `K23_7_10bits)
            CodeGroup8bits = `K23_7_8bits; // K23.7 /R/
        else if (code_group_10b_recibido == `K27_7_10bits)
            CodeGroup8bits = `K27_7_8bits; // K27.7 /S/
        else if (code_group_10b_recibido == `K29_7_10bits)
            CodeGroup8bits = `K29_7_8bits; // K29.7 /T/
        else if (code_group_10b_recibido == `K30_7_10bits)
            CodeGroup8bits = `K30_7_8bits; // K30.7 /V/
	end
	endmodule

///////////////// Modulo del receptor /////////////////
	module RECEIVE (
		input mr_main_reset, clk, rx_even,
		input [9:0] SUDI,
		input [2:0] xmit,
		output reg RX_DV, RX_ER, receiving, RX_CLK,
        output reg [7:0] RXD );

    //Estados para el receptor. Nombrados igual que el estándar
	localparam WAIT_FOR_K          = 0;
	localparam RX_K                = 1;
	localparam IDLE_D              = 2;
    localparam xmit_DATA           = 3'b010;
    localparam START_OF_PACKET     = 3;
    localparam RECEIVE             = 4; 
	
    //variables internas
		reg [6:0] estado;
		reg [6:0] proximo_estado;
		reg [9:0] SUDIxorCOMMA;
        reg [3:0] i;
        reg [3:0] contador = 0;
        reg [3:0] detector_acarreo;
        reg SUDI_D;
		wire [7:0] CodeGroup8bits;

        // Variables internas que se usan en la parte B del receptor
        reg [2:0] OctetoPreambulo;
        reg [19:0] VerificarFinal;
        reg [2:0] OctetoPreambulo_Nuevo; 

		// Instanciación del módulo DECODE, definido anteriormente
		DECODE decoding (
			.code_group_10b_recibido(SUDI), 
			.CodeGroup8bits(CodeGroup8bits)
		);

        // Después de instaciar el módulo DECODE, se puede continuar con lo que se hace en el "main reset"
		always @(posedge clk) begin
			if (!mr_main_reset) begin
				estado = WAIT_FOR_K;
				RX_CLK = 0;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				RXD = 8'h00;
                OctetoPreambulo = 3'h0;
                VerificarFinal = 20'h0; 
			end
			else begin
				estado <= proximo_estado;
				RX_CLK <= !RX_CLK;
                VerificarFinal <= {VerificarFinal[9:0], SUDI}; // Verificación del estado para terminal /T/R/K28.5/
                OctetoPreambulo_Nuevo <= OctetoPreambulo + 3'h1; 
			end
		end

		always @(*) begin
        // Se establece lo que se hace con la señal "SUDI"
        case (SUDI)
            `D00_0_10bits: SUDI_D = `TRUE;
            `D01_0_10bits: SUDI_D = `TRUE;
            `D02_0_10bits: SUDI_D = `TRUE;
            `D05_0_10bits: SUDI_D = `TRUE;
            `D10_0_10bits: SUDI_D = `TRUE;
            `D21_0_10bits: SUDI_D = `TRUE;
            `D11_1_10bits: SUDI_D = `TRUE;
            `D20_2_10bits: SUDI_D = `TRUE;
            `D21_4_10bits: SUDI_D = `TRUE;
            `D10_5_10bits: SUDI_D = `TRUE;
            default: SUDI_D = `FALSE;
        endcase		

		//Actualización de los estados del PCS
        proximo_estado = estado;
		case(estado)
			// Estado "WAIT_FOR_K"
			WAIT_FOR_K: begin
				receiving = `FALSE;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				if  (SUDI == `K28_5_10bits && rx_even) begin // Condicional "SUDI([/K28.5/] * EVEN)", proporcionada por el estándar
                    proximo_estado = RX_K; 
                end
			end
			
			// RX_K
			RX_K: begin
				receiving = `FALSE;
				RX_DV = `FALSE;
				RX_ER = `FALSE;
				RXD = 0;
				if ((xmit != xmit_DATA && SUDI_D && (SUDI != `D21_4_10bits && SUDI != `D10_0_10bits)) ||
					(xmit == xmit_DATA && (SUDI != `D21_4_10bits && SUDI != `D10_0_10bits))) begin 
					proximo_estado = IDLE_D;
                end
			end

			// IDLE_D
			IDLE_D: begin
				SUDIxorCOMMA = SUDI ^ `K28_5_10bits;

                // detector_acarreo
                /* 
                La función detector_acarreo detecta el operador cuando:
                    a) Existe una diferencia de dos o más bits entre [/x/] y ambas codificaciones /K28.5/
                    b) Existe una diferencia de dos a nueve bits entre [/x/] y el /K28.5/ esperado.
                    Valores: VERDADERO; Se detecta portador.
                    FALSO; No se detecta el portador. 
                */
                // Cálculo de la suma de bits
                for (i = 0; i < 9; i = i + 1) begin
                    contador = contador + SUDIxorCOMMA[i];
                end
                detector_acarreo = contador;

				if ((xmit == xmit_DATA && detector_acarreo < 2) || SUDI == `K28_5_10bits) begin
					proximo_estado = RX_K;
                end

				else if (xmit == xmit_DATA && detector_acarreo >= 2) begin
					receiving = `TRUE;

					if (SUDI == `K27_7_10bits) begin 
						proximo_estado = START_OF_PACKET;
                    end
				end

				// FALSE_CARRIER
				else begin
					RX_ER = `TRUE;
					RXD = 8'b00001110;
						
					if (SUDI == `K28_5_10bits && rx_even) begin
						proximo_estado = RX_K;
                    end
				end
			end

			// Estados de START_OF_PACKET
			START_OF_PACKET: begin
				OctetoPreambulo = OctetoPreambulo_Nuevo;
				RX_DV = `TRUE;
				RXD =  7'h55; // Estipulado por la clausula, 0101 01010

				if (OctetoPreambulo == 3'h7) begin 
					proximo_estado = RECEIVE;
					OctetoPreambulo = 3'h0;
				end
			end

			// Estados de RECEIVE
			RECEIVE: begin
                // Como no hay errores, se siguen mandando datos hasta se que se reciba la secuencia de terminacion que es /T/R/K28.5/
					// RX_DATA
					if (SUDI_D)
						RXD = CodeGroup8bits;

					// TRI + RRI
					if (VerificarFinal == {`K29_7_10bits, `K23_7_10bits} && SUDI == `K28_5_10bits && rx_even)
						proximo_estado = RX_K; // Volver al receptor parte a
			end

			default: proximo_estado = WAIT_FOR_K;
		endcase
		end
    endmodule