//
//  Macros.h
//  Helper
//
//  Created by Shaojun Han on 9/29/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#ifndef MACROS

#ifnden SingleKeywordify

#define macro_concat_(A, B) A ## B
#define macro_head_(FIRST, ...) FIRST

// macro_at expansions
#define macro_at0(...) macro_head(__VA_ARGS__)
#define macro_at1(_0, ...) macro_head(__VA_ARGS__)
#define macro_at2(_0, _1, ...) macro_head(__VA_ARGS__)
#define macro_at3(_0, _1, _2, ...) macro_head(__VA_ARGS__)
#define macro_at4(_0, _1, _2, _3, ...) macro_head(__VA_ARGS__)
#define macro_at5(_0, _1, _2, _3, _4, ...) macro_head(__VA_ARGS__)
#define macro_at6(_0, _1, _2, _3, _4, _5, ...) macro_head(__VA_ARGS__)
#define macro_at7(_0, _1, _2, _3, _4, _5, _6, ...) macro_head(__VA_ARGS__)
#define macro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...) macro_head(__VA_ARGS__)
#define macro_at9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) macro_head(__VA_ARGS__)
#define macro_at10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) macro_head(__VA_ARGS__)
#define macro_at11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) macro_head(__VA_ARGS__)
#define macro_at12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) macro_head(__VA_ARGS__)
#define macro_at13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) macro_head(__VA_ARGS__)
#define macro_at14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) macro_head(__VA_ARGS__)
#define macro_at15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) macro_head(__VA_ARGS__)
#define macro_at16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) macro_head(__VA_ARGS__)
#define macro_at17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) macro_head(__VA_ARGS__)
#define macro_at18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) macro_head(__VA_ARGS__)
#define macro_at19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) macro_head(__VA_ARGS__)
#define macro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) macro_head(__VA_ARGS__)


// macro_foreach_cxt expansions
#define macro_foreach_cxt0(MACRO, SEP, CONTEXT)
#define macro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) MACRO(0, CONTEXT, _0)

#define macro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
macro_foreach_cxt1(MACRO, SEP, CONTEXT, _0) \
SEP \
MACRO(1, CONTEXT, _1)

#define macro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
macro_foreach_cxt2(MACRO, SEP, CONTEXT, _0, _1) \
SEP \
MACRO(2, CONTEXT, _2)

#define macro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
macro_foreach_cxt3(MACRO, SEP, CONTEXT, _0, _1, _2) \
SEP \
MACRO(3, CONTEXT, _3)

#define macro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
macro_foreach_cxt4(MACRO, SEP, CONTEXT, _0, _1, _2, _3) \
SEP \
MACRO(4, CONTEXT, _4)

#define macro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
macro_foreach_cxt5(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4) \
SEP \
MACRO(5, CONTEXT, _5)

#define macro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
macro_foreach_cxt6(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5) \
SEP \
MACRO(6, CONTEXT, _6)

#define macro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
macro_foreach_cxt7(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6) \
SEP \
MACRO(7, CONTEXT, _7)

#define macro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
macro_foreach_cxt8(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7) \
SEP \
MACRO(8, CONTEXT, _8)

#define macro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
macro_foreach_cxt9(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8) \
SEP \
MACRO(9, CONTEXT, _9)

#define macro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
macro_foreach_cxt10(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9) \
SEP \
MACRO(10, CONTEXT, _10)

#define macro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
macro_foreach_cxt11(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) \
SEP \
MACRO(11, CONTEXT, _11)

#define macro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
macro_foreach_cxt12(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) \
SEP \
MACRO(12, CONTEXT, _12)

#define macro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
macro_foreach_cxt13(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) \
SEP \
MACRO(13, CONTEXT, _13)

#define macro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
macro_foreach_cxt14(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) \
SEP \
MACRO(14, CONTEXT, _14)

#define macro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
macro_foreach_cxt15(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) \
SEP \
MACRO(15, CONTEXT, _15)

#define macro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
macro_foreach_cxt16(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15) \
SEP \
MACRO(16, CONTEXT, _16)

#define macro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
macro_foreach_cxt17(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16) \
SEP \
MACRO(17, CONTEXT, _17)

#define macro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
macro_foreach_cxt18(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17) \
SEP \
MACRO(18, CONTEXT, _18)

#define macro_foreach_cxt20(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19) \
macro_foreach_cxt19(MACRO, SEP, CONTEXT, _0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
SEP \
MACRO(19, CONTEXT, _19)

/**
 * Returns the first argument given. At least one argument must be provided.
 *
 * This is useful when implementing a variadic macro, where you may have only
 * one variadic argument, but no way to retrieve it (for example, because \c ...
 * always needs to match at least one argument).
 *
 * @code
 
 #define varmacro(...) \
 macro_head(__VA_ARGS__)
 
 * @endcode
 */
#define macro_head(...) \
macro_head_(__VA_ARGS__, 0)

/**
 * Returns the Nth variadic argument (starting from zero). At least
 * N + 1 variadic arguments must be given. N must be between zero and twenty,
 * inclusive.
 */
#define macro_at(N, ...) \
macro_concat(macro_at, N)(__VA_ARGS__)

/**
 * Returns the number of arguments (up to twenty) provided to the macro. At
 * least one argument must be provided.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define macro_argcount(...) \
macro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)

/**
 * Returns A and B concatenated after full macro expansion.
 */
#define macro_concat(A, B) \
macro_concat_(A, B)

/**
 * For each consecutive variadic argument (up to twenty), MACRO is passed the
 * zero-based index of the current argument, CONTEXT, and then the argument
 * itself. The results of adjoining invocations of MACRO are then separated by
 * SEP.
 *
 * Inspired by P99: http://p99.gforge.inria.fr
 */
#define macro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
macro_concat(macro_foreach_cxt, macro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

/**
 * Creates \c __weak shadow variables for each of the variables provided as
 * arguments, which can later be made strong again with #strongify.
 *
 * This is typically used to weakly reference variables in a block, but then
 * ensure that the variables stay alive during the actual execution of the block
 * (if they were live upon entry).
 *
 * See #strongify for an example of usage.
 */
#define weakify(...) \
rac_keywordify \
macro_foreach_cxt(rac_weakify_,, __weak, __VA_ARGS__)

/**
 * Like #weakify, but uses \c __unsafe_unretained instead, for targets or
 * classes that do not support weak references.
 */
#define unsafeify(...) \
rac_keywordify \
macro_foreach_cxt(rac_weakify_,, __unsafe_unretained, __VA_ARGS__)

/**
 * Strongly references each of the variables provided as arguments, which must
 * have previously been passed to #weakify.
 *
 * The strong references created will shadow the original variable names, such
 * that the original names can be used without issue (and a significantly
 * reduced risk of retain cycles) in the current scope.
 *
 * @code
 
 id foo = [[NSObject alloc] init];
 id bar = [[NSObject alloc] init];
 
 @weakify(foo, bar);
 
 // this block will not keep 'foo' or 'bar' alive
 BOOL (^matchesFooOrBar)(id) = ^ BOOL (id obj){
 // but now, upon entry, 'foo' and 'bar' will stay alive until the block has
 // finished executing
 @strongify(foo, bar);
 
 return [foo isEqual:obj] || [bar isEqual:obj];
 };
 
 * @endcode
 */
#define strongify(...) \
rac_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
macro_foreach_cxt(rac_strongify_,, __strong, __VA_ARGS__) \
_Pragma("clang diagnostic pop")

#define rac_weakify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) macro_concat(VAR, _weak_) = (VAR);

#define rac_strongify_(INDEX, CONTEXT, VAR) \
CONTEXT __typeof__(VAR) VAR = macro_concat(VAR, _weak_);

// Details about the choice of backing keyword:
//
// The use of @try/@catch/@finally can cause the compiler to suppress
// return-type warnings.
// The use of @autoreleasepool {} is not optimized away by the compiler,
// resulting in superfluous creation of autorelease pools.
//
// Since neither option is perfect, and with no other alternatives, the
// compromise is to use @autorelease in DEBUG builds to maintain compiler
// analysis, and to use @try/@catch otherwise to avoid insertion of unnecessary
// autorelease pools.
#if DEBUG
#define rac_keywordify autoreleasepool {}
#else
#define rac_keywordify try {} @catch (...) {}
#endif

#else SingleKeywordify

#define weakify(obj) \
rac_keywordify \
__weak __typeof__(obj) obj##_weak_ = obj;

#define strongify(obj) \
rac_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(obj) obj = obj##_weak_; \
_Pragma("clang diagnostic pop")

#ifdef DEBUG
#define rac_keywordify autoreleasepool {}
#else
#define rac_keywordify try {} @catch(...) {}
#endif

#endif

#endif