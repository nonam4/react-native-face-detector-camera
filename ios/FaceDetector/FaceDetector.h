#import <UIKit/UIKit.h>
#import <GoogleMLKit/MLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceDetector : NSObject

- (instancetype)initWithOptions:(MLKFaceDetectorOptions *)options;
- (void)detectFromImage:(UIImage *)image
     completionListener:(void(^)(NSArray<MLKFace *> *faces, NSError* error)) completion;
- (void)detectFromBuffer:(CMSampleBufferRef)buffer
             orientation:(UIImageOrientation)orientation
      completionListener:(void(^)(NSArray<MLKFace *> *faces, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
