//
//  RawWrapper.h
//  Imagin Bridge
//
//  Created by Cristian Baluta on 29.01.2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RawWrapper : NSObject

+ (instancetype)shared;
- (nullable NSData *)extractEmbeddedJPEG:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
