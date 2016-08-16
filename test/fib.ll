
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@heapPtr = common global i32 addrspace(1)* null, align 8
@gcCounter = common global i32 0, align 8
@.str = private unnamed_addr constant [14 x i8] c"fib(%d) = %d\0A\00", align 1

declare void @enterGC()

declare token @llvm.experimental.gc.statepoint.p0f_voidvoidf(i64, i32, void ()*, i32, i32, ...)
declare token @llvm.experimental.gc.statepoint.p0f_p1i32p1i32f(i64, i32, i32 addrspace(1)* (i32 addrspace(1)*)*, i32, i32, ...)
declare i32 addrspace(1)* @llvm.experimental.gc.result.p1i32(token)
declare i32 addrspace(1)*  @llvm.experimental.gc.relocate.p1i32(token, i32, i32) ; base idx, pointer idx

; Function Attrs: nounwind ssp uwtable
define i32 addrspace(1)* @fib(i32 addrspace(1)* %boxedValParam) #0 gc "statepoint-example" {
entry:
    %count = load i32, i32* @gcCounter
    %cond = icmp sgt i32 %count, 10
    br i1 %cond, label %doGC, label %afterCheck
    
doGC:
    %gcRetTok = call token
              (i64, i32, void ()*, i32, i32, ...)
              @llvm.experimental.gc.statepoint.p0f_voidvoidf(
                  i64 0,      ; id
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
    br label %afterCheck
    
afterCheck: 
  %boxedVal = phi i32 addrspace(1)* [%boxedVal.afterGCRelo, %doGC], [%boxedValParam, %entry]
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
                i64 0,      ; id
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
                i64 0,      ; id
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
define i32 @main() #0 gc "statepoint-example" {
  %r1 = call i8 addrspace(1)* @malloc(i64 12288)
  %r2 = bitcast i8 addrspace(1)* %r1 to i32 addrspace(1)*
  store i32 addrspace(1)* %r2, i32 addrspace(1)** @heapPtr, align 8
  %r3 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 9, i32 addrspace(1)* %r3, align 4
  %r4 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %r5 = getelementptr inbounds i32, i32 addrspace(1)* %r4, i32 1
  store i32 addrspace(1)* %r5, i32 addrspace(1)** @heapPtr, align 8
  %r6 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %r3)
  %r7 = load i32, i32 addrspace(1)* %r6, align 4
  %r8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i32 0, i32 0), i32 9, i32 %r7)
  ret i32 0
}

declare i8 addrspace(1)* @malloc(i64) #1

declare i32 @printf(i8*, ...) #1

attributes #0 = { nounwind ssp uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="core2" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="core2" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"PIC Level", i32 2}
!1 = !{!"Apple LLVM version 7.3.0 (clang-703.0.29)"}
