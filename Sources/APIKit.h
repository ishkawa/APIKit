#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double APIKitVersionNumber;
FOUNDATION_EXPORT const unsigned char APIKitVersionString[];

@interface AbstractInputStream : NSInputStream

// Workaround for http://www.openradar.me/19809067
// This issue only occurs on iOS 8
- (instancetype)init;

@end
