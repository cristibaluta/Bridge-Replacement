//
//  RawWrapper.h
//  Imagin Raw
//
//  Created by Cristian Baluta on 29.01.2026.
//

#import <Foundation/Foundation.h>
#import "RawPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface RawWrapper : NSObject

+ (instancetype)shared;
- (nullable RawPhoto *)extractRawPhoto:(NSString *)path;
- (nullable NSData *)extractEmbeddedJPEG:(NSString *)path; // Keep for backward compatibility
- (nullable NSDictionary *)extractMetadata:(NSString *)path; // Extract rating, width, and height (returns @{@"rating": NSNumber, @"width": NSNumber, @"height": NSNumber})

@end

NS_ASSUME_NONNULL_END
