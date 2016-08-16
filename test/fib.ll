; ModuleID = 'main.ll'
source_filename = "main.ll"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.11.0"

@heapPtr = common global i32 addrspace(1)* null, align 8
@.str = private unnamed_addr constant [14 x i8] c"fib(%d) = %d\0A\00", align 1

; Function Attrs: nounwind ssp uwtable
define i32 addrspace(1)* @fib(i32 addrspace(1)* %boxedVal) #0 gc "statepoint-example" {
  %1 = load i32, i32 addrspace(1)* %boxedVal, align 4
  %2 = icmp sle i32 %1, 1
  br i1 %2, label %3, label %4

; <label>:3:                                      ; preds = %0
  br label %23

; <label>:4:                                      ; preds = %0
  %5 = load i32, i32 addrspace(1)* %boxedVal, align 4
  %6 = sub nsw i32 %5, 1
  %7 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %6, i32 addrspace(1)* %7, align 4
  %8 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %9 = getelementptr inbounds i32, i32 addrspace(1)* %8, i32 1
  store i32 addrspace(1)* %9, i32 addrspace(1)** @heapPtr, align 8
  %10 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %7)
  %11 = load i32, i32 addrspace(1)* %boxedVal, align 4
  %12 = sub nsw i32 %11, 2
  %13 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %12, i32 addrspace(1)* %13, align 4
  %14 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %15 = getelementptr inbounds i32, i32 addrspace(1)* %14, i32 1
  store i32 addrspace(1)* %15, i32 addrspace(1)** @heapPtr, align 8
  %16 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %13)
  %17 = load i32, i32 addrspace(1)* %10, align 4
  %18 = load i32, i32 addrspace(1)* %16, align 4
  %19 = add nsw i32 %17, %18
  %20 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 %19, i32 addrspace(1)* %20, align 4
  %21 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %22 = getelementptr inbounds i32, i32 addrspace(1)* %21, i32 1
  store i32 addrspace(1)* %22, i32 addrspace(1)** @heapPtr, align 8
  br label %23

; <label>:23:                                     ; preds = %4, %3
  %.0 = phi i32 addrspace(1)* [ %boxedVal, %3 ], [ %20, %4 ]
  ret i32 addrspace(1)* %.0
}

; Function Attrs: nounwind ssp uwtable
define i32 @main() #0 gc "statepoint-example" {
  %1 = call i8 addrspace(1)* @malloc(i64 12288)
  %2 = bitcast i8 addrspace(1)* %1 to i32 addrspace(1)*
  store i32 addrspace(1)* %2, i32 addrspace(1)** @heapPtr, align 8
  %3 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  store i32 9, i32 addrspace(1)* %3, align 4
  %4 = load i32 addrspace(1)*, i32 addrspace(1)** @heapPtr, align 8
  %5 = getelementptr inbounds i32, i32 addrspace(1)* %4, i32 1
  store i32 addrspace(1)* %5, i32 addrspace(1)** @heapPtr, align 8
  %6 = call i32 addrspace(1)* @fib(i32 addrspace(1)* %3)
  %7 = load i32, i32 addrspace(1)* %6, align 4
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i32 0, i32 0), i32 9, i32 %7)
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
