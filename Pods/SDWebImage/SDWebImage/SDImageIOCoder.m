/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageIOCoder.h"
#import "SDImageCoderHelper.h"
#import "NSImage+Compatibility.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+Metadata.h"

@implementation SDImageIOCoder {
    size_t _width, _height;
    CGImagePropertyOrientation _orientation;
    CGImageSourceRef _imageSource;
    CGFloat _scale;
    BOOL _finished;
}

- (void)dealloc {
    if (_imageSource) {
        CFRelease(_imageSource);
        _imageSource = NULL;
    }
#if SD_UIKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification
{
    if (_imageSource) {
        CGImageSourceRemoveCacheAtIndex(_imageSource, 0);
    }
}

+ (instancetype)sharedCoder {
    static SDImageIOCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDImageIOCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(nullable NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP decoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        default:
            return YES;
    }
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(nullable SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    CGFloat scale = 1;
    if ([options valueForKey:SDImageCoderDecodeScaleFactor]) {
        scale = [[options valueForKey:SDImageCoderDecodeScaleFactor] doubleValue];
        if (scale < 1) {
            scale = 1;
        }
    }
    
    UIImage *image = [[UIImage alloc] initWithData:data scale:scale];
    image.sd_imageFormat = [NSData sd_imageFormatForImageData:data];
    return image;
}

#pragma mark - Progressive Decode

- (BOOL)canIncrementalDecodeFromData:(NSData *)data {
    switch ([NSData sd_imageFormatForImageData:data]) {
        case SDImageFormatWebP:
            // Do not support WebP progressive decoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC decoding compatibility
            return [[self class] canDecodeFromHEICFormat];
        default:
            return YES;
    }
}

- (instancetype)initIncrementalWithOptions:(nullable SDImageCoderOptions *)options {
    self = [super init];
    if (self) {
        _imageSource = CGImageSourceCreateIncremental(NULL);
        CGFloat scale = 1;
        if ([options valueForKey:SDImageCoderDecodeScaleFactor]) {
            scale = [[options valueForKey:SDImageCoderDecodeScaleFactor] doubleValue];
            if (scale < 1) {
                scale = 1;
            }
        }
        _scale = scale;
#if SD_UIKIT
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)updateIncrementalData:(NSData *)data finished:(BOOL)finished {
    if (_finished) {
        return;
    }
    _finished = finished;
    
    // The following code is from http://www.cocoaintheshell.com/2011/05/progressive-images-download-imageio/
    // Thanks to the author @Nyx0uf
    
    // Update the data source, we must pass ALL the data, not just the new bytes
    CGImageSourceUpdateData(_imageSource, (__bridge CFDataRef)data, finished);
    
    if (_width + _height == 0) {
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(_imageSource, 0, NULL);
        if (properties) {
            NSInteger orientationValue = 1;
            CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_height);
            val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
            if (val) CFNumberGetValue(val, kCFNumberLongType, &_width);
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
            CFRelease(properties);
            
            // When we draw to Core Graphics, we lose orientation information,
            // which means the image below born of initWithCGIImage will be
            // oriented incorrectly sometimes. (Unlike the image born of initWithData
            // in didCompleteWithError.) So save it here and pass it on later.
            _orientation = (CGImagePropertyOrientation)orientationValue;
        }
    }
}

- (UIImage *)incrementalDecodedImageWithOptions:(SDImageCoderOptions *)options {
    UIImage *image;
    
    if (_width + _height > 0) {
        // Create the image
        CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(_imageSource, 0, NULL);
        
        if (partialImageRef) {
            CGFloat scale = _scale;
            if ([options valueForKey:SDImageCoderDecodeScaleFactor]) {
                scale = [[options valueForKey:SDImageCoderDecodeScaleFactor] doubleValue];
                if (scale < 1) {
                    scale = 1;
                }
            }
#if SD_UIKIT || SD_WATCH
            UIImageOrientation imageOrientation = [SDImageCoderHelper imageOrientationFromEXIFOrientation:_orientation];
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:scale orientation:imageOrientation];
#else
            image = [[UIImage alloc] initWithCGImage:partialImageRef scale:scale orientation:_orientation];
#endif
            CGImageRelease(partialImageRef);
            CFStringRef uttype = CGImageSourceGetType(_imageSource);
            image.sd_imageFormat = [NSData sd_imageFormatFromUTType:uttype];
        }
    }
    
    return image;
}

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    switch (format) {
        case SDImageFormatWebP:
            // Do not support WebP encoding
            return NO;
        case SDImageFormatHEIC:
            // Check HEIC encoding compatibility
            return [[self class] canEncodeToHEICFormat];
        default:
            return YES;
    }
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format options:(nullable SDImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    
    if (format == SDImageFormatUndefined) {
        BOOL hasAlpha = [SDImageCoderHelper CGImageContainsAlpha:image.CGImage];
        if (hasAlpha) {
            format = SDImageFormatPNG;
        } else {
            format = SDImageFormatJPEG;
        }
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromImageFormat:format];
    
    // Create an image destination.
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
#if SD_UIKIT || SD_WATCH
    CGImagePropertyOrientation exifOrientation = [SDImageCoderHelper exifOrientationFromImageOrientation:image.imageOrientation];
#else
    CGImagePropertyOrientation exifOrientation = kCGImagePropertyOrientationUp;
#endif
    [properties setValue:@(exifOrientation) forKey:(__bridge NSString *)kCGImagePropertyOrientation];
    double compressionQuality = 1;
    if ([options valueForKey:SDImageCoderEncodeCompressionQuality]) {
        compressionQuality = [[options valueForKey:SDImageCoderEncodeCompressionQuality] doubleValue];
    }
    [properties setValue:@(compressionQuality) forKey:(__bridge NSString *)kCGImageDestinationLossyCompressionQuality];
    
    // Add your image to the destination.
    CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

+ (BOOL)canDecodeFromHEICFormat {
    static BOOL canDecode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_SIMULATOR || SD_WATCH
        canDecode = NO;
#else
        if (@available(iOS 11.0, tvOS 11.0, macOS 10.13, *)) {
            canDecode = YES;
        } else {
            canDecode = NO;
        }
#endif
    });
    return canDecode;
}

+ (BOOL)canEncodeToHEICFormat {
    static BOOL canEncode = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableData *imageData = [NSMutableData data];
        CFStringRef imageUTType = [NSData sd_UTTypeFromImageFormat:SDImageFormatHEIC];
        
        // Create an image destination.
        CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, 1, NULL);
        if (!imageDestination) {
            // Can't encode to HEIC
            canEncode = NO;
        } else {
            // Can encode to HEIC
            CFRelease(imageDestination);
            canEncode = YES;
        }
    });
    return canEncode;
}

@end
