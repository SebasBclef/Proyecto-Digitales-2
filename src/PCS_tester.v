`include "CodeGroups.v"
module tester_TX (mr_main_reset, GTX_CLK, TXD, TX_EN, TX_ER, xmit);
    output reg mr_main_reset;     // Señal de reset principal
    output reg GTX_CLK;           // Señal de reloj para transmisión
    output reg [7:0] TXD;         // Datos a transmitir
    output reg TX_EN;             // Señal de habilitación de transmisión
    output reg TX_ER;             // Señal de error de transmisión
    output reg [2:0] xmit;         // Selección de modo de transmisión


    always begin
        GTX_CLK = 1'b0;           // Inicializa el reloj en 0
        #1;
        GTX_CLK = 1'b1;           // Cambia el reloj a 1
        #1;
    end

    initial begin
        // Se inicializan las variables provenientes del GMII
        TXD = 8'h00;               // Inicializa los datos a transmitir en 0
        TX_EN = 1'b0;              // Desactiva la transmisión
        TX_ER = 1'b0;              // Desactiva la señal de error
        xmit = 3'b001;             // Establece el modo de transmisión en 001 (Idle)

        // Se hace reset
        mr_main_reset = 1'b0;      // Desactiva el reset
        #2;
        mr_main_reset = 1'b1;      // Activa el reset

        #10;
        xmit = 3'b010;             // Cambia el modo de transmisión a 010 (Data)
        #10;
        TX_EN = 1'b1;              // Activa la transmisión
        #5;
        // Data a transmitir
        TXD = 8'h01;               // Envia el byte 01
        #2;
        TXD = 8'h02;               // Envia el byte 02
        #2;
        TXD = 8'h05;               // Envia el byte 05
        #2;
        TXD = 8'h0A;               // Envia el byte 0A
        #2;
        TXD = 8'h15;               // Envia el byte 15
        #2;
        TXD = 8'h2B;               // Envia el byte 2B
        #2;
        TXD = 8'h54;               // Envia el byte 54
        #2;
        TXD = 8'h95;               // Envia el byte 95
        #2;
        TXD = 8'hAA;               // Envia el byte AA
        #2;
        TXD = 8'h00;               // Envia el byte 00
        #2;
        TX_EN =1'b0;               // Desactiva la transmisión
        #20;
        $finish;                   // Finaliza la simulación
    end
endmodule


module tester_SYNC(clock, mr_main_reset, mr_loopback, signal_detect,rx_code_group);
    output reg clock, mr_main_reset, mr_loopback, signal_detect;
    output reg [9:0] rx_code_group;

    always #1 clock <= ~clock;   // Genera una señal de reloj alternante,p
 
    initial begin
        clock <= 1;               // Inicializa el reloj en 1
        mr_main_reset = 1'b0;     // Desactiva el reset
        #2 mr_main_reset <= 1'b1; // Activa el reset
        signal_detect <= 1'b1;    // Activa la detección de señal
        mr_loopback <= 1;         // Activa el bucle de retroalimentación

        rx_code_group <= 10'b0011111010;   // Envía el código K28.5 (Inicio de paquete)
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b0011111010; // Envía el código K28.5 (Inicio de paquete)
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b0011111010; // Envía el código K28.5 (Inicio de paquete)
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b1111111111; // Envía el código de relleno
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b1111111111; // Envía el código de relleno
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b1111111111; // Envía el código de relleno
        #2 rx_code_group <= 10'b0110110101; // Envía el código D16.2 (Datos)
        #2 rx_code_group <= 10'b1111111111; // Envía el código de relleno
        #50;
        #4 $finish; // Finaliza la simulación
    end
endmodule

module tester (TXD, TX_EN, TX_ER, GTX_CLK, xmit, mr_main_reset,  mr_loopback, signal_detect);
    output [7:0] TXD;                 // Datos a transmitir
    output TX_EN;                     // Señal de habilitación de transmisión
    output TX_ER;                     // Señal de error de transmisión
    output GTX_CLK;                   // Señal de reloj para transmisión
    output [2:0] xmit;                // Selección de modo de transmisión
    output mr_main_reset;             // Señal de reset principal
    output mr_loopback;               // Señal de bucle de retroalimentación
    output signal_detect;              // Señal de detección de señal

    tester_TX probador (
        .GTX_CLK      (GTX_CLK),        // Conexión de la señal de reloj para transmisión
        .mr_main_reset(mr_main_reset),  // Conexión de la señal de reset principal
        .TX_EN        (TX_EN),          // Conexión de la señal de habilitación de transmisión
        .TX_ER        (TX_ER),          // Conexión de la señal de error de transmisión
        .xmit         (xmit[2:0]),      // Conexión de la señal de selección de modo de transmisión
        .TXD          (TXD[7:0])        // Conexión de la señal de datos a transmitir
    );

    tester_SYNC Probador (
        .mr_loopback        (mr_loopback),    // Conexión de la señal de bucle de retroalimentación
        .signal_detect      (signal_detect)   // Conexión de la señal de detección de señal
    );
endmodule