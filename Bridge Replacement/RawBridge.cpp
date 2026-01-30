//
//  RawBridge.cpp
//  Imagin Bridge
//
//  Created by Cristian Baluta on 30.01.2026.
//


// RawBridge.cpp
#include "libraw/libraw.h"
#include <stdlib.h>
#include <string.h>

extern "C" bool libraw_extract_thumb_cpp(
    const char *path,
    uint8_t **outData,
    size_t *outSize
) {
    LibRaw raw;

    if (raw.open_file(path) != LIBRAW_SUCCESS) {
        return false;
    }

    if (raw.unpack_thumb() != LIBRAW_SUCCESS) {
        raw.recycle();
        return false;
    }

    libraw_processed_image_t *thumb = raw.dcraw_make_mem_thumb();
    if (!thumb) {
        raw.recycle();
        return false;
    }

    *outSize = thumb->data_size;
    *outData = (uint8_t *)malloc(*outSize);
    memcpy(*outData, thumb->data, *outSize);

    LibRaw::dcraw_clear_mem(thumb);
    raw.recycle();

    return true;
}
