; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -mtriple=thumbv8.1m.main -mattr=+mve < %s | FileCheck %s --check-prefix=CHECK-MVE
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -mtriple=thumbv8m.main < %s | FileCheck %s --check-prefix=CHECK-V8M-MAIN
; RUN: opt -S -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -mtriple=thumbv8m.base < %s | FileCheck %s --check-prefix=CHECK-V8M-BASE

declare float @llvm.sqrt.f32(float) nounwind readonly
declare float @llvm.fma.f32(float, float, float) nounwind readonly
declare float @llvm.fmuladd.f32(float, float, float) nounwind readonly
declare float @llvm.fabs.f32(float) nounwind readonly
declare float @llvm.minnum.f32(float, float) nounwind readonly
declare float @llvm.maxnum.f32(float, float) nounwind readonly
declare float @llvm.minimum.f32(float, float) nounwind readonly
declare float @llvm.maximum.f32(float, float) nounwind readonly

define double @fdiv_test(double %a, double %b) {
; CHECK-MVE-LABEL: @fdiv_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP:%.*]] = fcmp ogt double [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[DIV:%.*]] = fdiv double [[B:%.*]], [[A]]
; CHECK-MVE-NEXT:    [[COND:%.*]] = select nsz i1 [[CMP]], double [[DIV]], double 0.000000e+00
; CHECK-MVE-NEXT:    ret double [[COND]]
;
; CHECK-V8M-MAIN-LABEL: @fdiv_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP:%.*]] = fcmp ogt double [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[DIV:%.*]] = fdiv double [[B:%.*]], [[A]]
; CHECK-V8M-MAIN-NEXT:    [[COND:%.*]] = select nsz i1 [[CMP]], double [[DIV]], double 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    ret double [[COND]]
;
; CHECK-V8M-BASE-LABEL: @fdiv_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP:%.*]] = fcmp ogt double [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[DIV:%.*]] = fdiv double [[B:%.*]], [[A]]
; CHECK-V8M-BASE-NEXT:    [[COND:%.*]] = select nsz i1 [[CMP]], double [[DIV]], double 0.000000e+00
; CHECK-V8M-BASE-NEXT:    ret double [[COND]]
;
entry:
  %cmp = fcmp ogt double %a, 0.0
  br i1 %cmp, label %cond.true, label %cond.end

cond.true:
  %div = fdiv double %b, %a
  br label %cond.end

cond.end:
  %cond = phi nsz double [ %div, %cond.true ], [ 0.0, %entry ]
  ret double %cond
}

define void @sqrt_test(ptr addrspace(1) noalias nocapture %out, float %a) nounwind {
; CHECK-MVE-LABEL: @sqrt_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.sqrt.f32(float [[A]]) #[[ATTR3:[0-9]+]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select afn i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @sqrt_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.sqrt.f32(float [[A]]) #[[ATTR2:[0-9]+]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select afn i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @sqrt_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.sqrt.f32(float [[A]]) #[[ATTR2:[0-9]+]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select afn i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_sqrt.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.sqrt.f32(float %a) nounwind readnone
  br label %test_sqrt.exit

test_sqrt.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi afn float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fabs_test(ptr addrspace(1) noalias nocapture %out, float %a) nounwind {
; CHECK-MVE-LABEL: @fabs_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fabs.f32(float [[A]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @fabs_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fabs.f32(float [[A]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @fabs_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fabs.f32(float [[A]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fabs.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fabs.f32(float %a) nounwind readnone
  br label %test_fabs.exit

test_fabs.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fma_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b, float %c) nounwind {
; CHECK-MVE-LABEL: @fma_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fma.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select reassoc nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @fma_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fma.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select reassoc nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @fma_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fma.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select reassoc nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fma.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fma.f32(float %a, float %b, float %c) nounwind readnone
  br label %test_fma.exit

test_fma.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi nsz reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @fmuladd_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b, float %c) nounwind {
; CHECK-MVE-LABEL: @fmuladd_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fmuladd.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select ninf i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @fmuladd_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fmuladd.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select ninf i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @fmuladd_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.fmuladd.f32(float [[A]], float [[B:%.*]], float [[C:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select ninf i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_fmuladd.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.fmuladd.f32(float %a, float %b, float %c) nounwind readnone
  br label %test_fmuladd.exit

test_fmuladd.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi ninf float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @minnum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-MVE-LABEL: @minnum_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @minnum_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @minnum_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_minnum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.minnum.f32(float %a, float %b) nounwind readnone
  br label %test_minnum.exit

test_minnum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @maxnum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-MVE-LABEL: @maxnum_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maxnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select ninf nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @maxnum_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maxnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select ninf nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @maxnum_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maxnum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select ninf nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_maxnum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.maxnum.f32(float %a, float %b) nounwind readnone
  br label %test_maxnum.exit

test_maxnum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi ninf nsz float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @minimum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-MVE-LABEL: @minimum_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minimum.f32(float [[A]], float [[B:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @minimum_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minimum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @minimum_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.minimum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select reassoc i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_minimum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.minimum.f32(float %a, float %b) nounwind readnone
  br label %test_minimum.exit

test_minimum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi reassoc float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}

define void @maximum_test(ptr addrspace(1) noalias nocapture %out, float %a, float %b) nounwind {
; CHECK-MVE-LABEL: @maximum_test(
; CHECK-MVE-NEXT:  entry:
; CHECK-MVE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-MVE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maximum.f32(float [[A]], float [[B:%.*]]) #[[ATTR3]]
; CHECK-MVE-NEXT:    [[COND_I:%.*]] = select nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-MVE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-MVE-NEXT:    ret void
;
; CHECK-V8M-MAIN-LABEL: @maximum_test(
; CHECK-V8M-MAIN-NEXT:  entry:
; CHECK-V8M-MAIN-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-MAIN-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maximum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-MAIN-NEXT:    [[COND_I:%.*]] = select nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-MAIN-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-MAIN-NEXT:    ret void
;
; CHECK-V8M-BASE-LABEL: @maximum_test(
; CHECK-V8M-BASE-NEXT:  entry:
; CHECK-V8M-BASE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[A:%.*]], 0.000000e+00
; CHECK-V8M-BASE-NEXT:    [[TMP0:%.*]] = tail call float @llvm.maximum.f32(float [[A]], float [[B:%.*]]) #[[ATTR2]]
; CHECK-V8M-BASE-NEXT:    [[COND_I:%.*]] = select nsz i1 [[CMP_I]], float 0x7FF8000000000000, float [[TMP0]]
; CHECK-V8M-BASE-NEXT:    store float [[COND_I]], ptr addrspace(1) [[OUT:%.*]], align 4
; CHECK-V8M-BASE-NEXT:    ret void
;
entry:
  %cmp.i = fcmp olt float %a, 0.000000e+00
  br i1 %cmp.i, label %test_maximum.exit, label %cond.else.i

cond.else.i:                                      ; preds = %entry
  %0 = tail call float @llvm.maximum.f32(float %a, float %b) nounwind readnone
  br label %test_maximum.exit

test_maximum.exit:                                   ; preds = %cond.else.i, %entry
  %cond.i = phi nsz float [ %0, %cond.else.i ], [ 0x7FF8000000000000, %entry ]
  store float %cond.i, ptr addrspace(1) %out, align 4
  ret void
}
