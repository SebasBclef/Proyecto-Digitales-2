//Este codigo corresponde al Transmisor de Code Blocks (Bloques de Codigo)
`include "CodeGroups.v" //archivo con las tablas de los code-gruops
    `define TRUE  1'b1 // Va a ser util definir el true y false de una vez
    `define FALSE 1'b0 // Va a ser util definir el true y false de una vez
    
// Se desplaza el valor de 1 para hacer una codificacion one hot para los estados
    `define OS_T             9'd1
    `define OS_R             9'd2
    `define OS_I             9'd3
    `define OS_D             9'd4
    `define OS_S             9'd5
    `define OS_V             9'd6
    `define OS_LI            9'd7
//Este módulo codifica un código de grupo de 8 bits en un código de grupo de 10 bits. Recibe un argumento (x), donde (x) es un octeto, y, de acuerdo a su disparidad, se devuelve
//El code group de 10 bits. Parte de 36.2.5.1.4 Functions del estandar.
module ENCODE (
    input [7:0] code_group_8b_recibido,
    output reg [9:0] code_group_10b
);
    always @(code_group_8b_recibido) begin
        //Grupo de Codigos Validos
        if (code_group_8b_recibido == `D00_0_8bits)
            code_group_10b = `D00_0_10bits; // D0.0
        else if (code_group_8b_recibido == `D01_0_8bits)
            code_group_10b = `D01_0_10bits; // D1.0
        else if (code_group_8b_recibido == `D02_0_8bits)
            code_group_10b = `D02_0_10bits; // D2.0
        else if (code_group_8b_recibido == `D05_0_8bits)
            code_group_10b = `D05_0_10bits; // D5.0
        else if (code_group_8b_recibido == `D10_0_8bits)
            code_group_10b = `D10_0_10bits; // D10.0
        else if (code_group_8b_recibido == `D21_0_8bits)
            code_group_10b = `D21_0_10bits; // D21.0
        else if (code_group_8b_recibido == `D11_1_8bits)
            code_group_10b = `D11_1_10bits; // D11.1
        else if (code_group_8b_recibido == `D20_2_8bits)
            code_group_10b = `D20_2_10bits; // D20.2
        else if (code_group_8b_recibido == `D21_4_8bits)
            code_group_10b = `D21_4_10bits; // D21.4
        else if (code_group_8b_recibido == `D10_5_8bits)
            code_group_10b = `D10_5_10bits; // D10.5
        //Code Groups Especiales
        else if (code_group_8b_recibido == `K28_0_8bits)
            code_group_10b = `K28_0_10bits; // K28.0
        else if (code_group_8b_recibido == `K28_1_8bits)
            code_group_10b = `K28_1_10bits; // K28.1
        else if (code_group_8b_recibido == `K28_2_8bits)
            code_group_10b = `K28_2_10bits; // K28.2
        else if (code_group_8b_recibido == `K28_3_8bits)
            code_group_10b = `K28_3_10bits; // K28.3
        else if (code_group_8b_recibido == `K28_4_8bits)
            code_group_10b = `K28_4_10bits; // K28.4
        else if (code_group_8b_recibido == `K28_5_8bits)
            code_group_10b = `K28_5_10bits; // K28.5
        else if (code_group_8b_recibido == `K28_6_8bits)
            code_group_10b = `K28_6_10bits; // K28.6
        else if (code_group_8b_recibido == `K28_7_8bits)
            code_group_10b = `K28_7_10bits; // K28.7
        else if (code_group_8b_recibido == `K23_7_8bits)
            code_group_10b = `K23_7_10bits; // K23.7 /R/
        else if (code_group_8b_recibido == `K27_7_8bits)
            code_group_10b = `K27_7_10bits; // K27.7 /S/
        else if (code_group_8b_recibido == `K29_7_8bits)
            code_group_10b = `K29_7_10bits; // K29.7 /T/
        else if (code_group_8b_recibido == `K30_7_8bits)
            code_group_10b = `K30_7_10bits; // K30.7 /V/
	end
endmodule
//Maquina de estados para el transmisor
module TRANSMIT_CG (
    input mr_main_reset,           // Señal de reinicio principal
    input GTX_CLK,                 // Reloj de transmisión
    input [6:0] TX_O_SET,           // Conjunto de salida de transmisión
    input [7:0] TXD,               // Datos de transmisión
    output reg tx_even,            // Bit de paridad de transmisión
    output reg TX_OSET_indicate,   // Indicador de conjunto de salida de transmisión
    output reg [9:0] PUDR // Código de grupo de transmisión
    );
    // Variables internas para el transmit de los code groups
        wire [9:0] TXD_encoded;   // Datos de transmisión codificados
        reg [1:0] state;          // Estado actual de la máquina de estados
        reg [1:0] nxt_state;      // Próximo estado de la máquina de estados

        localparam GENERATE_CODE_GROUPS = 3'b001;
        localparam IDLE_I2B = 3'b010;
        localparam DATA_G0 = 3'b100;

        // función ENCODE(X)
        ENCODE encoding (
            .code_group_8b_recibido(TXD),
            .code_group_10b(TXD_encoded)
        );
        //Para los flip flops
        always @(posedge GTX_CLK) begin
            if (!mr_main_reset) begin
                state <= GENERATE_CODE_GROUPS;
                TX_OSET_indicate <= `FALSE;
            end
            else
                state <= nxt_state;
        end
        always @(*) begin
            nxt_state = state; //Para los flops
            TX_OSET_indicate = `FALSE; //Se inica TX_OSET_indicate como 0
            case(state)
                // GENERATE_CODE_GROUPS
                GENERATE_CODE_GROUPS: begin
                    if (TX_O_SET == `OS_I) begin //Si el TX_O_SET es OS_I
                        tx_even = `TRUE; //even se pone como true
                        PUDR = `K28_5_10bits; // /K28.5/
                        nxt_state = IDLE_I2B; //se cae al siguiente estado
                    end
                    else 
                    begin //Si TX_O_SET tiene algun otro valor, se ajusta el valor para que refleje el bloque
                        TX_OSET_indicate = `TRUE;
                        tx_even = !tx_even;
                        if (TX_O_SET == `OS_R)
                            PUDR = `K23_7_10bits; // /R/
                        if (TX_O_SET == `OS_S)
                            PUDR = `K27_7_10bits; // /S/
                        if (TX_O_SET == `OS_T)
                            PUDR = `K29_7_10bits; // /T/
                        if (TX_O_SET == `OS_V)
                            PUDR = `K30_7_10bits; // /V/
                        if (TX_O_SET == `OS_D)
                            PUDR = TXD_encoded; 
                    end
                end
                // Si se cae a este estado:
                IDLE_I2B: begin
                    tx_even = `FALSE; //tx_even se pone como 0
                    TX_OSET_indicate = `TRUE; //indicate se pone como 1
                    PUDR = `D16_2_10bits; // /D16.2/
                    nxt_state = GENERATE_CODE_GROUPS; //Se vuelve al estado
                end
                default : nxt_state = GENERATE_CODE_GROUPS;
            endcase
        end
endmodule