`timescale 1ns / 1ps

module pwm_generator_tb();

  // 1. Test sinyallerimizi tanımlıyoruz (Dışarıdan vereceğimiz uyarıcılar)
  logic clk;
  logic reset_n;
  logic [15:0] duty_cycle;
  logic pwm_out;

  // 2. Senin yazdığın asıl donanımı (UUT - Unit Under Test) test masasına koyuyoruz
  pwm_generator #(
                  .CLK_FREQ(50000000), // 50 MHz
                  .PWM_FREQ(20000),    // 20 kHz
                  .BIT_WIDTH(16)
                ) uut (
                  .clk(clk),
                  .reset_n(reset_n),
                  .duty_cycle(duty_cycle),
                  .pwm_out(pwm_out)
                );

  // 3. Zynq'in kalbini atıyoruz: 50 MHz saat sinyali (Periyot = 20ns, yani her 10ns'de bir yön değiştirir)
  always #10 clk = ~clk;

  // 4. Test Senaryosu (Zaman çizelgesi)
  initial
  begin
    // Sisteme ilk elektriği ver
    clk = 0;
    reset_n = 0;
    duty_cycle = 0;

    // 100 nanosaniye bekle ve reset'i kaldır (Sistemi uyandır)
    #100;
    reset_n = 1;

    // SENARYO 1: Kumandadan %25 Gaz Verdik (65535 * 0.25 = ~16384)
    duty_cycle = 16384;
    #100000; // 100 mikrosaniye (2 tam PWM döngüsü) boyunca sistemi izle

    // SENARYO 2: Kumandadan %75 Gaz Verdik (65535 * 0.75 = ~49151)
    duty_cycle = 49151;
    #100000; // 100 mikrosaniye daha izle

    // Testi durdur
    $stop;
  end

endmodule
