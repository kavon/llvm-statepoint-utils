
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@heapPtr = common global i32 addrspace(1)* null, align 8
@heapBase = common global i32 addrspace(1)* null, align 8
; 4096 bytes is just enough for a depth of at least 50, will trigger a lot of GCs :)
@heapSizeB = global i64 4096, align 8 

; @gcCounter = common global i32 0, align 8
@.str = private unnamed_addr constant [14 x i8] c"fib(%d) = %d\0A\00", align 1

declare void @enterGC()

declare token @llvm.experimental.gc.statepoint.p0f_voidvoidf(i64, i32, void ()*, i32, i32, ...)
declare token @llvm.experimental.gc.statepoint.p0f_p1i32p1i32f(i64, i32, i32 addrspace(1)* (i32 addrspace(1)*)*, i32, i32, ...)
declare i32 addrspace(1)* @llvm.experimental.gc.result.p1i32(token)
declare i32 addrspace(1)*  @llvm.experimental.gc.relocate.p1i32(token, i32, i32) ; base idx, pointer idx

define internal i32 addrspace(1)* @fib(i32 addrspace(1)* %boxedValParam) gc "statepoint-example" {
entry:
    ; %count = load i32, i32* @gcCounter
    %allocPtr = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr
    %basePtr = load i32 addrspace(1)*, i32 addrspace(1)** @heapBase
    %allocPtr.v = ptrtoint i32 addrspace(1)* %allocPtr to i64
    %basePtr.v = ptrtoint i32 addrspace(1)* %basePtr to i64
    %usedSpace = sub i64 %allocPtr.v, %basePtr.v
    %sz = load i64, i64* @heapSizeB
    %max = sub i64 %sz, 128  ;; some head room
    %cond = icmp sgt i64 %usedSpace, %max
    br i1 %cond, label %doGC, label %afterCheck
    
doGC:
    %gcRetTok = call token
              (i64, i32, void ()*, i32, i32, ...)
              @llvm.experimental.gc.statepoint.p0f_voidvoidf(
                  i64 2863311530,      ; id = 0xAAAAAAAA
                  i32 0,      ; patch bytes 
                  
                  void ()* @enterGC,    ; function
                  i32 0, ; function's arity
                  
                  i32 0, ; "flags"
                  ; start of args
                  
                  ; end of args
                  i32 0, ; # "transition" args, followed by them if any
                  i32 0, ; # deopt args, followed by them if any
                  
                  ; start of live heap pointers that the GC needs to know about.
                  i32 addrspace(1)* %boxedValParam
                  
                  )
                  
    %boxedVal.afterGCRelo = call i32 addrspace(1)*  
              @llvm.experimental.gc.relocate.p1i32(token %gcRetTok, i32 7, i32 7)
              
    ; reset the count
    ; store i32 0, i32* @gcCounter
    
    br label %afterCheck
    
afterCheck: 
  %boxedVal = phi i32 addrspace(1)* [%boxedVal.afterGCRelo, %doGC], [%boxedValParam, %entry]
  
  ; increment the count
  ; %z1 = load i32, i32* @gcCounter
  ; %z2 = add i32 %z1, 1
  ; store i32 %z2, i32* @gcCounter
  
  %r1 = load i32, i32 addrspace(1)* %boxedVal, align 4
  %r2 = icmp sle i32 %r1, 1
  br i1 %r2, label %r3, label %r4

r3:
  br label %r23

r4:
  %r5 = load i32, i32 addrspace(1)* %boxedVal, align 4
  %r6 = sub nsw i32 %r5, 1
  %r7 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %r6, i32 addrspace(1)* %r7, align 4
  %r8 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %r9 = getelementptr inbounds i32, i32 addrspace(1)* %r8, i32 1
  store i32 addrspace(1)* %r9, i32 addrspace(1)** @heapPtr, align 8
  
  ; %r10 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %r7)
  
  %retTok = call token
            (i64, i32, i32 addrspace(1)* (i32 addrspace(1)*)*, i32, i32, ...)
            @llvm.experimental.gc.statepoint.p0f_p1i32p1i32f(
                i64 3149642683,      ; id = 0xBBBBBBBB
                i32 0,      ; patch bytes 
                
                i32 addrspace(1)* (i32 addrspace(1)*)* @fib,    ; function
                i32 1, ; function's arity
                
                i32 0, ; "flags"
                ; start of args
                
                i32 addrspace(1)* %r7,
                
                ; end of args
                i32 0, ; # "transition" args, followed by them if any
                i32 0, ; # deopt args, followed by them if any
                
                ; start of live heap pointers that the GC needs to know about.
                i32 addrspace(1)* %boxedVal
                
                )
                
  %fib_minusOne = call i32 addrspace(1)* @llvm.experimental.gc.result.p1i32(token %retTok)
  %boxedVal.relo = call i32 addrspace(1)*  
            @llvm.experimental.gc.relocate.p1i32(token %retTok, i32 8, i32 8)
  
  
  %r11 = load i32, i32 addrspace(1)* %boxedVal.relo, align 4
  %r12 = sub nsw i32 %r11, 2
  %r13 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %r12, i32 addrspace(1)* %r13, align 4
  %r14 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %r15 = getelementptr inbounds i32, i32 addrspace(1)* %r14, i32 1
  store i32 addrspace(1)* %r15, i32 addrspace(1)** @heapPtr, align 8
  
  ; %r16 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %r13)
  
  %retTok2 = call token
            (i64, i32, i32 addrspace(1)* (i32 addrspace(1)*)*, i32, i32, ...)
            @llvm.experimental.gc.statepoint.p0f_p1i32p1i32f(
                i64 3435973836,      ; id = 0xCCCCCCCC
                i32 0,      ; patch bytes 
                
                i32 addrspace(1)* (i32 addrspace(1)*)* @fib,    ; function
                i32 1, ; function's arity
                
                i32 0, ; "flags"
                ; start of args
                
                i32 addrspace(1)* %r13,
                
                ; end of args
                i32 0, ; # "transition" args, followed by them if any
                i32 0, ; # deopt args, followed by them if any
                
                ; start of live heap pointers that the GC needs to know about.
                i32 addrspace(1)* %fib_minusOne
                
                )
                
  %fib_minusTwo = call i32 addrspace(1)* @llvm.experimental.gc.result.p1i32(token %retTok2)
  %fib_minusOne.relo = call i32 addrspace(1)*  
            @llvm.experimental.gc.relocate.p1i32(token %retTok2, i32 8, i32 8)
  
  %r17 = load i32, i32 addrspace(1)* %fib_minusOne.relo, align 4
  %r18 = load i32, i32 addrspace(1)* %fib_minusTwo, align 4
  %r19 = add nsw i32 %r17, %r18
  %r20 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %r19, i32 addrspace(1)* %r20, align 4
  %r21 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %r22 = getelementptr inbounds i32, i32 addrspace(1)* %r21, i32 1
  store i32 addrspace(1)* %r22, i32 addrspace(1)** @heapPtr, align 8
  br label %r23

r23:
  %.0 = phi i32 addrspace(1)* [ %boxedVal, %r3 ], [ %r20, %r4 ]
  ret i32 addrspace(1)* %.0
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() gc "statepoint-example" {
  %r0 = load i64, i64* @heapSizeB, align 8
  %r1 = call i8 addrspace(1)* @malloc(i64 %r0)
  %r2 = bitcast i8 addrspace(1)* %r1 to i32 addrspace(1)*
  store i32 addrspace(1)* %r2, i32 addrspace(1)** @heapPtr, align 8
  store i32 addrspace(1)* %r2, i32 addrspace(1)** @heapBase, align 8
  %r3 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  
  ; fib(35) = 9227465
  %n = bitcast i32 35 to i32
  store i32 %n, i32 addrspace(1)* %r3, align 4
  
  %r4 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %r5 = getelementptr inbounds i32, i32 addrspace(1)* %r4, i32 1
  store i32 addrspace(1)* %r5, i32 addrspace(1)** @heapPtr, align 8
  %r6 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %r3)
  %r7 = load i32, i32 addrspace(1)* %r6, align 4
  %r8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i32 0, i32 0), i32 %n, i32 %r7)
  ret i32 0
}

declare i8 addrspace(1)* @malloc(i64)

declare i32 @printf(i8*, ...)
