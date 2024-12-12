// Inclusiones de módulos.
// Este codigo corresponde al modulo PCS`
`include "TRANSMIT.v"
`include "Receptor.v"
`include "sincronizador.v"

module PCS (
    // Transmisor
    input [7:0] TXD,               // Datos de transmisión
    input TX_EN,                   // Habilitación de transmisión
    input TX_ER,                   // Error de transmisión
    input GTX_CLK,                 // Clock de transmisión
    output [9:0] PUDR,    // Grupo de código transmitido

    // Receptor
    input [9:0] PUDI,     // Grupo de código recibido
    output [7:0] RXD,              // Datos recibidos
    output RX_DV,                  // Datos válidos recibidos
    output RX_CLK,                 // Clock de recepción

    // GMII
    input mr_main_reset,           // Señal de reinicio principal
    input mr_loopback,             // Modo de bucle en el receptor
    input signal_detect,           // Detección de señal
    input [2:0] xmit               // Modo de transmisión
);

    // PCS
    wire receiving;                 // Indicador de recepción en progreso
    wire [9:0] SUDI;                // Grupo de código SUDI
    wire rx_even;                   // Indicador de paridad en recepción
    wire code_sync_status;          // Estado de sincronización del código
    wire transmitting;              // Indicador de transmisión en progreso

    // Instancia del módulo TRANSMIT para el transmisor
    TRANSMIT Transmisor (
        .mr_main_reset(mr_main_reset),
        .GTX_CLK(GTX_CLK),
        .TXD(TXD),
        .TX_EN(TX_EN),
        .receiving(receiving),
        .xmit(xmit),
        .PUDR(PUDR),
        .transmitting(transmitting)
    );

    // Instancia del módulo RECEIVE para el receptor
    RECEIVE Receptor (
        .mr_main_reset(mr_main_reset),
        .clk(GTX_CLK),
        .SUDI(SUDI),
        .rx_even(rx_even),
        .xmit(xmit),
        .RXD(RXD),
        .RX_DV(RX_DV),
        .RX_ER(RX_ER),
        .RX_CLK(RX_CLK),
        .receiving(receiving)
    );

    // Instancia del módulo SYNCHRONIZATION para la sincronización
    sincronizador sincronizador (
        .mr_main_reset(mr_main_reset),
        .clk(GTX_CLK),
        .mr_loopback(mr_loopback),
        .signal_detect(signal_detect),
        .PUDI(PUDI),
        .SUDI(SUDI),
        .rx_even(rx_even),
        .code_sync_status(code_sync_status)
    );
    
endmodule