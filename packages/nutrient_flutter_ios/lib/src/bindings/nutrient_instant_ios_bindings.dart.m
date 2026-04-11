#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "../../../example/ios/Pods/Instant/Instant.xcframework/ios-arm64_x86_64-simulator/Instant.framework/Headers/Instant.h"
#import "../../../example/ios/Pods/PSPDFKit/PSPDFKit.xcframework/ios-arm64_x86_64-simulator/PSPDFKit.framework/Headers/PSPDFKit.h"
#import "../../../example/ios/Pods/PSPDFKit/PSPDFKitUI.xcframework/ios-arm64_x86_64-simulator/PSPDFKitUI.framework/Headers/PSPDFKitUI.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, BLOCK_SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  return BLOCK_SIG {                                                           \
    void* currentIsolate = ctx->currentIsolate();                              \
    bool mayEnterIsolate =                                                     \
        currentIsolate == NULL &&                                              \
        ctx->getCurrentThreadOwnsIsolate != NULL &&                            \
        ctx->getCurrentThreadOwnsIsolate(targetPort);                          \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                  \
      if (mayEnterIsolate) {                                                   \
        ctx->enterIsolate(targetIsolate);                                      \
      }                                                                        \
      INVOKE_DIRECT;                                                           \
      if (mayEnterIsolate) {                                                   \
        ctx->exitIsolate();                                                    \
      }                                                                        \
    } else {                                                                   \
      void* waiter = ctx->newWaiter();                                         \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
    }                                                                          \
  };


typedef double  (^_ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
double  _NutrientInstantIOSBindings_protocolTrampoline_tfvuzk(id target, void * sel) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct OpaqueCMTimebase *  (^_ProtocolTrampoline_1)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaqueCMTimebase *  _NutrientInstantIOSBindings_protocolTrampoline_1hdtd53(id target, void * sel) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_2)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_3)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef NSItemProviderRepresentationVisibility  (^_ProtocolTrampoline_4)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
NSItemProviderRepresentationVisibility  _NutrientInstantIOSBindings_protocolTrampoline_1ldqghh(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef NSPasteboardReadingOptions  (^_ProtocolTrampoline_5)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
NSPasteboardReadingOptions  _NutrientInstantIOSBindings_protocolTrampoline_1jypdhr(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef NSPasteboardWritingOptions  (^_ProtocolTrampoline_6)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
NSPasteboardWritingOptions  _NutrientInstantIOSBindings_protocolTrampoline_zs9fen(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_7)(void * sel, id * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_361moc(id target, void * sel, id * arg1) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_8)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_1q0i84(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_9)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_10s6poe(id target, void * sel, id arg1, id * arg2) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_10)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_zi5eed(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef unsigned long  (^_ProtocolTrampoline_11)(void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _NutrientInstantIOSBindings_protocolTrampoline_17ap02x(id target, void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_12)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientInstantIOSBindings_protocolTrampoline_10z9f5k(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef PSPDFInstantCacheEntryState  (^_ProtocolTrampoline_13)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFInstantCacheEntryState  _NutrientInstantIOSBindings_protocolTrampoline_kvku1m(id target, void * sel) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef PSPDFInstantDocumentState  (^_ProtocolTrampoline_14)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFInstantDocumentState  _NutrientInstantIOSBindings_protocolTrampoline_ac1yx(id target, void * sel) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_15)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_16)(void * sel, id * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_jp3gca(id target, void * sel, id * arg1) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_17)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_joosg4(id target, void * sel, id arg1, id * arg2) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_18)(void * sel, id * arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_yn963z(id target, void * sel, id * arg1, id * arg2) {
  return ((_ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_19)(void * sel, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_1xgs5se(id target, void * sel, id arg1, PSPDFAnnotationZIndexMove arg2) {
  return ((_ProtocolTrampoline_19)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_20)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_h7kw4q(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4) {
  return ((_ProtocolTrampoline_20)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_21)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientInstantIOSBindings_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_21)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef size_t  (^_ProtocolTrampoline_22)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
size_t  _NutrientInstantIOSBindings_protocolTrampoline_150qdkd(id target, void * sel) {
  return ((_ProtocolTrampoline_22)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long long  (^_ProtocolTrampoline_23)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long long  _NutrientInstantIOSBindings_protocolTrampoline_1hkamru(id target, void * sel) {
  return ((_ProtocolTrampoline_23)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _NutrientInstantIOSBindings_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _NutrientInstantIOSBindings_wrapBlockingBlock_1pl9qdv(
    _BlockingTrampoline block, _BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    objc_retainBlock(block);
    block(nil);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter);
  });
}

typedef void  (^_ListenerTrampoline_1)(int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _NutrientInstantIOSBindings_wrapListenerBlock_d5qk2g(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _NutrientInstantIOSBindings_wrapBlockingBlock_d5qk2g(
    _BlockingTrampoline_1 block, _BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_2)(int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _NutrientInstantIOSBindings_wrapListenerBlock_1dy5sj5(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _NutrientInstantIOSBindings_wrapBlockingBlock_1dy5sj5(
    _BlockingTrampoline_2 block, _BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_3)(uint64_t arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _NutrientInstantIOSBindings_wrapListenerBlock_xr8iv0(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(uint64_t arg0, float arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, uint64_t arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _NutrientInstantIOSBindings_wrapBlockingBlock_xr8iv0(
    _BlockingTrampoline_3 block, _BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(uint64_t arg0, float arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_4)(id arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _NutrientInstantIOSBindings_wrapListenerBlock_142x8lj(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, float arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, id arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _NutrientInstantIOSBindings_wrapBlockingBlock_142x8lj(
    _BlockingTrampoline_4 block, _BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, float arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^_ListenerTrampoline_5)(AUVoiceIOSpeechActivityEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _NutrientInstantIOSBindings_wrapListenerBlock_c466x6(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(AUVoiceIOSpeechActivityEvent arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, AUVoiceIOSpeechActivityEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _NutrientInstantIOSBindings_wrapBlockingBlock_c466x6(
    _BlockingTrampoline_5 block, _BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(AUVoiceIOSpeechActivityEvent arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_6)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _NutrientInstantIOSBindings_wrapListenerBlock_pfv6jd(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _NutrientInstantIOSBindings_wrapBlockingBlock_pfv6jd(
    _BlockingTrampoline_6 block, _BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_7)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _NutrientInstantIOSBindings_wrapListenerBlock_xtuoz7(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _NutrientInstantIOSBindings_wrapBlockingBlock_xtuoz7(
    _BlockingTrampoline_7 block, _BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef void  (^_ListenerTrampoline_8)(AVAudioPlayerNodeCompletionCallbackType arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _NutrientInstantIOSBindings_wrapListenerBlock_go4t5m(_ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(AVAudioPlayerNodeCompletionCallbackType arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, AVAudioPlayerNodeCompletionCallbackType arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _NutrientInstantIOSBindings_wrapBlockingBlock_go4t5m(
    _BlockingTrampoline_8 block, _BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(AVAudioPlayerNodeCompletionCallbackType arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_9)(id arg0, double * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _NutrientInstantIOSBindings_wrapListenerBlock_7at20g(_ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, double * arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, id arg0, double * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _NutrientInstantIOSBindings_wrapBlockingBlock_7at20g(
    _BlockingTrampoline_9 block, _BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, double * arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_10)(id arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _NutrientInstantIOSBindings_wrapListenerBlock_qf8tk6(_ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, double arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, id arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _NutrientInstantIOSBindings_wrapBlockingBlock_qf8tk6(
    _BlockingTrampoline_10 block, _BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, double arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ListenerTrampoline_11)(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _NutrientInstantIOSBindings_wrapListenerBlock_1v0mrw4(_ListenerTrampoline_11 block) NS_RETURNS_RETAINED {
  return ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _NutrientInstantIOSBindings_wrapBlockingBlock_1v0mrw4(
    _BlockingTrampoline_11 block, _BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_12)(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _NutrientInstantIOSBindings_wrapListenerBlock_uefqw7(_ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _NutrientInstantIOSBindings_wrapBlockingBlock_uefqw7(
    _BlockingTrampoline_12 block, _BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^_ListenerTrampoline_13)(AudioUnitRemoteControlEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _NutrientInstantIOSBindings_wrapListenerBlock_1sfe49o(_ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRemoteControlEvent arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, AudioUnitRemoteControlEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _NutrientInstantIOSBindings_wrapBlockingBlock_1sfe49o(
    _BlockingTrampoline_13 block, _BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(AudioUnitRemoteControlEvent arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_14)(AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _NutrientInstantIOSBindings_wrapListenerBlock_1jn8q5n(_ListenerTrampoline_14 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _NutrientInstantIOSBindings_wrapBlockingBlock_1jn8q5n(
    _BlockingTrampoline_14 block, _BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_15)(AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _NutrientInstantIOSBindings_wrapListenerBlock_18q2rn5(_ListenerTrampoline_15 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _NutrientInstantIOSBindings_wrapBlockingBlock_18q2rn5(
    _BlockingTrampoline_15 block, _BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_16)(struct AudioUnitRenderContext * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _NutrientInstantIOSBindings_wrapListenerBlock_1208de5(_ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(struct AudioUnitRenderContext * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, struct AudioUnitRenderContext * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _NutrientInstantIOSBindings_wrapBlockingBlock_1208de5(
    _BlockingTrampoline_16 block, _BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct AudioUnitRenderContext * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_17)(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _NutrientInstantIOSBindings_wrapListenerBlock_115kkcp(_ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, unsigned char arg0, unsigned long long arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _NutrientInstantIOSBindings_wrapBlockingBlock_115kkcp(
    _BlockingTrampoline_17 block, _BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned char arg0, unsigned long long arg1, struct __CFError * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_18)(struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _NutrientInstantIOSBindings_wrapListenerBlock_htoix7(_ListenerTrampoline_18 block) NS_RETURNS_RETAINED {
  return ^void(struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_18)(void * waiter, struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _NutrientInstantIOSBindings_wrapBlockingBlock_htoix7(
    _BlockingTrampoline_18 block, _BlockingTrampoline_18 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ListenerTrampoline_19)(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _NutrientInstantIOSBindings_wrapListenerBlock_du1izn(_ListenerTrampoline_19 block) NS_RETURNS_RETAINED {
  return ^void(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_19)(void * waiter, CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _NutrientInstantIOSBindings_wrapBlockingBlock_du1izn(
    _BlockingTrampoline_19 block, _BlockingTrampoline_19 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(CGDisplayStreamFrameStatus arg0, uint64_t arg1, struct __IOSurface * arg2, struct CGDisplayStreamUpdate * arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_20)(struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _NutrientInstantIOSBindings_wrapListenerBlock_1ctgxtl(_ListenerTrampoline_20 block) NS_RETURNS_RETAINED {
  return ^void(struct CGPathElement * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_20)(void * waiter, struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _NutrientInstantIOSBindings_wrapBlockingBlock_1ctgxtl(
    _BlockingTrampoline_20 block, _BlockingTrampoline_20 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct CGPathElement * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_21)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _NutrientInstantIOSBindings_wrapListenerBlock_r8gdi7(_ListenerTrampoline_21 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_21)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _NutrientInstantIOSBindings_wrapBlockingBlock_r8gdi7(
    _BlockingTrampoline_21 block, _BlockingTrampoline_21 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_22)(struct opaqueCMBufferQueueTriggerToken * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _NutrientInstantIOSBindings_wrapListenerBlock_19rd2sv(_ListenerTrampoline_22 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMBufferQueueTriggerToken * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_22)(void * waiter, struct opaqueCMBufferQueueTriggerToken * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _NutrientInstantIOSBindings_wrapBlockingBlock_19rd2sv(
    _BlockingTrampoline_22 block, _BlockingTrampoline_22 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct opaqueCMBufferQueueTriggerToken * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_23)(int32_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_23 _NutrientInstantIOSBindings_wrapListenerBlock_lof6g0(_ListenerTrampoline_23 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_23)(void * waiter, int32_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_23 _NutrientInstantIOSBindings_wrapBlockingBlock_lof6g0(
    _BlockingTrampoline_23 block, _BlockingTrampoline_23 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int32_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_24)(struct opaqueCMSampleBuffer * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_24 _NutrientInstantIOSBindings_wrapListenerBlock_b3hvj9(_ListenerTrampoline_24 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMSampleBuffer * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_24)(void * waiter, struct opaqueCMSampleBuffer * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_24 _NutrientInstantIOSBindings_wrapBlockingBlock_b3hvj9(
    _BlockingTrampoline_24 block, _BlockingTrampoline_24 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct opaqueCMSampleBuffer * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_25)(struct opaqueCMSampleBuffer * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_25 _NutrientInstantIOSBindings_wrapListenerBlock_3f698x(_ListenerTrampoline_25 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMSampleBuffer * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_25)(void * waiter, struct opaqueCMSampleBuffer * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_25 _NutrientInstantIOSBindings_wrapBlockingBlock_3f698x(
    _BlockingTrampoline_25 block, _BlockingTrampoline_25 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct opaqueCMSampleBuffer * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_26)(CMTime arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_26 _NutrientInstantIOSBindings_wrapListenerBlock_1hznzoi(_ListenerTrampoline_26 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_26)(void * waiter, CMTime arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_26 _NutrientInstantIOSBindings_wrapBlockingBlock_1hznzoi(
    _BlockingTrampoline_26 block, _BlockingTrampoline_26 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(CMTime arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_27)(CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_27 _NutrientInstantIOSBindings_wrapListenerBlock_1gyb8q7(_ListenerTrampoline_27 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4));
  };
}

typedef void  (^_BlockingTrampoline_27)(void * waiter, CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_27 _NutrientInstantIOSBindings_wrapBlockingBlock_1gyb8q7(
    _BlockingTrampoline_27 block, _BlockingTrampoline_27 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4));
  });
}

typedef void  (^_ListenerTrampoline_28)(CMTime arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_28 _NutrientInstantIOSBindings_wrapListenerBlock_fgo1sw(_ListenerTrampoline_28 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_28)(void * waiter, CMTime arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_28 _NutrientInstantIOSBindings_wrapBlockingBlock_fgo1sw(
    _BlockingTrampoline_28 block, _BlockingTrampoline_28 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(CMTime arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_29)(int64_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _NutrientInstantIOSBindings_wrapListenerBlock_mpxix1(_ListenerTrampoline_29 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_29)(void * waiter, int64_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _NutrientInstantIOSBindings_wrapBlockingBlock_mpxix1(
    _BlockingTrampoline_29 block, _BlockingTrampoline_29 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int64_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_30)(struct MIDIEventList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _NutrientInstantIOSBindings_wrapListenerBlock_zl28ap(_ListenerTrampoline_30 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDIEventList * arg0, void * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_30)(void * waiter, struct MIDIEventList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _NutrientInstantIOSBindings_wrapBlockingBlock_zl28ap(
    _BlockingTrampoline_30 block, _BlockingTrampoline_30 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDIEventList * arg0, void * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_31)(struct MIDINotification * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _NutrientInstantIOSBindings_wrapListenerBlock_9vhxqi(_ListenerTrampoline_31 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDINotification * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_31)(void * waiter, struct MIDINotification * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _NutrientInstantIOSBindings_wrapBlockingBlock_9vhxqi(
    _BlockingTrampoline_31 block, _BlockingTrampoline_31 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDINotification * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_32)(struct MIDIPacketList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _NutrientInstantIOSBindings_wrapListenerBlock_1pb1iof(_ListenerTrampoline_32 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDIPacketList * arg0, void * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_32)(void * waiter, struct MIDIPacketList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _NutrientInstantIOSBindings_wrapBlockingBlock_1pb1iof(
    _BlockingTrampoline_32 block, _BlockingTrampoline_32 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDIPacketList * arg0, void * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_33)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _NutrientInstantIOSBindings_wrapListenerBlock_1p9ui4q(_ListenerTrampoline_33 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_33)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _NutrientInstantIOSBindings_wrapBlockingBlock_1p9ui4q(
    _BlockingTrampoline_33 block, _BlockingTrampoline_33 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_34)(id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _NutrientInstantIOSBindings_wrapListenerBlock_1a22wz(_ListenerTrampoline_34 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_34)(void * waiter, id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _NutrientInstantIOSBindings_wrapBlockingBlock_1a22wz(
    _BlockingTrampoline_34 block, _BlockingTrampoline_34 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_35)(id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _NutrientInstantIOSBindings_wrapListenerBlock_t8l8el(_ListenerTrampoline_35 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL * arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_35)(void * waiter, id arg0, BOOL * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _NutrientInstantIOSBindings_wrapBlockingBlock_t8l8el(
    _BlockingTrampoline_35 block, _BlockingTrampoline_35 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL * arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^_ListenerTrampoline_36)(long arg0, struct AUParameterAutomationEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _NutrientInstantIOSBindings_wrapListenerBlock_bqkezo(_ListenerTrampoline_36 block) NS_RETURNS_RETAINED {
  return ^void(long arg0, struct AUParameterAutomationEvent * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_36)(void * waiter, long arg0, struct AUParameterAutomationEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _NutrientInstantIOSBindings_wrapBlockingBlock_bqkezo(
    _BlockingTrampoline_36 block, _BlockingTrampoline_36 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(long arg0, struct AUParameterAutomationEvent * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_37)(long arg0, struct AURecordedParameterEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _NutrientInstantIOSBindings_wrapListenerBlock_6up75b(_ListenerTrampoline_37 block) NS_RETURNS_RETAINED {
  return ^void(long arg0, struct AURecordedParameterEvent * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_37)(void * waiter, long arg0, struct AURecordedParameterEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _NutrientInstantIOSBindings_wrapBlockingBlock_6up75b(
    _BlockingTrampoline_37 block, _BlockingTrampoline_37 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(long arg0, struct AURecordedParameterEvent * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_38)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _NutrientInstantIOSBindings_wrapListenerBlock_1b3bb6a(_ListenerTrampoline_38 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_38)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _NutrientInstantIOSBindings_wrapBlockingBlock_1b3bb6a(
    _BlockingTrampoline_38 block, _BlockingTrampoline_38 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_39)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _NutrientInstantIOSBindings_wrapListenerBlock_lmc3p5(_ListenerTrampoline_39 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_39)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _NutrientInstantIOSBindings_wrapBlockingBlock_lmc3p5(
    _BlockingTrampoline_39 block, _BlockingTrampoline_39 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_40)(id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _NutrientInstantIOSBindings_wrapListenerBlock_6jvo9y(_ListenerTrampoline_40 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_40)(void * waiter, id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _NutrientInstantIOSBindings_wrapBlockingBlock_6jvo9y(
    _BlockingTrampoline_40 block, _BlockingTrampoline_40 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_41)(unsigned long arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _NutrientInstantIOSBindings_wrapListenerBlock_101dho9(_ListenerTrampoline_41 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, double arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_41)(void * waiter, unsigned long arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _NutrientInstantIOSBindings_wrapBlockingBlock_101dho9(
    _BlockingTrampoline_41 block, _BlockingTrampoline_41 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, double arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_42)(unsigned long arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _NutrientInstantIOSBindings_wrapListenerBlock_bfp043(_ListenerTrampoline_42 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_42)(void * waiter, unsigned long arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _NutrientInstantIOSBindings_wrapBlockingBlock_bfp043(
    _BlockingTrampoline_42 block, _BlockingTrampoline_42 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_43)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _NutrientInstantIOSBindings_wrapListenerBlock_o762yo(_ListenerTrampoline_43 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  };
}

typedef void  (^_BlockingTrampoline_43)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _NutrientInstantIOSBindings_wrapBlockingBlock_o762yo(
    _BlockingTrampoline_43 block, _BlockingTrampoline_43 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  });
}

typedef void  (^_ListenerTrampoline_44)(NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _NutrientInstantIOSBindings_wrapListenerBlock_n8yd09(_ListenerTrampoline_44 block) NS_RETURNS_RETAINED {
  return ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_44)(void * waiter, NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _NutrientInstantIOSBindings_wrapBlockingBlock_n8yd09(
    _BlockingTrampoline_44 block, _BlockingTrampoline_44 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_45)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _NutrientInstantIOSBindings_wrapListenerBlock_rnu2c5(_ListenerTrampoline_45 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_45)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _NutrientInstantIOSBindings_wrapBlockingBlock_rnu2c5(
    _BlockingTrampoline_45 block, _BlockingTrampoline_45 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_46)(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _NutrientInstantIOSBindings_wrapListenerBlock_np5chy(_ListenerTrampoline_46 block) NS_RETURNS_RETAINED {
  return ^void(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  };
}

typedef void  (^_BlockingTrampoline_46)(void * waiter, PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _NutrientInstantIOSBindings_wrapBlockingBlock_np5chy(
    _BlockingTrampoline_46 block, _BlockingTrampoline_46 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  });
}

typedef void  (^_ListenerTrampoline_47)(struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _NutrientInstantIOSBindings_wrapListenerBlock_gwxhxt(_ListenerTrampoline_47 block) NS_RETURNS_RETAINED {
  return ^void(struct __SecTrust * arg0, SecTrustResultType arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_47)(void * waiter, struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _NutrientInstantIOSBindings_wrapBlockingBlock_gwxhxt(
    _BlockingTrampoline_47 block, _BlockingTrampoline_47 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct __SecTrust * arg0, SecTrustResultType arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_48)(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _NutrientInstantIOSBindings_wrapListenerBlock_k73ff5(_ListenerTrampoline_48 block) NS_RETURNS_RETAINED {
  return ^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_48)(void * waiter, struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _NutrientInstantIOSBindings_wrapBlockingBlock_k73ff5(
    _BlockingTrampoline_48 block, _BlockingTrampoline_48 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_49)(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _NutrientInstantIOSBindings_wrapListenerBlock_17t6k8t(_ListenerTrampoline_49 block) NS_RETURNS_RETAINED {
  return ^void(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_49)(void * waiter, uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _NutrientInstantIOSBindings_wrapBlockingBlock_17t6k8t(
    _BlockingTrampoline_49 block, _BlockingTrampoline_49 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ListenerTrampoline_50)(BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _NutrientInstantIOSBindings_wrapListenerBlock_1s56lr9(_ListenerTrampoline_50 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_50)(void * waiter, BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _NutrientInstantIOSBindings_wrapBlockingBlock_1s56lr9(
    _BlockingTrampoline_50 block, _BlockingTrampoline_50 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_51)(BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _NutrientInstantIOSBindings_wrapListenerBlock_hk7n97(_ListenerTrampoline_51 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_51)(void * waiter, BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _NutrientInstantIOSBindings_wrapBlockingBlock_hk7n97(
    _BlockingTrampoline_51 block, _BlockingTrampoline_51 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_52)(BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _NutrientInstantIOSBindings_wrapListenerBlock_og5b6y(_ListenerTrampoline_52 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1, int arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_52)(void * waiter, BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _NutrientInstantIOSBindings_wrapBlockingBlock_og5b6y(
    _BlockingTrampoline_52 block, _BlockingTrampoline_52 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1, int arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ListenerTrampoline_53)(BOOL arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _NutrientInstantIOSBindings_wrapListenerBlock_n4nbpt(_ListenerTrampoline_53 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_53)(void * waiter, BOOL arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _NutrientInstantIOSBindings_wrapBlockingBlock_n4nbpt(
    _BlockingTrampoline_53 block, _BlockingTrampoline_53 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_54)(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _NutrientInstantIOSBindings_wrapListenerBlock_11z9wy5(_ListenerTrampoline_54 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_54)(void * waiter, id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _NutrientInstantIOSBindings_wrapBlockingBlock_11z9wy5(
    _BlockingTrampoline_54 block, _BlockingTrampoline_54 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_55)(id arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _NutrientInstantIOSBindings_wrapListenerBlock_1lhy15d(_ListenerTrampoline_55 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_55)(void * waiter, id arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _NutrientInstantIOSBindings_wrapBlockingBlock_1lhy15d(
    _BlockingTrampoline_55 block, _BlockingTrampoline_55 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ListenerTrampoline_56)(id arg0, id arg1, BOOL arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _NutrientInstantIOSBindings_wrapListenerBlock_pppu4n(_ListenerTrampoline_56 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL arg2, id arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_56)(void * waiter, id arg0, id arg1, BOOL arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _NutrientInstantIOSBindings_wrapBlockingBlock_pppu4n(
    _BlockingTrampoline_56 block, _BlockingTrampoline_56 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ListenerTrampoline_57)(char * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _NutrientInstantIOSBindings_wrapListenerBlock_1r7ue5f(_ListenerTrampoline_57 block) NS_RETURNS_RETAINED {
  return ^void(char * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_57)(void * waiter, char * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _NutrientInstantIOSBindings_wrapBlockingBlock_1r7ue5f(
    _BlockingTrampoline_57 block, _BlockingTrampoline_57 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(char * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_58)(int * arg0, id arg1, unsigned long arg2, struct CGSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _NutrientInstantIOSBindings_wrapListenerBlock_1miu6gv(_ListenerTrampoline_58 block) NS_RETURNS_RETAINED {
  return ^void(int * arg0, id arg1, unsigned long arg2, struct CGSize arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_58)(void * waiter, int * arg0, id arg1, unsigned long arg2, struct CGSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _NutrientInstantIOSBindings_wrapBlockingBlock_1miu6gv(
    _BlockingTrampoline_58 block, _BlockingTrampoline_58 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int * arg0, id arg1, unsigned long arg2, struct CGSize arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_59)(size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _NutrientInstantIOSBindings_wrapListenerBlock_11t2oft(_ListenerTrampoline_59 block) NS_RETURNS_RETAINED {
  return ^void(size_t arg0, struct CGImage * arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_59)(void * waiter, size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _NutrientInstantIOSBindings_wrapBlockingBlock_11t2oft(
    _BlockingTrampoline_59 block, _BlockingTrampoline_59 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(size_t arg0, struct CGImage * arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_60)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _NutrientInstantIOSBindings_wrapListenerBlock_ovsamd(_ListenerTrampoline_60 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_60)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _NutrientInstantIOSBindings_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline_60 block, _BlockingTrampoline_60 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ProtocolTrampoline_24)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_24)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^_ListenerTrampoline_61)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _NutrientInstantIOSBindings_wrapListenerBlock_f167m6(_ListenerTrampoline_61 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0));
  };
}

typedef void  (^_BlockingTrampoline_61)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _NutrientInstantIOSBindings_wrapBlockingBlock_f167m6(
    _BlockingTrampoline_61 block, _BlockingTrampoline_61 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0));
  });
}

typedef void  (^_ListenerTrampoline_62)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _NutrientInstantIOSBindings_wrapListenerBlock_fjrv01(_ListenerTrampoline_62 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_62)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _NutrientInstantIOSBindings_wrapBlockingBlock_fjrv01(
    _BlockingTrampoline_62 block, _BlockingTrampoline_62 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ProtocolTrampoline_25)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_fjrv01(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_25)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_63)(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _NutrientInstantIOSBindings_wrapListenerBlock_1m1m78d(_ListenerTrampoline_63 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_63)(void * waiter, void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _NutrientInstantIOSBindings_wrapBlockingBlock_1m1m78d(
    _BlockingTrampoline_63 block, _BlockingTrampoline_63 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_64)(void * arg0, struct AudioUnitParameter * arg1, float arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _NutrientInstantIOSBindings_wrapListenerBlock_1e9x4g1(_ListenerTrampoline_64 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct AudioUnitParameter * arg1, float arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_64)(void * waiter, void * arg0, struct AudioUnitParameter * arg1, float arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _NutrientInstantIOSBindings_wrapBlockingBlock_1e9x4g1(
    _BlockingTrampoline_64 block, _BlockingTrampoline_64 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct AudioUnitParameter * arg1, float arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_65)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _NutrientInstantIOSBindings_wrapListenerBlock_18v1jvf(_ListenerTrampoline_65 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_65)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _NutrientInstantIOSBindings_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_65 block, _BlockingTrampoline_65 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ProtocolTrampoline_26)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_26)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_66)(void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_66 _NutrientInstantIOSBindings_wrapListenerBlock_18sfmo2(_ListenerTrampoline_66 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, double arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_66)(void * waiter, void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_66 _NutrientInstantIOSBindings_wrapBlockingBlock_18sfmo2(
    _BlockingTrampoline_66 block, _BlockingTrampoline_66 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, double arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_27)(void * sel, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_18sfmo2(id target, void * sel, double arg1) {
  return ((_ProtocolTrampoline_27)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_67)(void * arg0, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_67 _NutrientInstantIOSBindings_wrapListenerBlock_1sf11wt(_ListenerTrampoline_67 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct opaqueCMSampleBuffer * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_67)(void * waiter, void * arg0, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_67 _NutrientInstantIOSBindings_wrapBlockingBlock_1sf11wt(
    _BlockingTrampoline_67 block, _BlockingTrampoline_67 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct opaqueCMSampleBuffer * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_28)(void * sel, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_1sf11wt(id target, void * sel, struct opaqueCMSampleBuffer * arg1) {
  return ((_ProtocolTrampoline_28)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_68)(void * arg0, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_68 _NutrientInstantIOSBindings_wrapListenerBlock_1wp3it5(_ListenerTrampoline_68 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, long arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_68)(void * waiter, void * arg0, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_68 _NutrientInstantIOSBindings_wrapBlockingBlock_1wp3it5(
    _BlockingTrampoline_68 block, _BlockingTrampoline_68 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_29)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_1wp3it5(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_29)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_69)(void * arg0, id arg1, long arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_69 _NutrientInstantIOSBindings_wrapListenerBlock_98c27v(_ListenerTrampoline_69 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, long arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_69)(void * waiter, void * arg0, id arg1, long arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_69 _NutrientInstantIOSBindings_wrapBlockingBlock_98c27v(
    _BlockingTrampoline_69 block, _BlockingTrampoline_69 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, long arg2, long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_30)(void * sel, id arg1, long arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_98c27v(id target, void * sel, id arg1, long arg2, long arg3) {
  return ((_ProtocolTrampoline_30)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_70)(void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_70 _NutrientInstantIOSBindings_wrapListenerBlock_zzthnb(_ListenerTrampoline_70 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_70)(void * waiter, void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_70 _NutrientInstantIOSBindings_wrapBlockingBlock_zzthnb(
    _BlockingTrampoline_70 block, _BlockingTrampoline_70 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_31)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_zzthnb(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_31)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_71)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_71 _NutrientInstantIOSBindings_wrapListenerBlock_1tz5yf(_ListenerTrampoline_71 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_71)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_71 _NutrientInstantIOSBindings_wrapBlockingBlock_1tz5yf(
    _BlockingTrampoline_71 block, _BlockingTrampoline_71 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_32)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_1tz5yf(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_32)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_72)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_72 _NutrientInstantIOSBindings_wrapListenerBlock_bklti2(_ListenerTrampoline_72 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  };
}

typedef void  (^_BlockingTrampoline_72)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_72 _NutrientInstantIOSBindings_wrapBlockingBlock_bklti2(
    _BlockingTrampoline_72 block, _BlockingTrampoline_72 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_33)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_bklti2(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_33)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_73)(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_73 _NutrientInstantIOSBindings_wrapListenerBlock_gw0ghs(_ListenerTrampoline_73 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_73)(void * waiter, void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_73 _NutrientInstantIOSBindings_wrapBlockingBlock_gw0ghs(
    _BlockingTrampoline_73 block, _BlockingTrampoline_73 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_34)(void * sel, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_gw0ghs(id target, void * sel, id arg1, PSPDFAnnotationZIndexMove arg2) {
  return ((_ProtocolTrampoline_34)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_74)(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_74 _NutrientInstantIOSBindings_wrapListenerBlock_5qyi04(_ListenerTrampoline_74 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^_BlockingTrampoline_74)(void * waiter, void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_74 _NutrientInstantIOSBindings_wrapBlockingBlock_5qyi04(
    _BlockingTrampoline_74 block, _BlockingTrampoline_74 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^_ProtocolTrampoline_35)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_5qyi04(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4) {
  return ((_ProtocolTrampoline_35)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_75)(void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_75 _NutrientInstantIOSBindings_wrapListenerBlock_10lndml(_ListenerTrampoline_75 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, BOOL arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_75)(void * waiter, void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_75 _NutrientInstantIOSBindings_wrapBlockingBlock_10lndml(
    _BlockingTrampoline_75 block, _BlockingTrampoline_75 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, BOOL arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_36)(void * sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_10lndml(id target, void * sel, BOOL arg1) {
  return ((_ProtocolTrampoline_36)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_76)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_76 _NutrientInstantIOSBindings_wrapListenerBlock_jk1ljc(_ListenerTrampoline_76 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  };
}

typedef void  (^_BlockingTrampoline_76)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_76 _NutrientInstantIOSBindings_wrapBlockingBlock_jk1ljc(
    _BlockingTrampoline_76 block, _BlockingTrampoline_76 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  });
}

typedef void  (^_ProtocolTrampoline_37)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_jk1ljc(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_37)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_77)(void * arg0, id arg1, struct objc_selector * arg2, void * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_77 _NutrientInstantIOSBindings_wrapListenerBlock_1teny3c(_ListenerTrampoline_77 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct objc_selector * arg2, void * arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_77)(void * waiter, void * arg0, id arg1, struct objc_selector * arg2, void * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_77 _NutrientInstantIOSBindings_wrapBlockingBlock_1teny3c(
    _BlockingTrampoline_77 block, _BlockingTrampoline_77 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct objc_selector * arg2, void * arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_38)(void * sel, id arg1, struct objc_selector * arg2, void * arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_1teny3c(id target, void * sel, id arg1, struct objc_selector * arg2, void * arg3) {
  return ((_ProtocolTrampoline_38)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_78)(void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_78 _NutrientInstantIOSBindings_wrapListenerBlock_be1lg6(_ListenerTrampoline_78 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct objc_selector * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_78)(void * waiter, void * arg0, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_78 _NutrientInstantIOSBindings_wrapBlockingBlock_be1lg6(
    _BlockingTrampoline_78 block, _BlockingTrampoline_78 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct objc_selector * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_39)(void * sel, struct objc_selector * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientInstantIOSBindings_protocolTrampoline_be1lg6(id target, void * sel, struct objc_selector * arg1) {
  return ((_ProtocolTrampoline_39)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_79)(nw_browser_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_79 _NutrientInstantIOSBindings_wrapListenerBlock_1g2tbdc(_ListenerTrampoline_79 block) NS_RETURNS_RETAINED {
  return ^void(nw_browser_state_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_79)(void * waiter, nw_browser_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_79 _NutrientInstantIOSBindings_wrapBlockingBlock_1g2tbdc(
    _BlockingTrampoline_79 block, _BlockingTrampoline_79 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(nw_browser_state_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_80)(nw_connection_group_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_80 _NutrientInstantIOSBindings_wrapListenerBlock_z58qem(_ListenerTrampoline_80 block) NS_RETURNS_RETAINED {
  return ^void(nw_connection_group_state_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_80)(void * waiter, nw_connection_group_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_80 _NutrientInstantIOSBindings_wrapBlockingBlock_z58qem(
    _BlockingTrampoline_80 block, _BlockingTrampoline_80 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(nw_connection_group_state_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_81)(nw_connection_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_81 _NutrientInstantIOSBindings_wrapListenerBlock_1a8f0dm(_ListenerTrampoline_81 block) NS_RETURNS_RETAINED {
  return ^void(nw_connection_state_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_81)(void * waiter, nw_connection_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_81 _NutrientInstantIOSBindings_wrapBlockingBlock_1a8f0dm(
    _BlockingTrampoline_81 block, _BlockingTrampoline_81 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(nw_connection_state_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_82)(id arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_82 _NutrientInstantIOSBindings_wrapListenerBlock_6p7ndb(_ListenerTrampoline_82 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_82)(void * waiter, id arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_82 _NutrientInstantIOSBindings_wrapBlockingBlock_6p7ndb(
    _BlockingTrampoline_82 block, _BlockingTrampoline_82 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^_ListenerTrampoline_83)(nw_ethernet_channel_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_83 _NutrientInstantIOSBindings_wrapListenerBlock_1qkc9y7(_ListenerTrampoline_83 block) NS_RETURNS_RETAINED {
  return ^void(nw_ethernet_channel_state_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_83)(void * waiter, nw_ethernet_channel_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_83 _NutrientInstantIOSBindings_wrapBlockingBlock_1qkc9y7(
    _BlockingTrampoline_83 block, _BlockingTrampoline_83 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(nw_ethernet_channel_state_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_84)(id arg0, id arg1, size_t arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_84 _NutrientInstantIOSBindings_wrapListenerBlock_vrbbwj(_ListenerTrampoline_84 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, size_t arg2, BOOL arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_84)(void * waiter, id arg0, id arg1, size_t arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_84 _NutrientInstantIOSBindings_wrapBlockingBlock_vrbbwj(
    _BlockingTrampoline_84 block, _BlockingTrampoline_84 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, size_t arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_85)(nw_listener_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_85 _NutrientInstantIOSBindings_wrapListenerBlock_1qfkyaa(_ListenerTrampoline_85 block) NS_RETURNS_RETAINED {
  return ^void(nw_listener_state_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_85)(void * waiter, nw_listener_state_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_85 _NutrientInstantIOSBindings_wrapBlockingBlock_1qfkyaa(
    _BlockingTrampoline_85 block, _BlockingTrampoline_85 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(nw_listener_state_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_86)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_86 _NutrientInstantIOSBindings_wrapListenerBlock_18qun1e(_ListenerTrampoline_86 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  };
}

typedef void  (^_BlockingTrampoline_86)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_86 _NutrientInstantIOSBindings_wrapBlockingBlock_18qun1e(
    _BlockingTrampoline_86 block, _BlockingTrampoline_86 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  });
}

Protocol* _NutrientInstantIOSBindings_PSPDFInstantClientDelegate(void) { return @protocol(PSPDFInstantClientDelegate); }

Protocol* _NutrientInstantIOSBindings_PSPDFInstantDocumentCacheEntry(void) { return @protocol(PSPDFInstantDocumentCacheEntry); }

Protocol* _NutrientInstantIOSBindings_PSPDFInstantDocumentDescriptor(void) { return @protocol(PSPDFInstantDocumentDescriptor); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
