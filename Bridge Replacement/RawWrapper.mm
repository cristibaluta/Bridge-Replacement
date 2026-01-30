#import "RawWrapper.h"
#include "libraw/libraw.h"

@implementation RawWrapper

- (NSData *)extractEmbeddedJPEG:(NSString *)path {
    LibRaw raw;
    int ret;

    ret = raw.open_file(path.UTF8String);
    if (ret != LIBRAW_SUCCESS) {
        return nil;
    }

    ret = raw.unpack_thumb();
    if (ret != LIBRAW_SUCCESS) {
        raw.recycle();
        return nil;
    }

    libraw_processed_image_t *thumb = raw.dcraw_make_mem_thumb();
    if (!thumb || thumb->type != LIBRAW_IMAGE_JPEG) {
        raw.recycle();
        return nil;
    }

    NSData *jpegData = [NSData dataWithBytes:thumb->data
                                       length:thumb->data_size];

    LibRaw::dcraw_clear_mem(thumb);
    raw.recycle();

    return jpegData;
}

@end
