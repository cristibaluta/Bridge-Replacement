
#import "RawWrapper.h"
#include "../libraw/libraw.h"

@implementation RawWrapper

+ (instancetype)shared {
    static RawWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (dispatch_queue_t)librawQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("ro.imagin.libraw", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (NSData *)extractEmbeddedJPEG:(NSString *)path {
    __block NSData *result = nil;

    dispatch_sync([[self class] librawQueue], ^{
        result = [self _extractEmbeddedJPEGSynchronized:path];
    });

    return result;
}

- (NSData *)_extractEmbeddedJPEGSynchronized:(NSString *)path {
    // Use heap allocation to ensure LibRaw constructor is called within serialized context
    LibRaw *raw = new LibRaw();
    NSData *result = nil;

    @try {
        int ret = raw->open_file(path.UTF8String);
        if (ret != LIBRAW_SUCCESS) {
            delete raw;
            return nil;
        }

        ret = raw->unpack_thumb();
        if (ret != LIBRAW_SUCCESS) {
            raw->recycle();
            delete raw;
            return nil;
        }

        libraw_processed_image_t *thumb = raw->dcraw_make_mem_thumb();
        if (!thumb || thumb->type != LIBRAW_IMAGE_JPEG) {
            raw->recycle();
            delete raw;
            return nil;
        }

        result = [NSData dataWithBytes:thumb->data length:thumb->data_size];

        LibRaw::dcraw_clear_mem(thumb);
        raw->recycle();
        delete raw;
    }
    @catch (NSException *exception) {
        if (raw) {
            raw->recycle();
            delete raw;
        }
        NSLog(@"LibRaw exception: %@", exception);
        result = nil;
    }

    return result;
}

@end
