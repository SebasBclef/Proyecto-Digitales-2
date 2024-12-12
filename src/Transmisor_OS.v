//Este codigo corresponde al Transmisor de Ordered Sets (Sets Ordenados)
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ese modulo se usa para detectar el cambio de estado de la variable xmit. Es TRUE si se detecto un cambio en el estado. Es FALSE si no se detecto un cambio en el estado. 
// Parte de 36.2.5.1.4 Functions del estandar.
module XMITCHANGE (
    input clk,                    // Entrada de reloj
    input [2:0] xmit,             // Señal de cambio de estado
    output reg xmit_change_out   // Bandera de si hubo cambio o no
    );  

    reg [2:0] xmit_old;
    always @(posedge clk) 
    xmit_old <= xmit;       // Se guarda el valor de xmit en cada flanco positivo de clk

    always @(*) begin
        if (xmit == xmit_old)            // Se compara el xmit anterior y el actual
            xmit_change_out = `FALSE;    // FALSE; No se detecto un cambio de estado para la variable xmit.
        else xmit_change_out = `TRUE;    // TRUE; Si se detecto un cambio de estado para la variable xmit.
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // El modulo VOID pone en la salida o en la entrada V, dependiendo de TX_EN y TXD segun lo dice la maquina de estados.
 // Parte de 36.2.5.1.4 Functions del estandar.
module VOID (
    input TX_EN,       // Corresponde al Enable
    input [7:0] TXD,   // Señal que corresponde al TXD
    input [8:0] x_in, // Entrada proveniente el GMII
    output reg [8:0] return //Salida que va al otro modulo
    );

    always @(*) begin
        if (!TX_EN  && TXD[7:0] != 8'h0F) return = `OS_V; // Si el enable es 0 y TXD es distinto a (0000 1111)], se devuelve el bloque /V/
        else if (TX_EN) return = `OS_V;                  // Si el Enable es 1, se devuelve el bloque /V/                
        else return = x_in;                              // Sino, se devuelve x.
    end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//El modulo TRANSMIT_OS, define la maquina de estados que corresponde al transmisor de Ordered Sets como tal.
module TRANSMIT_OS (
    //Inputs
    input mr_main_reset,           // Señal de reset principal
    input GTX_CLK,                 // Señal del reloj
    input [7:0] TXD,               // Datos de transmisión
    input TX_EN,                   // Enable para la transmision
    input receiving,               // Indicador de recepción
    input TX_OSET_indicate,        // Indicador del conjunto de órdenes de transmisión
    input tx_even,                 // Señal de paridad para los datos de transmisión
    input [2:0] xmit,              // Estado actual de transmisión

    //outputs
    output reg [6:0] TX_O_SET,      // Conjunto de órdenes de transmisión generado
    output reg transmitting,       // Indicador de transmisión en progreso
    output reg [9:0] PUDR // Grupo de código de transmisión
    );

    // Parametros para la maquina PCS transmit ordered set
    localparam xmit_IDLE = 3'h1; // Si se quiere que el valor de xmit sea IDLE
    localparam xmit_DATA = 3'h2;  // Si se quiere que el valor de xmit sea DATA
    
    // Estados de la maquina de estados codificados
    localparam TX_TEST_XMIT        = 8'b00000001;         
    localparam IDLE                = 8'b00000010;                 
    localparam XMIT_DATA           = 8'b00000100;            
    localparam START_OF_PACKET     = 8'b00001000;      
    localparam TX_PACKET           = 8'b00010000;            
    localparam END_OF_PACKET_NOEXT = 8'b00100000;  
    localparam EPD2_NOEXT          = 8'b01000000;           
    localparam EPD3                = 8'b10000000;  

        //Variables internas para el  TX ordered set
    wire xmit_change_out; //detector de cambio
    wire [8:0] tx_set_void; //registro interno que es lo que se va a retornar
    reg [7:0] estado_actual; // Estados para la maquina
    reg [7:0] estado_siguiente; // Siguiente estado para la maquina de estado

    //Se instancia XMITCHANGE dentro del modulo de la maquina de estados
    XMITCHANGE xmit_C (
        .clk(GTX_CLK), //el clk de XMIT CHANGE, es el reset general de toda el modelo de TRANSMIT
        .xmit(xmit), //transmit a transmit
        .xmit_change_out(xmit_change_out) //indicador para detectar si hay un cambio en el transmit
    );

    //Se instancia VOID dentro del modulo de la maquina de estados
    VOID void (
        .x_in(`OS_D), //Se conecta x al bloque D, como indica el estandar
        .TX_EN(TX_EN), //Enable a Enable
        .TXD(TXD[7:0]), //Se pone TXD como un bus de 8 bits
        .return(tx_set_void) //Return se conecta al tx_set void
    );

    //Para los Flip Flops
    always @(posedge GTX_CLK) begin //FF cambia en el flanco positivo
        if (!mr_main_reset || (xmit_change_out && TX_OSET_indicate && !tx_even)) begin //Si el valor del reset es 0, O si el detector de cambio, el detector de paridad y el trransmit indicate son 1
                                                                                        // se ejecuta el bloque interior
            estado_actual <= TX_TEST_XMIT; //El estado actual se pone al estado TX_TEST_XMIT
            transmitting = `FALSE; //Se pone la señal de transmision como falsa.
        end else
            estado_actual <= estado_siguiente; //Si no se cumple la condicional, el estado actual queda como el estado siguiente
    end
 // Maquina de Estados segun el ASM
    always @(*) begin
        //Para garantizar el comportamiento delFF
        estado_siguiente = estado_actual;
        case(estado_actual)

            TX_TEST_XMIT: begin //Si el estado actual es TEXT_XMIT
                transmitting = `FALSE; //La condicion de transmitting es 0
                if (xmit == xmit_IDLE || (xmit == xmit_DATA && TX_EN)) //Si el xmit del modulo xmit change es igual al valor de xmit_IDLE, O, ese mismo xmit es el valor de xmit_DATA y el Enable es 1
                                                                    //Se pone el estado siguiente como el IDLE
                    estado_siguiente = IDLE;
                if (xmit == xmit_DATA && !TX_EN) //Para otro caso, si xmit es xmit_DATA Y el enable es 0, cae de una vez al estado XMIT_DATA
                    estado_siguiente = XMIT_DATA;
            end

            IDLE: begin // Cuando se cae al estado IDLE:
                TX_O_SET = `OS_I; // TX_O_SET de una vez envia el codigo OS_I, que corresponde al bloque /I/
                if (xmit == xmit_DATA && TX_OSET_indicate && !TX_EN) //Por otro lado, si xmit esta en xmit data y el enable es 0 junto a TX_OSET_indicate es 0, se cae al estado XMIT Data 
                    estado_siguiente = XMIT_DATA;
            end

            XMIT_DATA: begin // Cuando se cae al estado de Transmit_Data
                TX_O_SET = `OS_I; // De una vez, se pone TX_O_SET se pone a enviar el codigo OS_I, lo que corresponde al bloque /I/

                if (!TX_EN && TX_OSET_indicate) //Si el Enable es 0 y TX_OSET_indicate es 1, se queda en este estado
                    estado_siguiente = XMIT_DATA;
                if (TX_EN && TX_OSET_indicate) //Si el Enable es 1 y TX_OSET_indicate es 1, se pasa al estado START_OF _PACKET
                    estado_siguiente = START_OF_PACKET;
            end


            START_OF_PACKET: begin // Cuando se cae al estado de START_OF_PACKET
                transmitting = `TRUE; //Se pone la señal de transmisión como 1
                TX_O_SET = `OS_S; //TX_O_SET se pone a enviar el codigo OS_S, que corresponde al bloque /S/
                if (TX_OSET_indicate) estado_siguiente = TX_PACKET; // condicion de salto al estado TX_PACKET
            end

            TX_PACKET: begin //Cuando se cae al estado de TX_PACKET
                if (TX_EN) begin //Si el enable es 1
                    TX_O_SET = tx_set_void; // Y se pone TX_O_SET conectado a la funcion VOID(/D/)   
                end
                if (!TX_EN) estado_siguiente = END_OF_PACKET_NOEXT; //Cuando el enable se pone en 0, se salta al estado END_OF_PACKET_NOEXT
            end

            END_OF_PACKET_NOEXT: begin //Si se cae al estado END_OF_PACKET_NOEXT
                TX_O_SET = `OS_T; //TX_O_SET se pone en el codigo OS_T, para enviar el bloque /T/
                if (!tx_even) transmitting = `FALSE; // Si tx_even es 0, se pone la transmision como 0
                if (TX_OSET_indicate) estado_siguiente = EPD2_NOEXT; // Si TX_OSET_indicate, se brinca al estado epd2_noext
            end

            // Bloque de EPD2_NOEXT
            EPD2_NOEXT: begin
                transmitting = `FALSE; //Se pone la transmision como 0
                TX_O_SET = `OS_R; //Se toma el valor del bloque /R/, que corresponde al codigo OS_R
                if (!tx_even && TX_OSET_indicate) begin //Si se cumple la condicion, el programa cae al estado XMIT_DATA
                    estado_siguiente = XMIT_DATA;
                end else
                    estado_siguiente = EPD3; //Se brinca al siguiente estado si no se cumple la condicion
            end
            // Bloque de EPD3
            EPD3: begin
                TX_O_SET = `OS_R; // Toma el valor de /R/
                if (TX_OSET_indicate)
                    estado_siguiente = XMIT_DATA;
            end
            // Para un default:
            default:
                estado_siguiente = TX_TEST_XMIT; // condicion de excepcion, salto al estado inicial
        endcase
    end
endmodule