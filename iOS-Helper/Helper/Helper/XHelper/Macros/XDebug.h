//
//  XDebug.h
//  Helper
//
//  Created by Shaojun Han on 10/15/16.
//  Copyright © 2016 Hadlinks. All rights reserved.
//

#ifndef XDebug_h
#define XDebug_h

#define XDebug(MACRO, Block) \
    #ifdef MACRO
        #Block
    #endif

#ifdef DEBUG
#define xdebug_keywordify autoreleasepool {}
#else
#define xdebug_keywordify try {} @catch(...) {}
#endif

#endif /* XDebug_h */
