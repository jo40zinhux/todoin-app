#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppGroupDirectoryPlugin.h"

FOUNDATION_EXPORT double app_group_directoryVersionNumber;
FOUNDATION_EXPORT const unsigned char app_group_directoryVersionString[];

