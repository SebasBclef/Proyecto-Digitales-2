// Testbench utilizado para verificar el funcionamiento del DUT
// Inclusión de los archivos necesarios
`include "PCS.v"
`include "PCS_tester.v"

// Modulo de banco de pruebas. En este apartado se instancian los modulos del PCS y tester.
// Encargado de conectar los wires correspondientes para lograr un flujo de datos correcto.
module tb_PCS;
    // Definición de las señales de entrada y salida
    wire COL;                      // Indicador de colisión
    wire GTX_CLK;                  // Clock de transmisión
    wire [7:0] RXD;                // Datos recibidos
    wire RX_CLK;                   // Clock de recepción
    wire RX_DV;                    // Datos válidos recibidos
    wire RX_ER;                    // Error de recepción
    wire [7:0] TXD;                // Datos de transmisión
    wire TX_EN;                    // Habilitación de transmisión
    wire TX_ER;                    // Error de transmisión
    wire [9:0] loopback;           // Bucle de retroalimentación
    wire mr_loopback;              // Modo de bucle en el receptor
    wire mr_main_reset;            // Señal de reinicio principal
    wire signal_detect;            // Detección de señal
    wire [2:0] xmit;               // Modo de transmisión

    // Instancia del módulo PCS
    PCS DUT (
        .TXD(TXD),
        .TX_EN(TX_EN),
        .TX_ER(TX_ER),
        .GTX_CLK(GTX_CLK),
        .PUDR(loopback),
        .RXD(RXD),
        .RX_DV(RX_DV),
        .RX_CLK(RX_CLK),
        .PUDI(loopback),
        .xmit(xmit),
        .mr_main_reset(mr_main_reset),
        .mr_loopback(mr_loopback),
        .signal_detect(signal_detect)
    );

    // Instancia del módulo tester 
    tester probador (
        .TXD(TXD),
        .TX_EN(TX_EN),
        .TX_ER(TX_ER),
        .GTX_CLK(GTX_CLK),
        .xmit(xmit),
        .mr_main_reset(mr_main_reset),
        .mr_loopback(mr_loopback),
        .signal_detect(signal_detect)
    );

    initial begin
        $dumpfile("tb_PCS.vcd");
        $dumpvars;
    end
endmodule