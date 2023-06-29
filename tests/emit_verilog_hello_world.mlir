// Test emit-verilog supporting the minimal number of operations required to
// emit hello_world.tflite after it's lowered to arith via our other passes.

// RUN: heir-translate %s --emit-verilog > %t
// RUN: FileCheck %s < %t

module {
  func.func @main(%arg0: ui8) -> (i8) {
    %c0 = arith.constant 0 : i32
    %c1 = arith.constant 1 : i32
    %c2 = arith.constant 2 : i32
    %c3 = arith.constant 3 : i32
    %0 =  builtin.unrealized_conversion_cast %arg0 : ui8 to i8
    %1 = arith.extsi %0 : i8 to i32
    %2 = arith.subi %1, %c1 : i32
    %3 = arith.muli %2, %c2 : i32
    %4 = arith.addi %3, %c3 : i32
    %5 = arith.cmpi sge, %3, %c0 : i32
    %6 = arith.select %5, %c1, %c2 : i32
    %7 = arith.shrsi %4, %c1 : i32
    %8 = arith.shrui %4, %c1 : i32
    %9 = arith.extui %0 : i8 to i32
    %10 = arith.andi %8, %c1 : i32
    %out = arith.trunci %7 : i32 to i8
    return %out : i8
  }
}

// CHECK:      module main(
// CHECK-NEXT:   input wire [7:0] [[ARG:.*]],
// CHECK-NEXT:   output wire signed [7:0] [[OUT:.*]]
// CHECK-NEXT: );
// CHECK-NEXT:   wire signed [31:0] [[V2:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V3:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V4:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V5:.*]];
// CHECK-NEXT:   wire signed [7:0] [[V6:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V7:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V8:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V9:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V10:.*]];
// CHECK-NEXT:   wire [[V11:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V12:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V13:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V14:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V15:.*]];
// CHECK-NEXT:   wire signed [31:0] [[V16:.*]];
// CHECK-NEXT:   wire signed [7:0] [[V17:.*]];
// CHECK-EMPTY:
// CHECK-NEXT:   assign [[V2]] = 0;
// CHECK-NEXT:   assign [[V3]] = 1;
// CHECK-NEXT:   assign [[V4]] = 2;
// CHECK-NEXT:   assign [[V5]] = 3;

// Double-braces means "regular expression" in FileCheck, so to match the
// leading double braces required for the sign extension syntax in verilog, we
// need this disgusting regular expression that matches two character classes
// [{] each consisting of a single opening brace: {{[{][{]}}
//
// CHECK-NEXT:   assign [[V6]] = $signed([[ARG]]);
// CHECK-NEXT:   assign [[V7]] = {{[{][{]}}24{[[V6]][7]}}, [[V6]]};

// CHECK-NEXT:   assign [[V8]] = [[V7]] - [[V3]];
// CHECK-NEXT:   assign [[V9]] = [[V8]] * [[V4]];
// CHECK-NEXT:   assign [[V10]] = [[V9]] + [[V5]];
// CHECK-NEXT:   assign [[V11]] = [[V9]] >= [[V2]];
// CHECK-NEXT:   assign [[V12]] = [[V11]] ? [[V3]] : [[V4]];
// CHECK-NEXT:   assign [[V13]] = [[V10]] >>> [[V3]];
// CHECK-NEXT:   assign [[V14]] = [[V10]] >> [[V3]];
// CHECK-NEXT:   assign [[V15]] = {{[{][{]}}24{1'b0}}, [[V6]]};
// CHECK-NEXT:   assign [[V16]] = [[V14]] & [[V3]];
// CHECK-NEXT:   assign [[V17]] = [[V13]][7:0];
// CHECK-NEXT:   assign [[OUT]] = [[V17]];
// CHECK-NEXT: endmodule
