// riscv_sim.v
//
// Testbench for the 6-stage pipelined RISC-V RV32I CPU.
// Loads the hex test program into the instruction memory (U_RISCV.U_IM.memory)
// via $readmemh, runs for 5000 cycles, and prints PC + register file contents.
//
// Reconstructed from the design report (section 4.1.2); the report uses
// Verdi PLI for waveform dumping. Keep the PLI flags when you run VCS.
//
// Usage (VCS):
//   vcs -f ./files.f -timescale=1ns/1ps -full64 +vc +v2k -sverilog -debug_all \
//       -LDFLAGS -Wl,--no-as-needed \
//       -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab \
//          $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a \
//       +notimingchecks +nospecify | tee compile.log
//   ./simv -gui=verdi

`timescale 1ns/1ps

module riscv_sim;

    reg clk;
    reg rst;

    // DUT
    riscv U_RISCV (
        .clk (clk),
        .rst (rst)
    );

    // clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // reset pulse for the first 2 cycles, then run 5000 cycles
    initial begin
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        repeat (5000) @(posedge clk);
        $finish;
    end

    // load test program into instruction memory
    initial begin
        $readmemh("test_program.hex", U_RISCV.U_IM.memory);
    end

    // monitor: print PC on every rising edge
    always @(posedge clk) begin
        if (!rst)
            $display("%0t: PC = %08h", $time, U_RISCV.PC);
    end

    // dump VCD (portable alternative to Verdi; Verdi users can drop this)
    initial begin
        $dumpfile("riscv_sim.vcd");
        $dumpvars(0, riscv_sim);
    end

endmodule
