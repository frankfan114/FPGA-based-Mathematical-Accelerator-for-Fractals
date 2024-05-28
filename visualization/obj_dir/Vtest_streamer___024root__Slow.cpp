// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtest_streamer.h for the primary calling header

#include "verilated.h"

#include "Vtest_streamer__Syms.h"
#include "Vtest_streamer___024root.h"

void Vtest_streamer___024root___ctor_var_reset(Vtest_streamer___024root* vlSelf);

Vtest_streamer___024root::Vtest_streamer___024root(Vtest_streamer__Syms* symsp, const char* name)
    : VerilatedModule{name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vtest_streamer___024root___ctor_var_reset(this);
}

void Vtest_streamer___024root::__Vconfigure(bool first) {
    if (false && first) {}  // Prevent unused
}

Vtest_streamer___024root::~Vtest_streamer___024root() {
}
