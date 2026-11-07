#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <PSPDFKit/PSPDFKit.h>
#import <PSPDFKitUI/PSPDFKitUI.h>
#import "NutrientFFI.h"

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


Protocol* _NutrientIOSBindings_NSTextLocation(void) { return @protocol(NSTextLocation); }

typedef struct CGAffineTransform  (^_ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct CGAffineTransform  _NutrientIOSBindings_protocolTrampoline_8o6he9(id target, void * sel) {
  return ((_ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef double  (^_ProtocolTrampoline_1)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
double  _NutrientIOSBindings_protocolTrampoline_tfvuzk(id target, void * sel) {
  return ((_ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef double  (^_ProtocolTrampoline_2)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
double  _NutrientIOSBindings_protocolTrampoline_1x666sm(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef double  (^_ProtocolTrampoline_3)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
double  _NutrientIOSBindings_protocolTrampoline_1kspct0(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef double  (^_ProtocolTrampoline_4)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
double  _NutrientIOSBindings_protocolTrampoline_5bm8w8(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct CGPoint  (^_ProtocolTrampoline_5)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct CGPoint  _NutrientIOSBindings_protocolTrampoline_7ohnx8(id target, void * sel) {
  return ((_ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct CGPoint  (^_ProtocolTrampoline_6)(void * sel, struct CGPoint arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
struct CGPoint  _NutrientIOSBindings_protocolTrampoline_17ipln5(id target, void * sel, struct CGPoint arg1, id arg2) {
  return ((_ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct CGPoint  (^_ProtocolTrampoline_7)(void * sel, id arg1, struct CGPoint arg2);
__attribute__((visibility("default"))) __attribute__((used))
struct CGPoint  _NutrientIOSBindings_protocolTrampoline_pftu99(id target, void * sel, id arg1, struct CGPoint arg2) {
  return ((_ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct CGPoint  (^_ProtocolTrampoline_8)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
struct CGPoint  _NutrientIOSBindings_protocolTrampoline_1hsw88y(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef struct CGRect  (^_ProtocolTrampoline_9)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct CGRect  _NutrientIOSBindings_protocolTrampoline_1c3uc0w(id target, void * sel) {
  return ((_ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct CGRect  (^_ProtocolTrampoline_10)(void * sel, struct CGRect arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
struct CGRect  _NutrientIOSBindings_protocolTrampoline_1sh7l9z(id target, void * sel, struct CGRect arg1, id arg2) {
  return ((_ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct CGRect  (^_ProtocolTrampoline_11)(void * sel, id arg1, struct CGRect arg2, struct CGPoint arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
struct CGRect  _NutrientIOSBindings_protocolTrampoline_iqdvkd(id target, void * sel, id arg1, struct CGRect arg2, struct CGPoint arg3, unsigned long arg4) {
  return ((_ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef struct CGRect  (^_ProtocolTrampoline_12)(void * sel, id arg1, PSPDFFlexibleToolbarPosition arg2);
__attribute__((visibility("default"))) __attribute__((used))
struct CGRect  _NutrientIOSBindings_protocolTrampoline_13kna1w(id target, void * sel, id arg1, PSPDFFlexibleToolbarPosition arg2) {
  return ((_ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct CGRect  (^_ProtocolTrampoline_13)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
struct CGRect  _NutrientIOSBindings_protocolTrampoline_szn7s6(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef struct CGSize  (^_ProtocolTrampoline_14)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct CGSize  _NutrientIOSBindings_protocolTrampoline_1j20mp(id target, void * sel) {
  return ((_ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct CGSize  (^_ProtocolTrampoline_15)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
struct CGSize  _NutrientIOSBindings_protocolTrampoline_ckubc3(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef struct CGSize  (^_ProtocolTrampoline_16)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
struct CGSize  _NutrientIOSBindings_protocolTrampoline_jdolg0(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef struct CGSize  (^_ProtocolTrampoline_17)(void * sel, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
struct CGSize  _NutrientIOSBindings_protocolTrampoline_141imqv(id target, void * sel, id arg1, id arg2, long arg3) {
  return ((_ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef struct CGSize  (^_ProtocolTrampoline_18)(void * sel, id arg1, struct CGSize arg2);
__attribute__((visibility("default"))) __attribute__((used))
struct CGSize  _NutrientIOSBindings_protocolTrampoline_gnbb7x(id target, void * sel, id arg1, struct CGSize arg2) {
  return ((_ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct OpaqueCMTimebase *  (^_ProtocolTrampoline_19)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct OpaqueCMTimebase *  _NutrientIOSBindings_protocolTrampoline_1hdtd53(id target, void * sel) {
  return ((_ProtocolTrampoline_19)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef int32_t  (^_ProtocolTrampoline_20)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
int32_t  _NutrientIOSBindings_protocolTrampoline_zksw7k(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_20)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_21)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((_ProtocolTrampoline_21)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_22)(void * sel, struct CGRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_12thpau(id target, void * sel, struct CGRect arg1) {
  return ((_ProtocolTrampoline_22)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_23)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_zi5eed(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_23)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_24)(void * sel, id * arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_361moc(id target, void * sel, id * arg1) {
  return ((_ProtocolTrampoline_24)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_25)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_10s6poe(id target, void * sel, id arg1, id * arg2) {
  return ((_ProtocolTrampoline_25)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_26)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_3nbx5e(id target, void * sel, unsigned long arg1) {
  return ((_ProtocolTrampoline_26)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_27)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_27)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_28)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1yw2rcr(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_28)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_29)(void * sel, id arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_ggvik5(id target, void * sel, id arg1, struct _NSRange arg2) {
  return ((_ProtocolTrampoline_29)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef NSComparisonResult  (^_ProtocolTrampoline_30)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
NSComparisonResult  _NutrientIOSBindings_protocolTrampoline_1xws32k(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_30)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_31)(void * sel, id arg1, PSPDFSignatureHashAlgorithm arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_wzff2j(id target, void * sel, id arg1, PSPDFSignatureHashAlgorithm arg2) {
  return ((_ProtocolTrampoline_31)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_32)(void * sel, id arg1, NSDataReadingOptions arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_fscnsh(id target, void * sel, id arg1, NSDataReadingOptions arg2, id * arg3) {
  return ((_ProtocolTrampoline_32)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_33)(void * sel, uint64_t arg1, uint64_t arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_wbvms8(id target, void * sel, uint64_t arg1, uint64_t arg2, id * arg3) {
  return ((_ProtocolTrampoline_33)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_34)(void * sel, id arg1, id arg2, NSDirectoryEnumerationOptions arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_18a1ztj(id target, void * sel, id arg1, id arg2, NSDirectoryEnumerationOptions arg3, id arg4) {
  return ((_ProtocolTrampoline_34)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^_ProtocolTrampoline_35)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_qfyidt(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_35)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^_ProtocolTrampoline_36)(void * sel, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1tgdqpb(id target, void * sel, id arg1, id arg2, long arg3) {
  return ((_ProtocolTrampoline_36)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef long  (^_ProtocolTrampoline_37)(void * sel, long arg1);
__attribute__((visibility("default"))) __attribute__((used))
long  _NutrientIOSBindings_protocolTrampoline_1p78ubn(id target, void * sel, long arg1) {
  return ((_ProtocolTrampoline_37)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef long  (^_ProtocolTrampoline_38)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
long  _NutrientIOSBindings_protocolTrampoline_sqbvvb(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_38)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef long  (^_ProtocolTrampoline_39)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
long  _NutrientIOSBindings_protocolTrampoline_1e5b3dp(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_39)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef long  (^_ProtocolTrampoline_40)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
long  _NutrientIOSBindings_protocolTrampoline_evw03x(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_40)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef long  (^_ProtocolTrampoline_41)(void * sel, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
long  _NutrientIOSBindings_protocolTrampoline_12jo9nb(id target, void * sel, id arg1, id arg2, long arg3) {
  return ((_ProtocolTrampoline_41)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef NSItemProviderRepresentationVisibility  (^_ProtocolTrampoline_42)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
NSItemProviderRepresentationVisibility  _NutrientIOSBindings_protocolTrampoline_1ldqghh(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_42)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_43)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1q0i84(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_43)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_44)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1xvw1tx(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_44)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef unsigned long  (^_ProtocolTrampoline_45)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _NutrientIOSBindings_protocolTrampoline_1ckyi24(id target, void * sel) {
  return ((_ProtocolTrampoline_45)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^_ProtocolTrampoline_46)(void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _NutrientIOSBindings_protocolTrampoline_17ap02x(id target, void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_46)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef unsigned long  (^_ProtocolTrampoline_47)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _NutrientIOSBindings_protocolTrampoline_18rn8gi(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_47)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^_ProtocolTrampoline_48)(void * sel, id arg1, id * arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_e41i8j(id target, void * sel, id arg1, id * arg2, id * arg3) {
  return ((_ProtocolTrampoline_48)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_49)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_10z9f5k(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((_ProtocolTrampoline_49)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef PSPDFDataProvidingAdditionalOperations  (^_ProtocolTrampoline_50)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFDataProvidingAdditionalOperations  _NutrientIOSBindings_protocolTrampoline_dzi011(id target, void * sel) {
  return ((_ProtocolTrampoline_50)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef PSPDFDataSinkOptions  (^_ProtocolTrampoline_51)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFDataSinkOptions  _NutrientIOSBindings_protocolTrampoline_15lqesn(id target, void * sel) {
  return ((_ProtocolTrampoline_51)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef PSPDFDocumentViewLayoutPageMode  (^_ProtocolTrampoline_52)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFDocumentViewLayoutPageMode  _NutrientIOSBindings_protocolTrampoline_s32atu(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_52)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_53)(void * sel, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_skjqxk(id target, void * sel, id arg1, unsigned long arg2) {
  return ((_ProtocolTrampoline_53)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef PSPDFKnobType  (^_ProtocolTrampoline_54)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFKnobType  _NutrientIOSBindings_protocolTrampoline_zwtboe(id target, void * sel) {
  return ((_ProtocolTrampoline_54)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^_ProtocolTrampoline_55)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _NutrientIOSBindings_protocolTrampoline_1xrqj4g(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_55)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_56)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_zb0vvk(id target, void * sel) {
  return ((_ProtocolTrampoline_56)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_57)(void * sel, id arg1, PSPDFAppearanceMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1mtxout(id target, void * sel, id arg1, PSPDFAppearanceMode arg2) {
  return ((_ProtocolTrampoline_57)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef PSPDFSignatureEncryptionAlgorithm  (^_ProtocolTrampoline_58)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFSignatureEncryptionAlgorithm  _NutrientIOSBindings_protocolTrampoline_75mtla(id target, void * sel) {
  return ((_ProtocolTrampoline_58)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef PSPDFSignatureEncryptionAlgorithm  (^_ProtocolTrampoline_59)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFSignatureEncryptionAlgorithm  _NutrientIOSBindings_protocolTrampoline_1027no2(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_59)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef PSPDFSignatureHashAlgorithm  (^_ProtocolTrampoline_60)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFSignatureHashAlgorithm  _NutrientIOSBindings_protocolTrampoline_1xiub93(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_60)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef PSPDFStatefulViewState  (^_ProtocolTrampoline_61)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFStatefulViewState  _NutrientIOSBindings_protocolTrampoline_14gp5q4(id target, void * sel) {
  return ((_ProtocolTrampoline_61)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef PSPDFViewMode  (^_ProtocolTrampoline_62)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
PSPDFViewMode  _NutrientIOSBindings_protocolTrampoline_r3qxbg(id target, void * sel) {
  return ((_ProtocolTrampoline_62)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef UIBarPosition  (^_ProtocolTrampoline_63)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
UIBarPosition  _NutrientIOSBindings_protocolTrampoline_1aqbt4z(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_63)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef UIBarStyle  (^_ProtocolTrampoline_64)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
UIBarStyle  _NutrientIOSBindings_protocolTrampoline_15h7u8f(id target, void * sel) {
  return ((_ProtocolTrampoline_64)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_65)(void * sel, id arg1, id arg2, struct CGPoint arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_11umze2(id target, void * sel, id arg1, id arg2, struct CGPoint arg3) {
  return ((_ProtocolTrampoline_65)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef UIDynamicItemCollisionBoundsType  (^_ProtocolTrampoline_66)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
UIDynamicItemCollisionBoundsType  _NutrientIOSBindings_protocolTrampoline_ku69ws(id target, void * sel) {
  return ((_ProtocolTrampoline_66)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef struct UIEdgeInsets  (^_ProtocolTrampoline_67)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct UIEdgeInsets  _NutrientIOSBindings_protocolTrampoline_1rtilx3(id target, void * sel) {
  return ((_ProtocolTrampoline_67)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef UIFocusItemDeferralMode  (^_ProtocolTrampoline_68)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
UIFocusItemDeferralMode  _NutrientIOSBindings_protocolTrampoline_1qeotwu(id target, void * sel) {
  return ((_ProtocolTrampoline_68)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_69)(void * sel, struct CGRect arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_qwb72h(id target, void * sel, struct CGRect arg1, id arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_69)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef UIInterfaceOrientationMask  (^_ProtocolTrampoline_70)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
UIInterfaceOrientationMask  _NutrientIOSBindings_protocolTrampoline_l5rsi(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_70)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef UIInterfaceOrientation  (^_ProtocolTrampoline_71)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
UIInterfaceOrientation  _NutrientIOSBindings_protocolTrampoline_1ahzoma(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_71)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef UILetterformAwareSizingRule  (^_ProtocolTrampoline_72)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
UILetterformAwareSizingRule  _NutrientIOSBindings_protocolTrampoline_o2xzcr(id target, void * sel) {
  return ((_ProtocolTrampoline_72)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^_ProtocolTrampoline_73)(void * sel, id arg1, struct CGPoint arg2, id arg3, PSPDFEditMenuAppearance arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1vh6qro(id target, void * sel, id arg1, struct CGPoint arg2, id arg3, PSPDFEditMenuAppearance arg4, id arg5) {
  return ((_ProtocolTrampoline_73)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef id  (^_ProtocolTrampoline_74)(void * sel, id arg1, id arg2, id arg3, PSPDFEditMenuAppearance arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1knryfr(id target, void * sel, id arg1, id arg2, id arg3, PSPDFEditMenuAppearance arg4, id arg5) {
  return ((_ProtocolTrampoline_74)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef id  (^_ProtocolTrampoline_75)(void * sel, id arg1, struct _NSRange arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_166zki3(id target, void * sel, id arg1, struct _NSRange arg2, id arg3) {
  return ((_ProtocolTrampoline_75)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef UITableViewCellAccessoryType  (^_ProtocolTrampoline_76)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
UITableViewCellAccessoryType  _NutrientIOSBindings_protocolTrampoline_99g1re(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_76)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef UITableViewCellEditingStyle  (^_ProtocolTrampoline_77)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
UITableViewCellEditingStyle  _NutrientIOSBindings_protocolTrampoline_xo1673(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_77)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_78)(void * sel, id arg1, id arg2, BOOL arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1p3knoe(id target, void * sel, id arg1, id arg2, BOOL arg3, id arg4) {
  return ((_ProtocolTrampoline_78)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef uint64_t  (^_ProtocolTrampoline_79)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
uint64_t  _NutrientIOSBindings_protocolTrampoline_k3xjiw(id target, void * sel) {
  return ((_ProtocolTrampoline_79)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_80)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((_ProtocolTrampoline_80)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef BOOL  (^_ProtocolTrampoline_81)(void * sel, struct CGPoint arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1umlnay(id target, void * sel, struct CGPoint arg1, id arg2) {
  return ((_ProtocolTrampoline_81)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_82)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_82)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_83)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_joosg4(id target, void * sel, id arg1, id * arg2) {
  return ((_ProtocolTrampoline_83)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_84)(void * sel, id arg1, id arg2, NSDataWritingOptions arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1lq5n21(id target, void * sel, id arg1, id arg2, NSDataWritingOptions arg3, id * arg4) {
  return ((_ProtocolTrampoline_84)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_85)(void * sel, id * arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_jp3gca(id target, void * sel, id * arg1) {
  return ((_ProtocolTrampoline_85)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_86)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_jk8du5(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_86)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_87)(void * sel, id arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1kxrxpn(id target, void * sel, id arg1, BOOL * arg2) {
  return ((_ProtocolTrampoline_87)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_88)(void * sel, id arg1, BOOL arg2, id arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_10qmkm6(id target, void * sel, id arg1, BOOL arg2, id arg3, id * arg4) {
  return ((_ProtocolTrampoline_88)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_89)(void * sel, unsigned long arg1, unsigned long arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1w2yxsc(id target, void * sel, unsigned long arg1, unsigned long arg2, id * arg3) {
  return ((_ProtocolTrampoline_89)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_90)(void * sel, unsigned long arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_hjahug(id target, void * sel, unsigned long arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_90)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_91)(void * sel, id arg1, id * arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1lvll7z(id target, void * sel, id arg1, id * arg2, id arg3) {
  return ((_ProtocolTrampoline_91)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_92)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_oqebfq(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((_ProtocolTrampoline_92)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_93)(void * sel, id arg1, id arg2, id arg3, NSFileManagerItemReplacementOptions arg4, id * arg5, id * arg6);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_ezlmno(id target, void * sel, id arg1, id arg2, id arg3, NSFileManagerItemReplacementOptions arg4, id * arg5, id * arg6) {
  return ((_ProtocolTrampoline_93)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef BOOL  (^_ProtocolTrampoline_94)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_7rhb6y(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_94)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_95)(void * sel, id arg1, struct CGRect arg2, unsigned long arg3, BOOL arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1suwsgt(id target, void * sel, id arg1, struct CGRect arg2, unsigned long arg3, BOOL arg4, id arg5) {
  return ((_ProtocolTrampoline_95)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_96)(void * sel, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1yi3beh(id target, void * sel, id arg1, id arg2, id arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_96)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_97)(void * sel, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1xgs5se(id target, void * sel, id arg1, PSPDFAnnotationZIndexMove arg2) {
  return ((_ProtocolTrampoline_97)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_98)(void * sel, PSPDFAnnotationZIndexMove arg1, unsigned long arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_fkispk(id target, void * sel, PSPDFAnnotationZIndexMove arg1, unsigned long arg2, id * arg3) {
  return ((_ProtocolTrampoline_98)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_99)(void * sel, id arg1, unsigned long arg2, id arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_upqs9t(id target, void * sel, id arg1, unsigned long arg2, id arg3, id * arg4) {
  return ((_ProtocolTrampoline_99)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_100)(void * sel, id arg1, id arg2, id arg3, PSPDFFileConflictResolution arg4, id * arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_pctdvv(id target, void * sel, id arg1, id arg2, id arg3, PSPDFFileConflictResolution arg4, id * arg5) {
  return ((_ProtocolTrampoline_100)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_101)(void * sel, id arg1, id arg2, id arg3, PSPDFFileConflictType arg4, PSPDFFileConflictResolution * arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1lgerdv(id target, void * sel, id arg1, id arg2, id arg3, PSPDFFileConflictType arg4, PSPDFFileConflictResolution * arg5) {
  return ((_ProtocolTrampoline_101)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_102)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_2n06mv(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_102)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_103)(void * sel, PSPDFFileConflictResolution arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_11rwx0l(id target, void * sel, PSPDFFileConflictResolution arg1, id * arg2) {
  return ((_ProtocolTrampoline_103)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_104)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_15ssoz8(id target, void * sel, unsigned long arg1) {
  return ((_ProtocolTrampoline_104)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_105)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_9k4e9l(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_105)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_106)(void * sel, id arg1, struct CGPoint arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_g0ff12(id target, void * sel, id arg1, struct CGPoint arg2) {
  return ((_ProtocolTrampoline_106)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_107)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_h7kw4q(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4) {
  return ((_ProtocolTrampoline_107)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_108)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_114y1g8(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5) {
  return ((_ProtocolTrampoline_108)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_109)(void * sel, id arg1, id arg2, struct CGPoint arg3, id arg4, id arg5, struct CGPoint arg6);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1c3eadv(id target, void * sel, id arg1, id arg2, struct CGPoint arg3, id arg4, id arg5, struct CGPoint arg6) {
  return ((_ProtocolTrampoline_109)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef BOOL  (^_ProtocolTrampoline_110)(void * sel, id arg1, id arg2, id arg3, BOOL arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_19icu2t(id target, void * sel, id arg1, id arg2, id arg3, BOOL arg4) {
  return ((_ProtocolTrampoline_110)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_111)(void * sel, id arg1, struct objc_selector * arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1yp3wri(id target, void * sel, id arg1, struct objc_selector * arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_111)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_112)(void * sel, id arg1, struct _NSRange arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_u18wpp(id target, void * sel, id arg1, struct _NSRange arg2, id arg3) {
  return ((_ProtocolTrampoline_112)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_113)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1ae3jer(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_113)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_114)(void * sel, id arg1, id arg2, struct _NSRange arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_132e89p(id target, void * sel, id arg1, id arg2, struct _NSRange arg3) {
  return ((_ProtocolTrampoline_114)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^_ProtocolTrampoline_115)(void * sel, id arg1, id arg2, struct _NSRange arg3, UITextItemInteraction arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_11bdmat(id target, void * sel, id arg1, id arg2, struct _NSRange arg3, UITextItemInteraction arg4) {
  return ((_ProtocolTrampoline_115)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_116)(void * sel, id arg1, id arg2, BOOL arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_149puq(id target, void * sel, id arg1, id arg2, BOOL arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_116)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef BOOL  (^_ProtocolTrampoline_117)(void * sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_2pswnb(id target, void * sel, BOOL arg1) {
  return ((_ProtocolTrampoline_117)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^_ProtocolTrampoline_118)(void * sel, BOOL arg1, id arg2, id arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1echywy(id target, void * sel, BOOL arg1, id arg2, id arg3, id * arg4) {
  return ((_ProtocolTrampoline_118)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef BOOL  (^_ProtocolTrampoline_119)(void * sel, void * arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_afzlid(id target, void * sel, void * arg1, id arg2) {
  return ((_ProtocolTrampoline_119)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef BOOL  (^_ProtocolTrampoline_120)(void * sel, id arg1, BOOL arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _NutrientIOSBindings_protocolTrampoline_1lce076(id target, void * sel, id arg1, BOOL arg2, id arg3) {
  return ((_ProtocolTrampoline_120)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef char *  (^_ProtocolTrampoline_121)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
char *  _NutrientIOSBindings_protocolTrampoline_llgiz7(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_121)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef size_t  (^_ProtocolTrampoline_122)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
size_t  _NutrientIOSBindings_protocolTrampoline_150qdkd(id target, void * sel) {
  return ((_ProtocolTrampoline_122)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _NutrientIOSBindings_wrapListenerBlock_1pl9qdv(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^_BlockingTrampoline)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline _NutrientIOSBindings_wrapBlockingBlock_1pl9qdv(
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
_ListenerTrampoline_1 _NutrientIOSBindings_wrapListenerBlock_d5qk2g(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_1)(void * waiter, int64_t arg0, uint32_t arg1, uint64_t arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_1 _NutrientIOSBindings_wrapBlockingBlock_d5qk2g(
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
_ListenerTrampoline_2 _NutrientIOSBindings_wrapListenerBlock_1dy5sj5(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_2)(void * waiter, int64_t arg0, uint8_t arg1, long arg2, uint8_t * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_2 _NutrientIOSBindings_wrapBlockingBlock_1dy5sj5(
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
_ListenerTrampoline_3 _NutrientIOSBindings_wrapListenerBlock_xr8iv0(_ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(uint64_t arg0, float arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_3)(void * waiter, uint64_t arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_3 _NutrientIOSBindings_wrapBlockingBlock_xr8iv0(
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
_ListenerTrampoline_4 _NutrientIOSBindings_wrapListenerBlock_142x8lj(_ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, float arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_4)(void * waiter, id arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_4 _NutrientIOSBindings_wrapBlockingBlock_142x8lj(
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
_ListenerTrampoline_5 _NutrientIOSBindings_wrapListenerBlock_c466x6(_ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(AUVoiceIOSpeechActivityEvent arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_5)(void * waiter, AUVoiceIOSpeechActivityEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_5 _NutrientIOSBindings_wrapBlockingBlock_c466x6(
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
_ListenerTrampoline_6 _NutrientIOSBindings_wrapListenerBlock_pfv6jd(_ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_6)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_6 _NutrientIOSBindings_wrapBlockingBlock_pfv6jd(
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
_ListenerTrampoline_7 _NutrientIOSBindings_wrapListenerBlock_xtuoz7(_ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^_BlockingTrampoline_7)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_7 _NutrientIOSBindings_wrapBlockingBlock_xtuoz7(
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
_ListenerTrampoline_8 _NutrientIOSBindings_wrapListenerBlock_go4t5m(_ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(AVAudioPlayerNodeCompletionCallbackType arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_8)(void * waiter, AVAudioPlayerNodeCompletionCallbackType arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_8 _NutrientIOSBindings_wrapBlockingBlock_go4t5m(
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
_ListenerTrampoline_9 _NutrientIOSBindings_wrapListenerBlock_7at20g(_ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, double * arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_9)(void * waiter, id arg0, double * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_9 _NutrientIOSBindings_wrapBlockingBlock_7at20g(
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
_ListenerTrampoline_10 _NutrientIOSBindings_wrapListenerBlock_qf8tk6(_ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, double arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_10)(void * waiter, id arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_10 _NutrientIOSBindings_wrapBlockingBlock_qf8tk6(
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
_ListenerTrampoline_11 _NutrientIOSBindings_wrapListenerBlock_1v0mrw4(_ListenerTrampoline_11 block) NS_RETURNS_RETAINED {
  return ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_11)(void * waiter, struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_11 _NutrientIOSBindings_wrapBlockingBlock_1v0mrw4(
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
_ListenerTrampoline_12 _NutrientIOSBindings_wrapListenerBlock_uefqw7(_ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_12)(void * waiter, struct OpaqueAudioQueue * arg0, struct AudioQueueBuffer * arg1, struct AudioTimeStamp * arg2, unsigned arg3, struct AudioStreamPacketDescription * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_12 _NutrientIOSBindings_wrapBlockingBlock_uefqw7(
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
_ListenerTrampoline_13 _NutrientIOSBindings_wrapListenerBlock_1sfe49o(_ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRemoteControlEvent arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_13)(void * waiter, AudioUnitRemoteControlEvent arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_13 _NutrientIOSBindings_wrapBlockingBlock_1sfe49o(
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
_ListenerTrampoline_14 _NutrientIOSBindings_wrapListenerBlock_1jn8q5n(_ListenerTrampoline_14 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_14)(void * waiter, AudioUnitRenderActionFlags arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_14 _NutrientIOSBindings_wrapBlockingBlock_1jn8q5n(
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
_ListenerTrampoline_15 _NutrientIOSBindings_wrapListenerBlock_18q2rn5(_ListenerTrampoline_15 block) NS_RETURNS_RETAINED {
  return ^void(AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_15)(void * waiter, AudioUnitRenderActionFlags * arg0, struct AudioTimeStamp * arg1, uint32_t arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_15 _NutrientIOSBindings_wrapBlockingBlock_18q2rn5(
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
_ListenerTrampoline_16 _NutrientIOSBindings_wrapListenerBlock_1208de5(_ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(struct AudioUnitRenderContext * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_16)(void * waiter, struct AudioUnitRenderContext * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_16 _NutrientIOSBindings_wrapBlockingBlock_1208de5(
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

typedef void  (^_ListenerTrampoline_17)(struct CGContext * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _NutrientIOSBindings_wrapListenerBlock_eekmh7(_ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(struct CGContext * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_17)(void * waiter, struct CGContext * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_17 _NutrientIOSBindings_wrapBlockingBlock_eekmh7(
    _BlockingTrampoline_17 block, _BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct CGContext * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_18)(struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _NutrientIOSBindings_wrapListenerBlock_htoix7(_ListenerTrampoline_18 block) NS_RETURNS_RETAINED {
  return ^void(struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_18)(void * waiter, struct CGContext * arg0, unsigned long arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_18 _NutrientIOSBindings_wrapBlockingBlock_htoix7(
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

typedef void  (^_ListenerTrampoline_19)(double arg0, id arg1, BOOL arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _NutrientIOSBindings_wrapListenerBlock_o4flre(_ListenerTrampoline_19 block) NS_RETURNS_RETAINED {
  return ^void(double arg0, id arg1, BOOL arg2, BOOL * arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_19)(void * waiter, double arg0, id arg1, BOOL arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_19 _NutrientIOSBindings_wrapBlockingBlock_o4flre(
    _BlockingTrampoline_19 block, _BlockingTrampoline_19 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(double arg0, id arg1, BOOL arg2, BOOL * arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_20)(struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _NutrientIOSBindings_wrapListenerBlock_1ctgxtl(_ListenerTrampoline_20 block) NS_RETURNS_RETAINED {
  return ^void(struct CGPathElement * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_20)(void * waiter, struct CGPathElement * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_20 _NutrientIOSBindings_wrapBlockingBlock_1ctgxtl(
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

typedef void  (^_ListenerTrampoline_21)(struct CGSize arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _NutrientIOSBindings_wrapListenerBlock_13lgpwz(_ListenerTrampoline_21 block) NS_RETURNS_RETAINED {
  return ^void(struct CGSize arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_21)(void * waiter, struct CGSize arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_21 _NutrientIOSBindings_wrapBlockingBlock_13lgpwz(
    _BlockingTrampoline_21 block, _BlockingTrampoline_21 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct CGSize arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_22)(struct opaqueCMBufferQueueTriggerToken * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _NutrientIOSBindings_wrapListenerBlock_19rd2sv(_ListenerTrampoline_22 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMBufferQueueTriggerToken * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_22)(void * waiter, struct opaqueCMBufferQueueTriggerToken * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_22 _NutrientIOSBindings_wrapBlockingBlock_19rd2sv(
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
_ListenerTrampoline_23 _NutrientIOSBindings_wrapListenerBlock_lof6g0(_ListenerTrampoline_23 block) NS_RETURNS_RETAINED {
  return ^void(int32_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_23)(void * waiter, int32_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_23 _NutrientIOSBindings_wrapBlockingBlock_lof6g0(
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
_ListenerTrampoline_24 _NutrientIOSBindings_wrapListenerBlock_b3hvj9(_ListenerTrampoline_24 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMSampleBuffer * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_24)(void * waiter, struct opaqueCMSampleBuffer * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_24 _NutrientIOSBindings_wrapBlockingBlock_b3hvj9(
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
_ListenerTrampoline_25 _NutrientIOSBindings_wrapListenerBlock_3f698x(_ListenerTrampoline_25 block) NS_RETURNS_RETAINED {
  return ^void(struct opaqueCMSampleBuffer * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_25)(void * waiter, struct opaqueCMSampleBuffer * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_25 _NutrientIOSBindings_wrapBlockingBlock_3f698x(
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
_ListenerTrampoline_26 _NutrientIOSBindings_wrapListenerBlock_1hznzoi(_ListenerTrampoline_26 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_26)(void * waiter, CMTime arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_26 _NutrientIOSBindings_wrapBlockingBlock_1hznzoi(
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
_ListenerTrampoline_27 _NutrientIOSBindings_wrapListenerBlock_1gyb8q7(_ListenerTrampoline_27 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4));
  };
}

typedef void  (^_BlockingTrampoline_27)(void * waiter, CMTime arg0, struct CGImage * arg1, CMTime arg2, AVAssetImageGeneratorResult arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_27 _NutrientIOSBindings_wrapBlockingBlock_1gyb8q7(
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
_ListenerTrampoline_28 _NutrientIOSBindings_wrapListenerBlock_fgo1sw(_ListenerTrampoline_28 block) NS_RETURNS_RETAINED {
  return ^void(CMTime arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_28)(void * waiter, CMTime arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_28 _NutrientIOSBindings_wrapBlockingBlock_fgo1sw(
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

typedef void  (^_ListenerTrampoline_29)(id arg0, struct CGPoint arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _NutrientIOSBindings_wrapListenerBlock_14v8ia(_ListenerTrampoline_29 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct CGPoint arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_29)(void * waiter, id arg0, struct CGPoint arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_29 _NutrientIOSBindings_wrapBlockingBlock_14v8ia(
    _BlockingTrampoline_29 block, _BlockingTrampoline_29 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct CGPoint arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_30)(int64_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _NutrientIOSBindings_wrapListenerBlock_mpxix1(_ListenerTrampoline_30 block) NS_RETURNS_RETAINED {
  return ^void(int64_t arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_30)(void * waiter, int64_t arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_30 _NutrientIOSBindings_wrapBlockingBlock_mpxix1(
    _BlockingTrampoline_30 block, _BlockingTrampoline_30 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(int64_t arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_31)(struct MIDIEventList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _NutrientIOSBindings_wrapListenerBlock_zl28ap(_ListenerTrampoline_31 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDIEventList * arg0, void * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_31)(void * waiter, struct MIDIEventList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_31 _NutrientIOSBindings_wrapBlockingBlock_zl28ap(
    _BlockingTrampoline_31 block, _BlockingTrampoline_31 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDIEventList * arg0, void * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_32)(struct MIDINotification * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _NutrientIOSBindings_wrapListenerBlock_9vhxqi(_ListenerTrampoline_32 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDINotification * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_32)(void * waiter, struct MIDINotification * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_32 _NutrientIOSBindings_wrapBlockingBlock_9vhxqi(
    _BlockingTrampoline_32 block, _BlockingTrampoline_32 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDINotification * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_33)(struct MIDIPacketList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _NutrientIOSBindings_wrapListenerBlock_1pb1iof(_ListenerTrampoline_33 block) NS_RETURNS_RETAINED {
  return ^void(struct MIDIPacketList * arg0, void * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_33)(void * waiter, struct MIDIPacketList * arg0, void * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_33 _NutrientIOSBindings_wrapBlockingBlock_1pb1iof(
    _BlockingTrampoline_33 block, _BlockingTrampoline_33 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct MIDIPacketList * arg0, void * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_34)(id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _NutrientIOSBindings_wrapListenerBlock_1p9ui4q(_ListenerTrampoline_34 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, unsigned long arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_34)(void * waiter, id arg0, unsigned long arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_34 _NutrientIOSBindings_wrapBlockingBlock_1p9ui4q(
    _BlockingTrampoline_34 block, _BlockingTrampoline_34 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, unsigned long arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_35)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _NutrientIOSBindings_wrapListenerBlock_r8gdi7(_ListenerTrampoline_35 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_35)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_35 _NutrientIOSBindings_wrapBlockingBlock_r8gdi7(
    _BlockingTrampoline_35 block, _BlockingTrampoline_35 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_36)(id arg0, long arg1, struct CGRect arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _NutrientIOSBindings_wrapListenerBlock_11l3kq6(_ListenerTrampoline_36 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, long arg1, struct CGRect arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_36)(void * waiter, id arg0, long arg1, struct CGRect arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_36 _NutrientIOSBindings_wrapBlockingBlock_11l3kq6(
    _BlockingTrampoline_36 block, _BlockingTrampoline_36 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, long arg1, struct CGRect arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_37)(id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _NutrientIOSBindings_wrapListenerBlock_1a22wz(_ListenerTrampoline_37 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_37)(void * waiter, id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_37 _NutrientIOSBindings_wrapBlockingBlock_1a22wz(
    _BlockingTrampoline_37 block, _BlockingTrampoline_37 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_38)(long arg0, struct AUParameterAutomationEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _NutrientIOSBindings_wrapListenerBlock_bqkezo(_ListenerTrampoline_38 block) NS_RETURNS_RETAINED {
  return ^void(long arg0, struct AUParameterAutomationEvent * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_38)(void * waiter, long arg0, struct AUParameterAutomationEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_38 _NutrientIOSBindings_wrapBlockingBlock_bqkezo(
    _BlockingTrampoline_38 block, _BlockingTrampoline_38 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(long arg0, struct AUParameterAutomationEvent * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_39)(long arg0, struct AURecordedParameterEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _NutrientIOSBindings_wrapListenerBlock_6up75b(_ListenerTrampoline_39 block) NS_RETURNS_RETAINED {
  return ^void(long arg0, struct AURecordedParameterEvent * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_39)(void * waiter, long arg0, struct AURecordedParameterEvent * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_39 _NutrientIOSBindings_wrapBlockingBlock_6up75b(
    _BlockingTrampoline_39 block, _BlockingTrampoline_39 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(long arg0, struct AURecordedParameterEvent * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_40)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _NutrientIOSBindings_wrapListenerBlock_1b3bb6a(_ListenerTrampoline_40 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_40)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_40 _NutrientIOSBindings_wrapBlockingBlock_1b3bb6a(
    _BlockingTrampoline_40 block, _BlockingTrampoline_40 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_41)(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _NutrientIOSBindings_wrapListenerBlock_lmc3p5(_ListenerTrampoline_41 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_41)(void * waiter, id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_41 _NutrientIOSBindings_wrapBlockingBlock_lmc3p5(
    _BlockingTrampoline_41 block, _BlockingTrampoline_41 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, struct _NSRange arg2, BOOL * arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_42)(id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _NutrientIOSBindings_wrapListenerBlock_6jvo9y(_ListenerTrampoline_42 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_42)(void * waiter, id arg0, NSMatchingFlags arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_42 _NutrientIOSBindings_wrapBlockingBlock_6jvo9y(
    _BlockingTrampoline_42 block, _BlockingTrampoline_42 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, NSMatchingFlags arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_43)(unsigned long arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _NutrientIOSBindings_wrapListenerBlock_101dho9(_ListenerTrampoline_43 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, double arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_43)(void * waiter, unsigned long arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_43 _NutrientIOSBindings_wrapBlockingBlock_101dho9(
    _BlockingTrampoline_43 block, _BlockingTrampoline_43 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, double arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_44)(unsigned long arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _NutrientIOSBindings_wrapListenerBlock_bfp043(_ListenerTrampoline_44 block) NS_RETURNS_RETAINED {
  return ^void(unsigned long arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_44)(void * waiter, unsigned long arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_44 _NutrientIOSBindings_wrapBlockingBlock_bfp043(
    _BlockingTrampoline_44 block, _BlockingTrampoline_44 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(unsigned long arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_45)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _NutrientIOSBindings_wrapListenerBlock_o762yo(_ListenerTrampoline_45 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  };
}

typedef void  (^_BlockingTrampoline_45)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_45 _NutrientIOSBindings_wrapBlockingBlock_o762yo(
    _BlockingTrampoline_45 block, _BlockingTrampoline_45 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), objc_retainBlock(arg1));
  });
}

typedef void  (^_ListenerTrampoline_46)(NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _NutrientIOSBindings_wrapListenerBlock_n8yd09(_ListenerTrampoline_46 block) NS_RETURNS_RETAINED {
  return ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_46)(void * waiter, NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_46 _NutrientIOSBindings_wrapBlockingBlock_n8yd09(
    _BlockingTrampoline_46 block, _BlockingTrampoline_46 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_47)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _NutrientIOSBindings_wrapListenerBlock_rnu2c5(_ListenerTrampoline_47 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_47)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_47 _NutrientIOSBindings_wrapBlockingBlock_rnu2c5(
    _BlockingTrampoline_47 block, _BlockingTrampoline_47 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_48)(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _NutrientIOSBindings_wrapListenerBlock_np5chy(_ListenerTrampoline_48 block) NS_RETURNS_RETAINED {
  return ^void(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  };
}

typedef void  (^_BlockingTrampoline_48)(void * waiter, PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_48 _NutrientIOSBindings_wrapBlockingBlock_np5chy(
    _BlockingTrampoline_48 block, _BlockingTrampoline_48 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(PSPDFLogLevel arg0, char * arg1, id arg2, char * arg3, char * arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, objc_retainBlock(arg2), arg3, arg4, arg5);
  });
}

typedef void  (^_ListenerTrampoline_49)(struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _NutrientIOSBindings_wrapListenerBlock_gwxhxt(_ListenerTrampoline_49 block) NS_RETURNS_RETAINED {
  return ^void(struct __SecTrust * arg0, SecTrustResultType arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_49)(void * waiter, struct __SecTrust * arg0, SecTrustResultType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_49 _NutrientIOSBindings_wrapBlockingBlock_gwxhxt(
    _BlockingTrampoline_49 block, _BlockingTrampoline_49 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct __SecTrust * arg0, SecTrustResultType arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_50)(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _NutrientIOSBindings_wrapListenerBlock_k73ff5(_ListenerTrampoline_50 block) NS_RETURNS_RETAINED {
  return ^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_50)(void * waiter, struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_50 _NutrientIOSBindings_wrapBlockingBlock_k73ff5(
    _BlockingTrampoline_50 block, _BlockingTrampoline_50 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(struct __SecTrust * arg0, BOOL arg1, struct __CFError * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_51)(id arg0, id arg1, struct objc_selector * arg2, UIControlEvents arg3, BOOL * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _NutrientIOSBindings_wrapListenerBlock_1cxqo1i(_ListenerTrampoline_51 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, struct objc_selector * arg2, UIControlEvents arg3, BOOL * arg4) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_51)(void * waiter, id arg0, id arg1, struct objc_selector * arg2, UIControlEvents arg3, BOOL * arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_51 _NutrientIOSBindings_wrapBlockingBlock_1cxqo1i(
    _BlockingTrampoline_51 block, _BlockingTrampoline_51 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, struct objc_selector * arg2, UIControlEvents arg3, BOOL * arg4), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^_ListenerTrampoline_52)(id arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _NutrientIOSBindings_wrapListenerBlock_6p7ndb(_ListenerTrampoline_52 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^_BlockingTrampoline_52)(void * waiter, id arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_52 _NutrientIOSBindings_wrapBlockingBlock_6p7ndb(
    _BlockingTrampoline_52 block, _BlockingTrampoline_52 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^_ListenerTrampoline_53)(id arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _NutrientIOSBindings_wrapListenerBlock_13x5jor(_ListenerTrampoline_53 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_53)(void * waiter, id arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_53 _NutrientIOSBindings_wrapBlockingBlock_13x5jor(
    _BlockingTrampoline_53 block, _BlockingTrampoline_53 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ListenerTrampoline_54)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _NutrientIOSBindings_wrapListenerBlock_18qun1e(_ListenerTrampoline_54 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  };
}

typedef void  (^_BlockingTrampoline_54)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_54 _NutrientIOSBindings_wrapBlockingBlock_18qun1e(
    _BlockingTrampoline_54 block, _BlockingTrampoline_54 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  });
}

typedef void  (^_ListenerTrampoline_55)(id arg0, id arg1, unsigned long arg2, struct CGSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _NutrientIOSBindings_wrapListenerBlock_14lvnm2(_ListenerTrampoline_55 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, unsigned long arg2, struct CGSize arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_55)(void * waiter, id arg0, id arg1, unsigned long arg2, struct CGSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_55 _NutrientIOSBindings_wrapBlockingBlock_14lvnm2(
    _BlockingTrampoline_55 block, _BlockingTrampoline_55 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, unsigned long arg2, struct CGSize arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_56)(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _NutrientIOSBindings_wrapListenerBlock_17t6k8t(_ListenerTrampoline_56 block) NS_RETURNS_RETAINED {
  return ^void(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_56)(void * waiter, uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_56 _NutrientIOSBindings_wrapBlockingBlock_17t6k8t(
    _BlockingTrampoline_56 block, _BlockingTrampoline_56 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(uint8_t arg0, uint8_t arg1, id arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ListenerTrampoline_57)(BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _NutrientIOSBindings_wrapListenerBlock_1s56lr9(_ListenerTrampoline_57 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_57)(void * waiter, BOOL arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_57 _NutrientIOSBindings_wrapBlockingBlock_1s56lr9(
    _BlockingTrampoline_57 block, _BlockingTrampoline_57 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_58)(BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _NutrientIOSBindings_wrapListenerBlock_hk7n97(_ListenerTrampoline_58 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_58)(void * waiter, BOOL arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_58 _NutrientIOSBindings_wrapBlockingBlock_hk7n97(
    _BlockingTrampoline_58 block, _BlockingTrampoline_58 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ListenerTrampoline_59)(BOOL arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _NutrientIOSBindings_wrapListenerBlock_n4nbpt(_ListenerTrampoline_59 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_59)(void * waiter, BOOL arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_59 _NutrientIOSBindings_wrapBlockingBlock_n4nbpt(
    _BlockingTrampoline_59 block, _BlockingTrampoline_59 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ListenerTrampoline_60)(BOOL arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _NutrientIOSBindings_wrapListenerBlock_14iqu8t(_ListenerTrampoline_60 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, BOOL arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_60)(void * waiter, BOOL arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_60 _NutrientIOSBindings_wrapBlockingBlock_14iqu8t(
    _BlockingTrampoline_60 block, _BlockingTrampoline_60 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, BOOL arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ListenerTrampoline_61)(BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _NutrientIOSBindings_wrapListenerBlock_og5b6y(_ListenerTrampoline_61 block) NS_RETURNS_RETAINED {
  return ^void(BOOL arg0, id arg1, int arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_61)(void * waiter, BOOL arg0, id arg1, int arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_61 _NutrientIOSBindings_wrapBlockingBlock_og5b6y(
    _BlockingTrampoline_61 block, _BlockingTrampoline_61 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(BOOL arg0, id arg1, int arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ListenerTrampoline_62)(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _NutrientIOSBindings_wrapListenerBlock_11z9wy5(_ListenerTrampoline_62 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_62)(void * waiter, id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_62 _NutrientIOSBindings_wrapBlockingBlock_11z9wy5(
    _BlockingTrampoline_62 block, _BlockingTrampoline_62 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, uint16_t arg1, unsigned char  arg2[6], unsigned char  arg3[6]), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_63)(id arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _NutrientIOSBindings_wrapListenerBlock_1lhy15d(_ListenerTrampoline_63 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_63)(void * waiter, id arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_63 _NutrientIOSBindings_wrapBlockingBlock_1lhy15d(
    _BlockingTrampoline_63 block, _BlockingTrampoline_63 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ListenerTrampoline_64)(id arg0, id arg1, BOOL arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _NutrientIOSBindings_wrapListenerBlock_pppu4n(_ListenerTrampoline_64 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, BOOL arg2, id arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_64)(void * waiter, id arg0, id arg1, BOOL arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_64 _NutrientIOSBindings_wrapBlockingBlock_pppu4n(
    _BlockingTrampoline_64 block, _BlockingTrampoline_64 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, BOOL arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ListenerTrampoline_65)(char * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _NutrientIOSBindings_wrapListenerBlock_1r7ue5f(_ListenerTrampoline_65 block) NS_RETURNS_RETAINED {
  return ^void(char * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_65)(void * waiter, char * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_65 _NutrientIOSBindings_wrapBlockingBlock_1r7ue5f(
    _BlockingTrampoline_65 block, _BlockingTrampoline_65 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(char * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ListenerTrampoline_66)(size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_66 _NutrientIOSBindings_wrapListenerBlock_11t2oft(_ListenerTrampoline_66 block) NS_RETURNS_RETAINED {
  return ^void(size_t arg0, struct CGImage * arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_66)(void * waiter, size_t arg0, struct CGImage * arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_66 _NutrientIOSBindings_wrapBlockingBlock_11t2oft(
    _BlockingTrampoline_66 block, _BlockingTrampoline_66 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(size_t arg0, struct CGImage * arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_67)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_67 _NutrientIOSBindings_wrapListenerBlock_ovsamd(_ListenerTrampoline_67 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^_BlockingTrampoline_67)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_67 _NutrientIOSBindings_wrapBlockingBlock_ovsamd(
    _BlockingTrampoline_67 block, _BlockingTrampoline_67 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^_ProtocolTrampoline_123)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((_ProtocolTrampoline_123)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^_ListenerTrampoline_68)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_68 _NutrientIOSBindings_wrapListenerBlock_f167m6(_ListenerTrampoline_68 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0));
  };
}

typedef void  (^_BlockingTrampoline_68)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_68 _NutrientIOSBindings_wrapBlockingBlock_f167m6(
    _BlockingTrampoline_68 block, _BlockingTrampoline_68 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0));
  });
}

typedef void  (^_ListenerTrampoline_69)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_69 _NutrientIOSBindings_wrapListenerBlock_fjrv01(_ListenerTrampoline_69 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_69)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_69 _NutrientIOSBindings_wrapBlockingBlock_fjrv01(
    _BlockingTrampoline_69 block, _BlockingTrampoline_69 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ProtocolTrampoline_124)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_fjrv01(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_124)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_70)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_70 _NutrientIOSBindings_wrapListenerBlock_1tz5yf(_ListenerTrampoline_70 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_70)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_70 _NutrientIOSBindings_wrapBlockingBlock_1tz5yf(
    _BlockingTrampoline_70 block, _BlockingTrampoline_70 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_125)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1tz5yf(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_125)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_71)(void * arg0, id arg1, struct _NSRange arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_71 _NutrientIOSBindings_wrapListenerBlock_laniev(_ListenerTrampoline_71 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct _NSRange arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_71)(void * waiter, void * arg0, id arg1, struct _NSRange arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_71 _NutrientIOSBindings_wrapBlockingBlock_laniev(
    _BlockingTrampoline_71 block, _BlockingTrampoline_71 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct _NSRange arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_126)(void * sel, id arg1, struct _NSRange arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_laniev(id target, void * sel, id arg1, struct _NSRange arg2, id arg3) {
  return ((_ProtocolTrampoline_126)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_72)(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_72 _NutrientIOSBindings_wrapListenerBlock_1m1m78d(_ListenerTrampoline_72 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_72)(void * waiter, void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_72 _NutrientIOSBindings_wrapBlockingBlock_1m1m78d(
    _BlockingTrampoline_72 block, _BlockingTrampoline_72 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct AudioUnitEvent * arg1, unsigned long long arg2, float arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^_ListenerTrampoline_73)(void * arg0, struct AudioUnitParameter * arg1, float arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_73 _NutrientIOSBindings_wrapListenerBlock_1e9x4g1(_ListenerTrampoline_73 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct AudioUnitParameter * arg1, float arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_73)(void * waiter, void * arg0, struct AudioUnitParameter * arg1, float arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_73 _NutrientIOSBindings_wrapBlockingBlock_1e9x4g1(
    _BlockingTrampoline_73 block, _BlockingTrampoline_73 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct AudioUnitParameter * arg1, float arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ListenerTrampoline_74)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_74 _NutrientIOSBindings_wrapListenerBlock_18v1jvf(_ListenerTrampoline_74 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^_BlockingTrampoline_74)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_74 _NutrientIOSBindings_wrapBlockingBlock_18v1jvf(
    _BlockingTrampoline_74 block, _BlockingTrampoline_74 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^_ProtocolTrampoline_127)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_127)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_75)(void * arg0, id arg1, struct CGContext * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_75 _NutrientIOSBindings_wrapListenerBlock_qvcerx(_ListenerTrampoline_75 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct CGContext * arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_75)(void * waiter, void * arg0, id arg1, struct CGContext * arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_75 _NutrientIOSBindings_wrapBlockingBlock_qvcerx(
    _BlockingTrampoline_75 block, _BlockingTrampoline_75 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct CGContext * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_128)(void * sel, id arg1, struct CGContext * arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_qvcerx(id target, void * sel, id arg1, struct CGContext * arg2) {
  return ((_ProtocolTrampoline_128)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_76)(void * arg0, struct CGAffineTransform arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_76 _NutrientIOSBindings_wrapListenerBlock_1lznlw3(_ListenerTrampoline_76 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct CGAffineTransform arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_76)(void * waiter, void * arg0, struct CGAffineTransform arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_76 _NutrientIOSBindings_wrapBlockingBlock_1lznlw3(
    _BlockingTrampoline_76 block, _BlockingTrampoline_76 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct CGAffineTransform arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_129)(void * sel, struct CGAffineTransform arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1lznlw3(id target, void * sel, struct CGAffineTransform arg1) {
  return ((_ProtocolTrampoline_129)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_77)(void * arg0, struct CGContext * arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_77 _NutrientIOSBindings_wrapListenerBlock_1fvj1hi(_ListenerTrampoline_77 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct CGContext * arg1, struct CGRect arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_77)(void * waiter, void * arg0, struct CGContext * arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_77 _NutrientIOSBindings_wrapBlockingBlock_1fvj1hi(
    _BlockingTrampoline_77 block, _BlockingTrampoline_77 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct CGContext * arg1, struct CGRect arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_130)(void * sel, struct CGContext * arg1, struct CGRect arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1fvj1hi(id target, void * sel, struct CGContext * arg1, struct CGRect arg2, id arg3) {
  return ((_ProtocolTrampoline_130)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_78)(void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_78 _NutrientIOSBindings_wrapListenerBlock_18sfmo2(_ListenerTrampoline_78 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, double arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_78)(void * waiter, void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_78 _NutrientIOSBindings_wrapBlockingBlock_18sfmo2(
    _BlockingTrampoline_78 block, _BlockingTrampoline_78 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, double arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_131)(void * sel, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_18sfmo2(id target, void * sel, double arg1) {
  return ((_ProtocolTrampoline_131)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_79)(void * arg0, struct CGPoint arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_79 _NutrientIOSBindings_wrapListenerBlock_1bktu2(_ListenerTrampoline_79 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct CGPoint arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_79)(void * waiter, void * arg0, struct CGPoint arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_79 _NutrientIOSBindings_wrapBlockingBlock_1bktu2(
    _BlockingTrampoline_79 block, _BlockingTrampoline_79 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct CGPoint arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_132)(void * sel, struct CGPoint arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1bktu2(id target, void * sel, struct CGPoint arg1) {
  return ((_ProtocolTrampoline_132)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_80)(void * arg0, struct CGRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_80 _NutrientIOSBindings_wrapListenerBlock_1e49sma(_ListenerTrampoline_80 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct CGRect arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_80)(void * waiter, void * arg0, struct CGRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_80 _NutrientIOSBindings_wrapBlockingBlock_1e49sma(
    _BlockingTrampoline_80 block, _BlockingTrampoline_80 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct CGRect arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_133)(void * sel, struct CGRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1e49sma(id target, void * sel, struct CGRect arg1) {
  return ((_ProtocolTrampoline_133)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_81)(void * arg0, struct CGSize arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_81 _NutrientIOSBindings_wrapListenerBlock_1rn6eap(_ListenerTrampoline_81 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct CGSize arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^_BlockingTrampoline_81)(void * waiter, void * arg0, struct CGSize arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_81 _NutrientIOSBindings_wrapBlockingBlock_1rn6eap(
    _BlockingTrampoline_81 block, _BlockingTrampoline_81 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct CGSize arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^_ProtocolTrampoline_134)(void * sel, struct CGSize arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1rn6eap(id target, void * sel, struct CGSize arg1, id arg2) {
  return ((_ProtocolTrampoline_134)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_82)(void * arg0, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_82 _NutrientIOSBindings_wrapListenerBlock_1sf11wt(_ListenerTrampoline_82 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct opaqueCMSampleBuffer * arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_82)(void * waiter, void * arg0, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_82 _NutrientIOSBindings_wrapBlockingBlock_1sf11wt(
    _BlockingTrampoline_82 block, _BlockingTrampoline_82 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct opaqueCMSampleBuffer * arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_135)(void * sel, struct opaqueCMSampleBuffer * arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1sf11wt(id target, void * sel, struct opaqueCMSampleBuffer * arg1) {
  return ((_ProtocolTrampoline_135)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_83)(void * arg0, id arg1, MFMailComposeResult arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_83 _NutrientIOSBindings_wrapListenerBlock_1j8lbdc(_ListenerTrampoline_83 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MFMailComposeResult arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_83)(void * waiter, void * arg0, id arg1, MFMailComposeResult arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_83 _NutrientIOSBindings_wrapBlockingBlock_1j8lbdc(
    _BlockingTrampoline_83 block, _BlockingTrampoline_83 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MFMailComposeResult arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_136)(void * sel, id arg1, MFMailComposeResult arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1j8lbdc(id target, void * sel, id arg1, MFMailComposeResult arg2, id arg3) {
  return ((_ProtocolTrampoline_136)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_84)(void * arg0, id arg1, MessageComposeResult arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_84 _NutrientIOSBindings_wrapListenerBlock_1cj720j(_ListenerTrampoline_84 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MessageComposeResult arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_84)(void * waiter, void * arg0, id arg1, MessageComposeResult arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_84 _NutrientIOSBindings_wrapBlockingBlock_1cj720j(
    _BlockingTrampoline_84 block, _BlockingTrampoline_84 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MessageComposeResult arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_137)(void * sel, id arg1, MessageComposeResult arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1cj720j(id target, void * sel, id arg1, MessageComposeResult arg2) {
  return ((_ProtocolTrampoline_137)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_85)(void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_85 _NutrientIOSBindings_wrapListenerBlock_zzthnb(_ListenerTrampoline_85 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_85)(void * waiter, void * arg0, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_85 _NutrientIOSBindings_wrapBlockingBlock_zzthnb(
    _BlockingTrampoline_85 block, _BlockingTrampoline_85 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_138)(void * sel, id arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_zzthnb(id target, void * sel, id arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_138)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_86)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_86 _NutrientIOSBindings_wrapListenerBlock_jk1ljc(_ListenerTrampoline_86 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  };
}

typedef void  (^_BlockingTrampoline_86)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_86 _NutrientIOSBindings_wrapBlockingBlock_jk1ljc(
    _BlockingTrampoline_86 block, _BlockingTrampoline_86 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  });
}

typedef void  (^_ProtocolTrampoline_139)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_jk1ljc(id target, void * sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_139)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_87)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_87 _NutrientIOSBindings_wrapListenerBlock_bklti2(_ListenerTrampoline_87 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  };
}

typedef void  (^_BlockingTrampoline_87)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_87 _NutrientIOSBindings_wrapBlockingBlock_bklti2(
    _BlockingTrampoline_87 block, _BlockingTrampoline_87 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_140)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_bklti2(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_140)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_88)(void * arg0, id arg1, id arg2, id arg3, BOOL arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_88 _NutrientIOSBindings_wrapListenerBlock_494ibn(_ListenerTrampoline_88 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, BOOL arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^_BlockingTrampoline_88)(void * waiter, void * arg0, id arg1, id arg2, id arg3, BOOL arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_88 _NutrientIOSBindings_wrapBlockingBlock_494ibn(
    _BlockingTrampoline_88 block, _BlockingTrampoline_88 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, BOOL arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^_ProtocolTrampoline_141)(void * sel, id arg1, id arg2, id arg3, BOOL arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_494ibn(id target, void * sel, id arg1, id arg2, id arg3, BOOL arg4) {
  return ((_ProtocolTrampoline_141)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_89)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_89 _NutrientIOSBindings_wrapListenerBlock_zuf90e(_ListenerTrampoline_89 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_89)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_89 _NutrientIOSBindings_wrapBlockingBlock_zuf90e(
    _BlockingTrampoline_89 block, _BlockingTrampoline_89 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_142)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_zuf90e(id target, void * sel, unsigned long arg1) {
  return ((_ProtocolTrampoline_142)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_90)(void * arg0, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_90 _NutrientIOSBindings_wrapListenerBlock_rv6ady(_ListenerTrampoline_90 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, objc_retainBlock(arg6));
  };
}

typedef void  (^_BlockingTrampoline_90)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_90 _NutrientIOSBindings_wrapBlockingBlock_rv6ady(
    _BlockingTrampoline_90 block, _BlockingTrampoline_90 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, objc_retainBlock(arg6));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, objc_retainBlock(arg6));
  });
}

typedef void  (^_ProtocolTrampoline_143)(void * sel, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_rv6ady(id target, void * sel, id arg1, id arg2, id arg3, id arg4, BOOL arg5, id arg6) {
  return ((_ProtocolTrampoline_143)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^_ListenerTrampoline_91)(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_91 _NutrientIOSBindings_wrapListenerBlock_m09tr7(_ListenerTrampoline_91 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), (__bridge id)(__bridge_retained void*)(arg5));
  };
}

typedef void  (^_BlockingTrampoline_91)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_91 _NutrientIOSBindings_wrapBlockingBlock_m09tr7(
    _BlockingTrampoline_91 block, _BlockingTrampoline_91 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), (__bridge id)(__bridge_retained void*)(arg5));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), (__bridge id)(__bridge_retained void*)(arg5));
  });
}

typedef void  (^_ProtocolTrampoline_144)(void * sel, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_m09tr7(id target, void * sel, id arg1, id arg2, id arg3, id arg4, id arg5) {
  return ((_ProtocolTrampoline_144)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^_ListenerTrampoline_92)(void * arg0, id arg1, BOOL arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_92 _NutrientIOSBindings_wrapListenerBlock_1hjmvoz(_ListenerTrampoline_92 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, BOOL arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_92)(void * waiter, void * arg0, id arg1, BOOL arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_92 _NutrientIOSBindings_wrapBlockingBlock_1hjmvoz(
    _BlockingTrampoline_92 block, _BlockingTrampoline_92 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, BOOL arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_145)(void * sel, id arg1, BOOL arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1hjmvoz(id target, void * sel, id arg1, BOOL arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_145)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_93)(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_93 _NutrientIOSBindings_wrapListenerBlock_gw0ghs(_ListenerTrampoline_93 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_93)(void * waiter, void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_93 _NutrientIOSBindings_wrapBlockingBlock_gw0ghs(
    _BlockingTrampoline_93 block, _BlockingTrampoline_93 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFAnnotationZIndexMove arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_146)(void * sel, id arg1, PSPDFAnnotationZIndexMove arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_gw0ghs(id target, void * sel, id arg1, PSPDFAnnotationZIndexMove arg2) {
  return ((_ProtocolTrampoline_146)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_94)(void * arg0, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_94 _NutrientIOSBindings_wrapListenerBlock_8acz2h(_ListenerTrampoline_94 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_94)(void * waiter, void * arg0, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_94 _NutrientIOSBindings_wrapBlockingBlock_8acz2h(
    _BlockingTrampoline_94 block, _BlockingTrampoline_94 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_147)(void * sel, id arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_8acz2h(id target, void * sel, id arg1, id arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_147)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_95)(void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_95 _NutrientIOSBindings_wrapListenerBlock_wy9lus(_ListenerTrampoline_95 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_95)(void * waiter, void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_95 _NutrientIOSBindings_wrapBlockingBlock_wy9lus(
    _BlockingTrampoline_95 block, _BlockingTrampoline_95 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_148)(void * sel, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_wy9lus(id target, void * sel, id arg1, unsigned long arg2) {
  return ((_ProtocolTrampoline_148)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_96)(void * arg0, PSPDFControllerState arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_96 _NutrientIOSBindings_wrapListenerBlock_1lom84x(_ListenerTrampoline_96 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFControllerState arg1, id arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_96)(void * waiter, void * arg0, PSPDFControllerState arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_96 _NutrientIOSBindings_wrapBlockingBlock_1lom84x(
    _BlockingTrampoline_96 block, _BlockingTrampoline_96 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFControllerState arg1, id arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_149)(void * sel, PSPDFControllerState arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1lom84x(id target, void * sel, PSPDFControllerState arg1, id arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_149)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_97)(void * arg0, id arg1, id arg2, unsigned long arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_97 _NutrientIOSBindings_wrapListenerBlock_ew6byw(_ListenerTrampoline_97 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, unsigned long arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4));
  };
}

typedef void  (^_BlockingTrampoline_97)(void * waiter, void * arg0, id arg1, id arg2, unsigned long arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_97 _NutrientIOSBindings_wrapBlockingBlock_ew6byw(
    _BlockingTrampoline_97 block, _BlockingTrampoline_97 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, unsigned long arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4));
  });
}

typedef void  (^_ProtocolTrampoline_150)(void * sel, id arg1, id arg2, unsigned long arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_ew6byw(id target, void * sel, id arg1, id arg2, unsigned long arg3, id arg4) {
  return ((_ProtocolTrampoline_150)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_98)(void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_98 _NutrientIOSBindings_wrapListenerBlock_ve6f9k(_ListenerTrampoline_98 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, double arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_98)(void * waiter, void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_98 _NutrientIOSBindings_wrapBlockingBlock_ve6f9k(
    _BlockingTrampoline_98 block, _BlockingTrampoline_98 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, double arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_151)(void * sel, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_ve6f9k(id target, void * sel, id arg1, double arg2) {
  return ((_ProtocolTrampoline_151)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_99)(void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_99 _NutrientIOSBindings_wrapListenerBlock_8jfq1p(_ListenerTrampoline_99 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  };
}

typedef void  (^_BlockingTrampoline_99)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_99 _NutrientIOSBindings_wrapBlockingBlock_8jfq1p(
    _BlockingTrampoline_99 block, _BlockingTrampoline_99 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  });
}

typedef void  (^_ProtocolTrampoline_152)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_8jfq1p(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_152)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_100)(void * arg0, id arg1, PSPDFDocumentSharingStep arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_100 _NutrientIOSBindings_wrapListenerBlock_gf1af3(_ListenerTrampoline_100 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFDocumentSharingStep arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_100)(void * waiter, void * arg0, id arg1, PSPDFDocumentSharingStep arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_100 _NutrientIOSBindings_wrapBlockingBlock_gf1af3(
    _BlockingTrampoline_100 block, _BlockingTrampoline_100 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFDocumentSharingStep arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_153)(void * sel, id arg1, PSPDFDocumentSharingStep arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_gf1af3(id target, void * sel, id arg1, PSPDFDocumentSharingStep arg2, id arg3) {
  return ((_ProtocolTrampoline_153)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_101)(void * arg0, id arg1, double arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_101 _NutrientIOSBindings_wrapListenerBlock_17oxmfy(_ListenerTrampoline_101 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, double arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_101)(void * waiter, void * arg0, id arg1, double arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_101 _NutrientIOSBindings_wrapBlockingBlock_17oxmfy(
    _BlockingTrampoline_101 block, _BlockingTrampoline_101 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, double arg2, long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_154)(void * sel, id arg1, double arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_17oxmfy(id target, void * sel, id arg1, double arg2, long arg3) {
  return ((_ProtocolTrampoline_154)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_102)(void * arg0, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_102 _NutrientIOSBindings_wrapListenerBlock_1wp3it5(_ListenerTrampoline_102 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, long arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_102)(void * waiter, void * arg0, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_102 _NutrientIOSBindings_wrapBlockingBlock_1wp3it5(
    _BlockingTrampoline_102 block, _BlockingTrampoline_102 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_155)(void * sel, id arg1, long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1wp3it5(id target, void * sel, id arg1, long arg2) {
  return ((_ProtocolTrampoline_155)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_103)(void * arg0, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_103 _NutrientIOSBindings_wrapListenerBlock_e6jln7(_ListenerTrampoline_103 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_103)(void * waiter, void * arg0, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_103 _NutrientIOSBindings_wrapBlockingBlock_e6jln7(
    _BlockingTrampoline_103 block, _BlockingTrampoline_103 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_156)(void * sel, id arg1, id arg2, long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_e6jln7(id target, void * sel, id arg1, id arg2, long arg3) {
  return ((_ProtocolTrampoline_156)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_104)(void * arg0, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_104 _NutrientIOSBindings_wrapListenerBlock_171mqxe(_ListenerTrampoline_104 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_104)(void * waiter, void * arg0, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_104 _NutrientIOSBindings_wrapBlockingBlock_171mqxe(
    _BlockingTrampoline_104 block, _BlockingTrampoline_104 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^_ProtocolTrampoline_157)(void * sel, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_171mqxe(id target, void * sel, id arg1, PSPDFSearchResultScope arg2, struct _NSRange arg3, unsigned long arg4) {
  return ((_ProtocolTrampoline_157)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_105)(void * arg0, id arg1, PSPDFReachability arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_105 _NutrientIOSBindings_wrapListenerBlock_1802r7j(_ListenerTrampoline_105 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFReachability arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_105)(void * waiter, void * arg0, id arg1, PSPDFReachability arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_105 _NutrientIOSBindings_wrapBlockingBlock_1802r7j(
    _BlockingTrampoline_105 block, _BlockingTrampoline_105 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFReachability arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_158)(void * sel, id arg1, PSPDFReachability arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1802r7j(id target, void * sel, id arg1, PSPDFReachability arg2) {
  return ((_ProtocolTrampoline_158)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_106)(void * arg0, id arg1, PSPDFDrawViewInputMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_106 _NutrientIOSBindings_wrapListenerBlock_rf5s1g(_ListenerTrampoline_106 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFDrawViewInputMode arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_106)(void * waiter, void * arg0, id arg1, PSPDFDrawViewInputMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_106 _NutrientIOSBindings_wrapBlockingBlock_rf5s1g(
    _BlockingTrampoline_106 block, _BlockingTrampoline_106 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFDrawViewInputMode arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_159)(void * sel, id arg1, PSPDFDrawViewInputMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_rf5s1g(id target, void * sel, id arg1, PSPDFDrawViewInputMode arg2) {
  return ((_ProtocolTrampoline_159)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_107)(void * arg0, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_107 _NutrientIOSBindings_wrapListenerBlock_wnetd4(_ListenerTrampoline_107 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_107)(void * waiter, void * arg0, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_107 _NutrientIOSBindings_wrapBlockingBlock_wnetd4(
    _BlockingTrampoline_107 block, _BlockingTrampoline_107 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_160)(void * sel, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_wnetd4(id target, void * sel, id arg1, PSPDFDrawViewInputMode arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_160)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_108)(void * arg0, id arg1, PSPDFFlexibleToolbarPosition arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_108 _NutrientIOSBindings_wrapListenerBlock_104z541(_ListenerTrampoline_108 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFFlexibleToolbarPosition arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_108)(void * waiter, void * arg0, id arg1, PSPDFFlexibleToolbarPosition arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_108 _NutrientIOSBindings_wrapBlockingBlock_104z541(
    _BlockingTrampoline_108 block, _BlockingTrampoline_108 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFFlexibleToolbarPosition arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_161)(void * sel, id arg1, PSPDFFlexibleToolbarPosition arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_104z541(id target, void * sel, id arg1, PSPDFFlexibleToolbarPosition arg2) {
  return ((_ProtocolTrampoline_161)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_109)(void * arg0, PSPDFKnobType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_109 _NutrientIOSBindings_wrapListenerBlock_1wu8oyo(_ListenerTrampoline_109 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFKnobType arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_109)(void * waiter, void * arg0, PSPDFKnobType arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_109 _NutrientIOSBindings_wrapBlockingBlock_1wu8oyo(
    _BlockingTrampoline_109 block, _BlockingTrampoline_109 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFKnobType arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_162)(void * sel, PSPDFKnobType arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1wu8oyo(id target, void * sel, PSPDFKnobType arg1) {
  return ((_ProtocolTrampoline_162)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_110)(void * arg0, id arg1, CMTime arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_110 _NutrientIOSBindings_wrapListenerBlock_128r5ck(_ListenerTrampoline_110 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, CMTime arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_110)(void * waiter, void * arg0, id arg1, CMTime arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_110 _NutrientIOSBindings_wrapBlockingBlock_128r5ck(
    _BlockingTrampoline_110 block, _BlockingTrampoline_110 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, CMTime arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_163)(void * sel, id arg1, CMTime arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_128r5ck(id target, void * sel, id arg1, CMTime arg2) {
  return ((_ProtocolTrampoline_163)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_111)(void * arg0, id arg1, PSPDFMediaPlayerControllerContentState arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_111 _NutrientIOSBindings_wrapListenerBlock_111uk8n(_ListenerTrampoline_111 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFMediaPlayerControllerContentState arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_111)(void * waiter, void * arg0, id arg1, PSPDFMediaPlayerControllerContentState arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_111 _NutrientIOSBindings_wrapBlockingBlock_111uk8n(
    _BlockingTrampoline_111 block, _BlockingTrampoline_111 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFMediaPlayerControllerContentState arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_164)(void * sel, id arg1, PSPDFMediaPlayerControllerContentState arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_111uk8n(id target, void * sel, id arg1, PSPDFMediaPlayerControllerContentState arg2) {
  return ((_ProtocolTrampoline_164)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_112)(void * arg0, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_112 _NutrientIOSBindings_wrapListenerBlock_2xx4dm(_ListenerTrampoline_112 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_112)(void * waiter, void * arg0, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_112 _NutrientIOSBindings_wrapBlockingBlock_2xx4dm(
    _BlockingTrampoline_112 block, _BlockingTrampoline_112 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_165)(void * sel, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_2xx4dm(id target, void * sel, id arg1, id arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_165)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_113)(void * arg0, unsigned long arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_113 _NutrientIOSBindings_wrapListenerBlock_lieacw(_ListenerTrampoline_113 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, id arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_113)(void * waiter, void * arg0, unsigned long arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_113 _NutrientIOSBindings_wrapBlockingBlock_lieacw(
    _BlockingTrampoline_113 block, _BlockingTrampoline_113 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, id arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_166)(void * sel, unsigned long arg1, id arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_lieacw(id target, void * sel, unsigned long arg1, id arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_166)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_114)(void * arg0, unsigned long arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_114 _NutrientIOSBindings_wrapListenerBlock_qoqyjy(_ListenerTrampoline_114 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_114)(void * waiter, void * arg0, unsigned long arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_114 _NutrientIOSBindings_wrapBlockingBlock_qoqyjy(
    _BlockingTrampoline_114 block, _BlockingTrampoline_114 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ProtocolTrampoline_167)(void * sel, unsigned long arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_qoqyjy(id target, void * sel, unsigned long arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_167)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_115)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_115 _NutrientIOSBindings_wrapListenerBlock_c2yeeh(_ListenerTrampoline_115 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_115)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_115 _NutrientIOSBindings_wrapBlockingBlock_c2yeeh(
    _BlockingTrampoline_115 block, _BlockingTrampoline_115 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_168)(void * sel, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_c2yeeh(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3) {
  return ((_ProtocolTrampoline_168)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_116)(void * arg0, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_116 _NutrientIOSBindings_wrapListenerBlock_16yqbmn(_ListenerTrampoline_116 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_116)(void * waiter, void * arg0, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_116 _NutrientIOSBindings_wrapBlockingBlock_16yqbmn(
    _BlockingTrampoline_116 block, _BlockingTrampoline_116 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_169)(void * sel, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_16yqbmn(id target, void * sel, id arg1, PSPDFResizableViewOuterKnob arg2, BOOL arg3) {
  return ((_ProtocolTrampoline_169)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_117)(void * arg0, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_117 _NutrientIOSBindings_wrapListenerBlock_m9e95d(_ListenerTrampoline_117 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^_BlockingTrampoline_117)(void * waiter, void * arg0, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_117 _NutrientIOSBindings_wrapBlockingBlock_m9e95d(
    _BlockingTrampoline_117 block, _BlockingTrampoline_117 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^_ProtocolTrampoline_170)(void * sel, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_m9e95d(id target, void * sel, PSPDFSearchStatus arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
  return ((_ProtocolTrampoline_170)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_118)(void * arg0, id arg1, struct CGRect arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_118 _NutrientIOSBindings_wrapListenerBlock_ustzvs(_ListenerTrampoline_118 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct CGRect arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_118)(void * waiter, void * arg0, id arg1, struct CGRect arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_118 _NutrientIOSBindings_wrapBlockingBlock_ustzvs(
    _BlockingTrampoline_118 block, _BlockingTrampoline_118 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct CGRect arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_171)(void * sel, id arg1, struct CGRect arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_ustzvs(id target, void * sel, id arg1, struct CGRect arg2) {
  return ((_ProtocolTrampoline_171)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_119)(void * arg0, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_119 _NutrientIOSBindings_wrapListenerBlock_1xbwpdm(_ListenerTrampoline_119 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  };
}

typedef void  (^_BlockingTrampoline_119)(void * waiter, void * arg0, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_119 _NutrientIOSBindings_wrapBlockingBlock_1xbwpdm(
    _BlockingTrampoline_119 block, _BlockingTrampoline_119 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  });
}

typedef void  (^_ProtocolTrampoline_172)(void * sel, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1xbwpdm(id target, void * sel, id arg1, id arg2, PSPDFSignatureHashAlgorithm arg3, id arg4) {
  return ((_ProtocolTrampoline_172)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_120)(void * arg0, PSPDFStatefulViewState arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_120 _NutrientIOSBindings_wrapListenerBlock_j32p5m(_ListenerTrampoline_120 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFStatefulViewState arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_120)(void * waiter, void * arg0, PSPDFStatefulViewState arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_120 _NutrientIOSBindings_wrapBlockingBlock_j32p5m(
    _BlockingTrampoline_120 block, _BlockingTrampoline_120 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFStatefulViewState arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_173)(void * sel, PSPDFStatefulViewState arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_j32p5m(id target, void * sel, PSPDFStatefulViewState arg1) {
  return ((_ProtocolTrampoline_173)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_121)(void * arg0, PSPDFStatefulViewState arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_121 _NutrientIOSBindings_wrapListenerBlock_pzjmfe(_ListenerTrampoline_121 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFStatefulViewState arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_121)(void * waiter, void * arg0, PSPDFStatefulViewState arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_121 _NutrientIOSBindings_wrapBlockingBlock_pzjmfe(
    _BlockingTrampoline_121 block, _BlockingTrampoline_121 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFStatefulViewState arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ProtocolTrampoline_174)(void * sel, PSPDFStatefulViewState arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_pzjmfe(id target, void * sel, PSPDFStatefulViewState arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_174)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_122)(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_122 _NutrientIOSBindings_wrapListenerBlock_1oxtwsg(_ListenerTrampoline_122 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^_BlockingTrampoline_122)(void * waiter, void * arg0, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_122 _NutrientIOSBindings_wrapBlockingBlock_1oxtwsg(
    _BlockingTrampoline_122 block, _BlockingTrampoline_122 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^_ProtocolTrampoline_175)(void * sel, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1oxtwsg(id target, void * sel, id arg1, id arg2, id arg3, unsigned long arg4) {
  return ((_ProtocolTrampoline_175)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_123)(void * arg0, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_123 _NutrientIOSBindings_wrapListenerBlock_vgp0rj(_ListenerTrampoline_123 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  };
}

typedef void  (^_BlockingTrampoline_123)(void * waiter, void * arg0, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_123 _NutrientIOSBindings_wrapBlockingBlock_vgp0rj(
    _BlockingTrampoline_123 block, _BlockingTrampoline_123 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  });
}

typedef void  (^_ProtocolTrampoline_176)(void * sel, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_vgp0rj(id target, void * sel, id arg1, id arg2, id arg3, BOOL arg4, BOOL arg5) {
  return ((_ProtocolTrampoline_176)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^_ListenerTrampoline_124)(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_124 _NutrientIOSBindings_wrapListenerBlock_5qyi04(_ListenerTrampoline_124 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^_BlockingTrampoline_124)(void * waiter, void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_124 _NutrientIOSBindings_wrapBlockingBlock_5qyi04(
    _BlockingTrampoline_124 block, _BlockingTrampoline_124 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^_ProtocolTrampoline_177)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_5qyi04(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4) {
  return ((_ProtocolTrampoline_177)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_125)(void * arg0, id arg1, unsigned long arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_125 _NutrientIOSBindings_wrapListenerBlock_vdw7q2(_ListenerTrampoline_125 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_125)(void * waiter, void * arg0, id arg1, unsigned long arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_125 _NutrientIOSBindings_wrapBlockingBlock_vdw7q2(
    _BlockingTrampoline_125 block, _BlockingTrampoline_125 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_178)(void * sel, id arg1, unsigned long arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_vdw7q2(id target, void * sel, id arg1, unsigned long arg2, id arg3) {
  return ((_ProtocolTrampoline_178)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_126)(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_126 _NutrientIOSBindings_wrapListenerBlock_1qa0tp6(_ListenerTrampoline_126 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5));
  };
}

typedef void  (^_BlockingTrampoline_126)(void * waiter, void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_126 _NutrientIOSBindings_wrapBlockingBlock_1qa0tp6(
    _BlockingTrampoline_126 block, _BlockingTrampoline_126 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5));
  });
}

typedef void  (^_ProtocolTrampoline_179)(void * sel, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1qa0tp6(id target, void * sel, id arg1, id arg2, id arg3, struct CGRect arg4, id arg5) {
  return ((_ProtocolTrampoline_179)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^_ListenerTrampoline_127)(void * arg0, id arg1, PSPDFControllerState arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_127 _NutrientIOSBindings_wrapListenerBlock_v1sln(_ListenerTrampoline_127 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFControllerState arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_127)(void * waiter, void * arg0, id arg1, PSPDFControllerState arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_127 _NutrientIOSBindings_wrapBlockingBlock_v1sln(
    _BlockingTrampoline_127 block, _BlockingTrampoline_127 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFControllerState arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_180)(void * sel, id arg1, PSPDFControllerState arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_v1sln(id target, void * sel, id arg1, PSPDFControllerState arg2, id arg3) {
  return ((_ProtocolTrampoline_180)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_128)(void * arg0, id arg1, PSPDFViewMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_128 _NutrientIOSBindings_wrapListenerBlock_gctmpw(_ListenerTrampoline_128 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, PSPDFViewMode arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_128)(void * waiter, void * arg0, id arg1, PSPDFViewMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_128 _NutrientIOSBindings_wrapBlockingBlock_gctmpw(
    _BlockingTrampoline_128 block, _BlockingTrampoline_128 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, PSPDFViewMode arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_181)(void * sel, id arg1, PSPDFViewMode arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_gctmpw(id target, void * sel, id arg1, PSPDFViewMode arg2) {
  return ((_ProtocolTrampoline_181)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_129)(void * arg0, PSPDFViewMode arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_129 _NutrientIOSBindings_wrapListenerBlock_ty5tme(_ListenerTrampoline_129 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, PSPDFViewMode arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_129)(void * waiter, void * arg0, PSPDFViewMode arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_129 _NutrientIOSBindings_wrapBlockingBlock_ty5tme(
    _BlockingTrampoline_129 block, _BlockingTrampoline_129 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, PSPDFViewMode arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ProtocolTrampoline_182)(void * sel, PSPDFViewMode arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_ty5tme(id target, void * sel, PSPDFViewMode arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_182)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_130)(void * arg0, UIBarStyle arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_130 _NutrientIOSBindings_wrapListenerBlock_kr3lox(_ListenerTrampoline_130 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, UIBarStyle arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_130)(void * waiter, void * arg0, UIBarStyle arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_130 _NutrientIOSBindings_wrapBlockingBlock_kr3lox(
    _BlockingTrampoline_130 block, _BlockingTrampoline_130 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, UIBarStyle arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_183)(void * sel, UIBarStyle arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_kr3lox(id target, void * sel, UIBarStyle arg1) {
  return ((_ProtocolTrampoline_183)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_131)(void * arg0, id arg1, struct objc_selector * arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_131 _NutrientIOSBindings_wrapListenerBlock_zthvms(_ListenerTrampoline_131 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct objc_selector * arg2, id arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  };
}

typedef void  (^_BlockingTrampoline_131)(void * waiter, void * arg0, id arg1, struct objc_selector * arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_131 _NutrientIOSBindings_wrapBlockingBlock_zthvms(
    _BlockingTrampoline_131 block, _BlockingTrampoline_131 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct objc_selector * arg2, id arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4));
  });
}

typedef void  (^_ProtocolTrampoline_184)(void * sel, id arg1, struct objc_selector * arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_zthvms(id target, void * sel, id arg1, struct objc_selector * arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_184)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^_ListenerTrampoline_132)(void * arg0, UILetterformAwareSizingRule arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_132 _NutrientIOSBindings_wrapListenerBlock_1k3rxc1(_ListenerTrampoline_132 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, UILetterformAwareSizingRule arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_132)(void * waiter, void * arg0, UILetterformAwareSizingRule arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_132 _NutrientIOSBindings_wrapBlockingBlock_1k3rxc1(
    _BlockingTrampoline_132 block, _BlockingTrampoline_132 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, UILetterformAwareSizingRule arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_185)(void * sel, UILetterformAwareSizingRule arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1k3rxc1(id target, void * sel, UILetterformAwareSizingRule arg1) {
  return ((_ProtocolTrampoline_185)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_133)(void * arg0, id arg1, struct CGPoint arg2, struct CGPoint * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_133 _NutrientIOSBindings_wrapListenerBlock_1y0a88x(_ListenerTrampoline_133 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct CGPoint arg2, struct CGPoint * arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_133)(void * waiter, void * arg0, id arg1, struct CGPoint arg2, struct CGPoint * arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_133 _NutrientIOSBindings_wrapBlockingBlock_1y0a88x(
    _BlockingTrampoline_133 block, _BlockingTrampoline_133 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct CGPoint arg2, struct CGPoint * arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^_ProtocolTrampoline_186)(void * sel, id arg1, struct CGPoint arg2, struct CGPoint * arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1y0a88x(id target, void * sel, id arg1, struct CGPoint arg2, struct CGPoint * arg3) {
  return ((_ProtocolTrampoline_186)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_134)(void * arg0, id arg1, id arg2, double arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_134 _NutrientIOSBindings_wrapListenerBlock_gxqm8e(_ListenerTrampoline_134 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, double arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^_BlockingTrampoline_134)(void * waiter, void * arg0, id arg1, id arg2, double arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_134 _NutrientIOSBindings_wrapBlockingBlock_gxqm8e(
    _BlockingTrampoline_134 block, _BlockingTrampoline_134 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, double arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^_ProtocolTrampoline_187)(void * sel, id arg1, id arg2, double arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_gxqm8e(id target, void * sel, id arg1, id arg2, double arg3) {
  return ((_ProtocolTrampoline_187)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_135)(void * arg0, id arg1, UITableViewCellEditingStyle arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_135 _NutrientIOSBindings_wrapListenerBlock_1qqt3t1(_ListenerTrampoline_135 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, UITableViewCellEditingStyle arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^_BlockingTrampoline_135)(void * waiter, void * arg0, id arg1, UITableViewCellEditingStyle arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_135 _NutrientIOSBindings_wrapBlockingBlock_1qqt3t1(
    _BlockingTrampoline_135 block, _BlockingTrampoline_135 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, UITableViewCellEditingStyle arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^_ProtocolTrampoline_188)(void * sel, id arg1, UITableViewCellEditingStyle arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1qqt3t1(id target, void * sel, id arg1, UITableViewCellEditingStyle arg2, id arg3) {
  return ((_ProtocolTrampoline_188)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^_ListenerTrampoline_136)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_136 _NutrientIOSBindings_wrapListenerBlock_1l4hxwm(_ListenerTrampoline_136 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retainBlock(arg1));
  };
}

typedef void  (^_BlockingTrampoline_136)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_136 _NutrientIOSBindings_wrapBlockingBlock_1l4hxwm(
    _BlockingTrampoline_136 block, _BlockingTrampoline_136 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, objc_retainBlock(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, objc_retainBlock(arg1));
  });
}

typedef void  (^_ProtocolTrampoline_189)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_1l4hxwm(id target, void * sel, id arg1) {
  return ((_ProtocolTrampoline_189)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_137)(void * arg0, id arg1, UITextFieldDidEndEditingReason arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_137 _NutrientIOSBindings_wrapListenerBlock_18wmx9i(_ListenerTrampoline_137 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, UITextFieldDidEndEditingReason arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^_BlockingTrampoline_137)(void * waiter, void * arg0, id arg1, UITextFieldDidEndEditingReason arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_137 _NutrientIOSBindings_wrapBlockingBlock_18wmx9i(
    _BlockingTrampoline_137 block, _BlockingTrampoline_137 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, UITextFieldDidEndEditingReason arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^_ProtocolTrampoline_190)(void * sel, id arg1, UITextFieldDidEndEditingReason arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_18wmx9i(id target, void * sel, id arg1, UITextFieldDidEndEditingReason arg2) {
  return ((_ProtocolTrampoline_190)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_138)(void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_138 _NutrientIOSBindings_wrapListenerBlock_10lndml(_ListenerTrampoline_138 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, BOOL arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^_BlockingTrampoline_138)(void * waiter, void * arg0, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_138 _NutrientIOSBindings_wrapBlockingBlock_10lndml(
    _BlockingTrampoline_138 block, _BlockingTrampoline_138 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, BOOL arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^_ProtocolTrampoline_191)(void * sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_10lndml(id target, void * sel, BOOL arg1) {
  return ((_ProtocolTrampoline_191)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^_ListenerTrampoline_139)(void * arg0, BOOL arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_139 _NutrientIOSBindings_wrapListenerBlock_5si851(_ListenerTrampoline_139 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, BOOL arg1, BOOL arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^_BlockingTrampoline_139)(void * waiter, void * arg0, BOOL arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_139 _NutrientIOSBindings_wrapBlockingBlock_5si851(
    _BlockingTrampoline_139 block, _BlockingTrampoline_139 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, BOOL arg1, BOOL arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^_ProtocolTrampoline_192)(void * sel, BOOL arg1, BOOL arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _NutrientIOSBindings_protocolTrampoline_5si851(id target, void * sel, BOOL arg1, BOOL arg2) {
  return ((_ProtocolTrampoline_192)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^_ListenerTrampoline_144)(id arg0, id arg1, size_t arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_144 _NutrientIOSBindings_wrapListenerBlock_vrbbwj(_ListenerTrampoline_144 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, size_t arg2, BOOL arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^_BlockingTrampoline_144)(void * waiter, id arg0, id arg1, size_t arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
_ListenerTrampoline_144 _NutrientIOSBindings_wrapBlockingBlock_vrbbwj(
    _BlockingTrampoline_144 block, _BlockingTrampoline_144 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, size_t arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef id  (^_ProtocolTrampoline_193)(void * sel, PSPDFDataSinkOptions arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1hoaye0(id target, void * sel, PSPDFDataSinkOptions arg1, id * arg2) {
  return ((_ProtocolTrampoline_193)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^_ProtocolTrampoline_194)(void * sel, unsigned long arg1, struct CGSize arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1x2t90h(id target, void * sel, unsigned long arg1, struct CGSize arg2, id arg3) {
  return ((_ProtocolTrampoline_194)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^_ProtocolTrampoline_195)(void * sel, id arg1, UINavigationControllerOperation arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _NutrientIOSBindings_protocolTrampoline_1cbct6m(id target, void * sel, id arg1, UINavigationControllerOperation arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_195)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _NutrientIOSBindings_PSPDFAnalyticsClient(void) { return @protocol(PSPDFAnalyticsClient); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationGridViewControllerDataSource(void) { return @protocol(PSPDFAnnotationGridViewControllerDataSource); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationGridViewControllerDelegate(void) { return @protocol(PSPDFAnnotationGridViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationPresenting(void) { return @protocol(PSPDFAnnotationPresenting); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationProvider(void) { return @protocol(PSPDFAnnotationProvider); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationProviderChangeNotifier(void) { return @protocol(PSPDFAnnotationProviderChangeNotifier); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationProviderDelegate(void) { return @protocol(PSPDFAnnotationProviderDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationSetStore(void) { return @protocol(PSPDFAnnotationSetStore); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationStateManagerDelegate(void) { return @protocol(PSPDFAnnotationStateManagerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationStyleManager(void) { return @protocol(PSPDFAnnotationStyleManager); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationStyleViewControllerDelegate(void) { return @protocol(PSPDFAnnotationStyleViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationTableViewControllerDelegate(void) { return @protocol(PSPDFAnnotationTableViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAnnotationUpdate(void) { return @protocol(PSPDFAnnotationUpdate); }

Protocol* _NutrientIOSBindings_PSPDFAppearanceModeManagerDelegate(void) { return @protocol(PSPDFAppearanceModeManagerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFAppearanceStreamGenerating(void) { return @protocol(PSPDFAppearanceStreamGenerating); }

Protocol* _NutrientIOSBindings_PSPDFApplication(void) { return @protocol(PSPDFApplication); }

Protocol* _NutrientIOSBindings_PSPDFApplicationPolicy(void) { return @protocol(PSPDFApplicationPolicy); }

Protocol* _NutrientIOSBindings_PSPDFAvoidingScrollViewDelegate(void) { return @protocol(PSPDFAvoidingScrollViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFBackForwardActionListDelegate(void) { return @protocol(PSPDFBackForwardActionListDelegate); }

Protocol* _NutrientIOSBindings_PSPDFBookmarkProvider(void) { return @protocol(PSPDFBookmarkProvider); }

Protocol* _NutrientIOSBindings_PSPDFBookmarkTableViewCellDelegate(void) { return @protocol(PSPDFBookmarkTableViewCellDelegate); }

Protocol* _NutrientIOSBindings_PSPDFBookmarkViewControllerDelegate(void) { return @protocol(PSPDFBookmarkViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFCertificatePickerViewControllerDelegate(void) { return @protocol(PSPDFCertificatePickerViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFCollectionViewDelegateThumbnailFlowLayout(void) { return @protocol(PSPDFCollectionViewDelegateThumbnailFlowLayout); }

Protocol* _NutrientIOSBindings_PSPDFConflictResolutionManagerDelegate(void) { return @protocol(PSPDFConflictResolutionManagerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFContainerViewControllerDelegate(void) { return @protocol(PSPDFContainerViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFControlDelegate(void) { return @protocol(PSPDFControlDelegate); }

Protocol* _NutrientIOSBindings_PSPDFControllerStateHandling(void) { return @protocol(PSPDFControllerStateHandling); }

Protocol* _NutrientIOSBindings_PSPDFCoordinatedFileDataProviding(void) { return @protocol(PSPDFCoordinatedFileDataProviding); }

Protocol* _NutrientIOSBindings_PSPDFDataProviding(void) { return @protocol(PSPDFDataProviding); }

Protocol* _NutrientIOSBindings_PSPDFDataSink(void) { return @protocol(PSPDFDataSink); }

Protocol* _NutrientIOSBindings_PSPDFDatabaseEncryptionProvider(void) { return @protocol(PSPDFDatabaseEncryptionProvider); }

Protocol* _NutrientIOSBindings_PSPDFDetachedUndoRecorder(void) { return @protocol(PSPDFDetachedUndoRecorder); }

Protocol* _NutrientIOSBindings_PSPDFDocumentAlignmentViewControllerDelegate(void) { return @protocol(PSPDFDocumentAlignmentViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentDelegate(void) { return @protocol(PSPDFDocumentDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentEditorConfigurationConfigurable(void) { return @protocol(PSPDFDocumentEditorConfigurationConfigurable); }

Protocol* _NutrientIOSBindings_PSPDFDocumentEditorDelegate(void) { return @protocol(PSPDFDocumentEditorDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentEditorToolbarControllerDelegate(void) { return @protocol(PSPDFDocumentEditorToolbarControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentFeaturesObserver(void) { return @protocol(PSPDFDocumentFeaturesObserver); }

Protocol* _NutrientIOSBindings_PSPDFDocumentFeaturesSource(void) { return @protocol(PSPDFDocumentFeaturesSource); }

Protocol* _NutrientIOSBindings_PSPDFDocumentInfoController(void) { return @protocol(PSPDFDocumentInfoController); }

Protocol* _NutrientIOSBindings_PSPDFDocumentInfoCoordinatorDelegate(void) { return @protocol(PSPDFDocumentInfoCoordinatorDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentInfoViewControllerDelegate(void) { return @protocol(PSPDFDocumentInfoViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentPickerControllerDelegate(void) { return @protocol(PSPDFDocumentPickerControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentProviderDelegate(void) { return @protocol(PSPDFDocumentProviderDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentSharingViewControllerDelegate(void) { return @protocol(PSPDFDocumentSharingViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentSignerDataSource(void) { return @protocol(PSPDFDocumentSignerDataSource); }

Protocol* _NutrientIOSBindings_PSPDFDocumentSignerDelegate(void) { return @protocol(PSPDFDocumentSignerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentViewControllerDelegate(void) { return @protocol(PSPDFDocumentViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDocumentViewInteractions(void) { return @protocol(PSPDFDocumentViewInteractions); }

Protocol* _NutrientIOSBindings_PSPDFDownloadManagerDelegate(void) { return @protocol(PSPDFDownloadManagerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFDownloadManagerPolicy(void) { return @protocol(PSPDFDownloadManagerPolicy); }

Protocol* _NutrientIOSBindings_PSPDFDrawViewDelegate(void) { return @protocol(PSPDFDrawViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFEmbeddedFilesViewControllerDelegate(void) { return @protocol(PSPDFEmbeddedFilesViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFEraseOverlayDataSource(void) { return @protocol(PSPDFEraseOverlayDataSource); }

Protocol* _NutrientIOSBindings_PSPDFErrorHandler(void) { return @protocol(PSPDFErrorHandler); }

Protocol* _NutrientIOSBindings_PSPDFExternalSignature(void) { return @protocol(PSPDFExternalSignature); }

Protocol* _NutrientIOSBindings_PSPDFExternalURLHandler(void) { return @protocol(PSPDFExternalURLHandler); }

Protocol* _NutrientIOSBindings_PSPDFFileCoordinationDelegate(void) { return @protocol(PSPDFFileCoordinationDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFileDataProviding(void) { return @protocol(PSPDFFileDataProviding); }

Protocol* _NutrientIOSBindings_PSPDFFileManager(void) { return @protocol(PSPDFFileManager); }

Protocol* _NutrientIOSBindings_PSPDFFlexibleToolbarContainerDelegate(void) { return @protocol(PSPDFFlexibleToolbarContainerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFlexibleToolbarDelegate(void) { return @protocol(PSPDFFlexibleToolbarDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFontPickerViewControllerDelegate(void) { return @protocol(PSPDFFontPickerViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFormFieldIdentifier(void) { return @protocol(PSPDFFormFieldIdentifier); }

Protocol* _NutrientIOSBindings_PSPDFFormInputAccessoryViewDelegate(void) { return @protocol(PSPDFFormInputAccessoryViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFormSubmissionDelegate(void) { return @protocol(PSPDFFormSubmissionDelegate); }

Protocol* _NutrientIOSBindings_PSPDFFreeTextAccessoryViewDelegate(void) { return @protocol(PSPDFFreeTextAccessoryViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFGalleryContentViewCaption(void) { return @protocol(PSPDFGalleryContentViewCaption); }

Protocol* _NutrientIOSBindings_PSPDFGalleryContentViewError(void) { return @protocol(PSPDFGalleryContentViewError); }

Protocol* _NutrientIOSBindings_PSPDFGalleryContentViewLoading(void) { return @protocol(PSPDFGalleryContentViewLoading); }

Protocol* _NutrientIOSBindings_PSPDFGalleryViewDataSource(void) { return @protocol(PSPDFGalleryViewDataSource); }

Protocol* _NutrientIOSBindings_PSPDFGalleryViewDelegate(void) { return @protocol(PSPDFGalleryViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFImagePickerControllerDelegate(void) { return @protocol(PSPDFImagePickerControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFInitialStartingPointGesture(void) { return @protocol(PSPDFInitialStartingPointGesture); }

Protocol* _NutrientIOSBindings_PSPDFInlineSearchManagerDelegate(void) { return @protocol(PSPDFInlineSearchManagerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFKnobView(void) { return @protocol(PSPDFKnobView); }

Protocol* _NutrientIOSBindings_PSPDFLibraryDataSource(void) { return @protocol(PSPDFLibraryDataSource); }

Protocol* _NutrientIOSBindings_PSPDFLibraryFileSystemDataSourceDocumentProvider(void) { return @protocol(PSPDFLibraryFileSystemDataSourceDocumentProvider); }

Protocol* _NutrientIOSBindings_PSPDFLinkAnnotationEditingContainerViewControllerDelegate(void) { return @protocol(PSPDFLinkAnnotationEditingContainerViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFLinkAnnotationEditingViewControllerDelegate(void) { return @protocol(PSPDFLinkAnnotationEditingViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFMeasurementAnnotation(void) { return @protocol(PSPDFMeasurementAnnotation); }

Protocol* _NutrientIOSBindings_PSPDFMediaPlayerControllerDelegate(void) { return @protocol(PSPDFMediaPlayerControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFMultiDocumentListControllerDelegate(void) { return @protocol(PSPDFMultiDocumentListControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFMultiDocumentViewControllerDelegate(void) { return @protocol(PSPDFMultiDocumentViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFMultimediaViewController(void) { return @protocol(PSPDFMultimediaViewController); }

Protocol* _NutrientIOSBindings_PSPDFNetworkActivityIndicatorManager(void) { return @protocol(PSPDFNetworkActivityIndicatorManager); }

Protocol* _NutrientIOSBindings_PSPDFNewPageViewControllerDataSource(void) { return @protocol(PSPDFNewPageViewControllerDataSource); }

Protocol* _NutrientIOSBindings_PSPDFNewPageViewControllerDelegate(void) { return @protocol(PSPDFNewPageViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFNoteAnnotationViewControllerDelegate(void) { return @protocol(PSPDFNoteAnnotationViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFOutlineCellDelegate(void) { return @protocol(PSPDFOutlineCellDelegate); }

Protocol* _NutrientIOSBindings_PSPDFOutlineViewControllerDelegate(void) { return @protocol(PSPDFOutlineViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFOverridable(void) { return @protocol(PSPDFOverridable); }

Protocol* _NutrientIOSBindings_PSPDFPageCellImageLoading(void) { return @protocol(PSPDFPageCellImageLoading); }

Protocol* _NutrientIOSBindings_PSPDFPageCellImageRequestToken(void) { return @protocol(PSPDFPageCellImageRequestToken); }

Protocol* _NutrientIOSBindings_PSPDFPageControls(void) { return @protocol(PSPDFPageControls); }

Protocol* _NutrientIOSBindings_PSPDFPageLabelViewDelegate(void) { return @protocol(PSPDFPageLabelViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFPendingUndoRecorder(void) { return @protocol(PSPDFPendingUndoRecorder); }

Protocol* _NutrientIOSBindings_PSPDFPresentationActions(void) { return @protocol(PSPDFPresentationActions); }

Protocol* _NutrientIOSBindings_PSPDFPresentationContext(void) { return @protocol(PSPDFPresentationContext); }

Protocol* _NutrientIOSBindings_PSPDFProcessorDelegate(void) { return @protocol(PSPDFProcessorDelegate); }

Protocol* _NutrientIOSBindings_PSPDFRemoteContentObject(void) { return @protocol(PSPDFRemoteContentObject); }

Protocol* _NutrientIOSBindings_PSPDFRenderManager(void) { return @protocol(PSPDFRenderManager); }

Protocol* _NutrientIOSBindings_PSPDFRenderTaskDelegate(void) { return @protocol(PSPDFRenderTaskDelegate); }

Protocol* _NutrientIOSBindings_PSPDFResizableViewDelegate(void) { return @protocol(PSPDFResizableViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFRotatable(void) { return @protocol(PSPDFRotatable); }

Protocol* _NutrientIOSBindings_PSPDFSaveViewControllerDelegate(void) { return @protocol(PSPDFSaveViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFScreenControllerDelegate(void) { return @protocol(PSPDFScreenControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFScrubberBarDelegate(void) { return @protocol(PSPDFScrubberBarDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSearchHighlightViewManagerDataSource(void) { return @protocol(PSPDFSearchHighlightViewManagerDataSource); }

Protocol* _NutrientIOSBindings_PSPDFSearchResultViewable(void) { return @protocol(PSPDFSearchResultViewable); }

Protocol* _NutrientIOSBindings_PSPDFSearchScopeViewable(void) { return @protocol(PSPDFSearchScopeViewable); }

Protocol* _NutrientIOSBindings_PSPDFSearchStatusViewable(void) { return @protocol(PSPDFSearchStatusViewable); }

Protocol* _NutrientIOSBindings_PSPDFSearchViewControllerDelegate(void) { return @protocol(PSPDFSearchViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSegmentImageProviding(void) { return @protocol(PSPDFSegmentImageProviding); }

Protocol* _NutrientIOSBindings_PSPDFSelectionViewDelegate(void) { return @protocol(PSPDFSelectionViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSignatureContents(void) { return @protocol(PSPDFSignatureContents); }

Protocol* _NutrientIOSBindings_PSPDFSignatureCreationViewControllerDelegate(void) { return @protocol(PSPDFSignatureCreationViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSignatureSelectorViewControllerDelegate(void) { return @protocol(PSPDFSignatureSelectorViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSignatureStore(void) { return @protocol(PSPDFSignatureStore); }

Protocol* _NutrientIOSBindings_PSPDFSignatureViewControllerDelegate(void) { return @protocol(PSPDFSignatureViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFSignedFormElementViewControllerDelegate(void) { return @protocol(PSPDFSignedFormElementViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFStatefulViewControlling(void) { return @protocol(PSPDFStatefulViewControlling); }

Protocol* _NutrientIOSBindings_PSPDFStatusHUDItemDelegate(void) { return @protocol(PSPDFStatusHUDItemDelegate); }

Protocol* _NutrientIOSBindings_PSPDFStylePreset(void) { return @protocol(PSPDFStylePreset); }

Protocol* _NutrientIOSBindings_PSPDFStyleable(void) { return @protocol(PSPDFStyleable); }

Protocol* _NutrientIOSBindings_PSPDFSystemBar(void) { return @protocol(PSPDFSystemBar); }

Protocol* _NutrientIOSBindings_PSPDFTabbedViewControllerDelegate(void) { return @protocol(PSPDFTabbedViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFTextSearchDelegate(void) { return @protocol(PSPDFTextSearchDelegate); }

Protocol* _NutrientIOSBindings_PSPDFTextSelectionViewDelegate(void) { return @protocol(PSPDFTextSelectionViewDelegate); }

Protocol* _NutrientIOSBindings_PSPDFTextStampViewControllerDelegate(void) { return @protocol(PSPDFTextStampViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFThumbnailBarDelegate(void) { return @protocol(PSPDFThumbnailBarDelegate); }

Protocol* _NutrientIOSBindings_PSPDFThumbnailViewControllerDelegate(void) { return @protocol(PSPDFThumbnailViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFUndoController(void) { return @protocol(PSPDFUndoController); }

Protocol* _NutrientIOSBindings_PSPDFUndoRecorder(void) { return @protocol(PSPDFUndoRecorder); }

Protocol* _NutrientIOSBindings_PSPDFUserInterfaceControls(void) { return @protocol(PSPDFUserInterfaceControls); }

Protocol* _NutrientIOSBindings_PSPDFViewControllerDelegate(void) { return @protocol(PSPDFViewControllerDelegate); }

Protocol* _NutrientIOSBindings_PSPDFViewModePresenter(void) { return @protocol(PSPDFViewModePresenter); }

Protocol* _NutrientIOSBindings_PSPDFVisiblePagesDataSource(void) { return @protocol(PSPDFVisiblePagesDataSource); }

Protocol* _NutrientIOSBindings_PSPDFWebViewControllerDelegate(void) { return @protocol(PSPDFWebViewControllerDelegate); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
