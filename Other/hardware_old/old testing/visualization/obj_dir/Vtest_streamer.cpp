// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtest_streamer.h"
#include "Vtest_streamer__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vtest_streamer::Vtest_streamer(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtest_streamer__Syms(contextp(), _vcname__, this)}
    , aclk{vlSymsp->TOP.aclk}
    , aresetn{vlSymsp->TOP.aresetn}
    , out_stream_tkeep{vlSymsp->TOP.out_stream_tkeep}
    , out_stream_tlast{vlSymsp->TOP.out_stream_tlast}
    , out_stream_tready{vlSymsp->TOP.out_stream_tready}
    , out_stream_tvalid{vlSymsp->TOP.out_stream_tvalid}
    , out_stream_tuser{vlSymsp->TOP.out_stream_tuser}
    , out_stream_tdata{vlSymsp->TOP.out_stream_tdata}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtest_streamer::Vtest_streamer(const char* _vcname__)
    : Vtest_streamer(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtest_streamer::~Vtest_streamer() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vtest_streamer___024root___eval_initial(Vtest_streamer___024root* vlSelf);
void Vtest_streamer___024root___eval_settle(Vtest_streamer___024root* vlSelf);
void Vtest_streamer___024root___eval(Vtest_streamer___024root* vlSelf);
#ifdef VL_DEBUG
void Vtest_streamer___024root___eval_debug_assertions(Vtest_streamer___024root* vlSelf);
#endif  // VL_DEBUG
void Vtest_streamer___024root___final(Vtest_streamer___024root* vlSelf);

static void _eval_initial_loop(Vtest_streamer__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vtest_streamer___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vtest_streamer___024root___eval_settle(&(vlSymsp->TOP));
        Vtest_streamer___024root___eval(&(vlSymsp->TOP));
    } while (0);
}

void Vtest_streamer::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtest_streamer::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vtest_streamer___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vtest_streamer___024root___eval(&(vlSymsp->TOP));
    } while (0);
    // Evaluate cleanup
}

//============================================================
// Utilities

const char* Vtest_streamer::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtest_streamer::final() {
    Vtest_streamer___024root___final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtest_streamer::hierName() const { return vlSymsp->name(); }
const char* Vtest_streamer::modelName() const { return "Vtest_streamer"; }
unsigned Vtest_streamer::threads() const { return 1; }
std::unique_ptr<VerilatedTraceConfig> Vtest_streamer::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vtest_streamer___024root__trace_init_top(Vtest_streamer___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vtest_streamer___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtest_streamer___024root*>(voidSelf);
    Vtest_streamer__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    Vtest_streamer___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void Vtest_streamer___024root__trace_register(Vtest_streamer___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vtest_streamer::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vtest_streamer___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
