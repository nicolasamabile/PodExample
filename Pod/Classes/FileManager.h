//
//  FileManager.h
//  Pods
//
//  Created by administrador on 10/2/15.
//
//

#import <Foundation/Foundation.h>
@class Image;
@class KSPromise;

@interface FileManager : NSObject
- (KSPromise *) existImage: (Image*)image;
- (KSPromise *) getImage: (Image*)image;
- (KSPromise *) saveImage: (NSString *)url imageToSave:(NSData *)imageToSave;
@end