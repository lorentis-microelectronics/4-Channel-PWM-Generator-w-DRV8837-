`timescale 1ns / 1ps

module pwm_generator #(
    // Parametreler büyük harf ve boşluksuz
    parameter int CLK_FREQ = 50000000, // Zynq PL katmanı varsayılan saati (50 MHz)
    parameter int PWM_FREQ = 20000,    // İstenen PWM frekansı (20 kHz)
    parameter int BIT_WIDTH = 16       // Duty cycle çözünürlüğü (16-bit)
  )(
    // Input/Output küçük harf
    input  logic clk,
    input  logic reset_n,                         // Active-low reset
    input  logic [BIT_WIDTH-1:0] duty_cycle,      // 0 ile 65535 arası gaz değeri
    output logic pwm_out
  );

  // Maksimum sayma değeri (50.000.000 / 20.000 = 2500)
  localparam int MAX_COUNT = CLK_FREQ / PWM_FREQ;

  // Duty cycle değerini sayaca göre oranlamak için çarpan
  // 65535 (16-bit max) değerini MAX_COUNT değerine ölçekleriz
  logic [31:0] scaled_duty;
  assign scaled_duty = (duty_cycle * MAX_COUNT) / ((1 << BIT_WIDTH) - 1);

  // Sayaç (Counter) sinyali
  logic [31:0] counter;

  always_ff @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
    begin
      counter <= 0;
      pwm_out <= 0;
    end
    else
    begin
      // Sayacı sürekli artır, MAX_COUNT'a ulaşınca sıfırla
      if (counter >= (MAX_COUNT - 1))
      begin
        counter <= 0;
      end
      else
      begin
        counter <= counter + 1;
      end

      // PWM Sinyalini oluştur: Sayaç, hedeflenen duty'den küçükse HIGH, değilse LOW
      if (counter < scaled_duty)
      begin
        pwm_out <= 1'b1;
      end
      else
      begin
        pwm_out <= 1'b0;
      end
    end
  end

endmodule
