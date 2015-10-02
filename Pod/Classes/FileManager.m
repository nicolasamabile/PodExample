//
//  FileManager.m
//  Pods
//
//  Created by Nicolas Amabile on 10/2/15.
//
//


#import "FileManager.h"
#import "KSDeferred.h"
#import "Image.h"
#import "KSPromise.h"

@interface FileManager ()
@property(nonatomic) dispatch_queue_t fileManagerQueue;
@property(nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSString *directoryPath;
@end

@implementation FileManager

- (instancetype) init {
    if(self = [super init]) {
        self.fileManagerQueue = dispatch_queue_create("com.oktana.fileManager.queue", nil); 
        self.fileManager    = [NSFileManager defaultManager];
        self.directoryPath = [self directory];
    }
    return self;
}

- (NSString *)getURL: (NSString *)imageURL{
    NSURL * document = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    document = [document URLByAppendingPathComponent:@"myFolder"];
    return [NSString stringWithFormat:@"%@/%@",[document path],imageURL];
}

- (KSPromise *)checkImageExist: (Image *) image{
    KSDeferred *deferred = [KSDeferred defer];
    dispatch_async(self.fileManagerQueue , ^{
        BOOL fileExists = [self.fileManager fileExistsAtPath: [self getURL: image.imageLocalURL] isDirectory:NO];
        [deferred resolveWithValue:[NSNumber numberWithBool:fileExists]];
    });
    return deferred.promise;
}

- (KSPromise *) existImage: (Image*)image{
    KSDeferred *deferred = [KSDeferred defer];
    if(image.imageLocalURL){
        [[self checkImageExist:image]then:^id(id value) {
            [deferred resolveWithValue:value];
            return value;
        } error:^id(NSError *error) {
            [deferred rejectWithError:error];
            return error;
        }];
    }else{
        [deferred resolveWithValue:[NSNumber numberWithBool:false]];
    }
    return deferred.promise;
}

- (KSPromise *) getImage: (Image*)image{
    KSDeferred *deferred = [KSDeferred defer];
    dispatch_async(self.fileManagerQueue , ^{
        NSData *loadedImage = [self.fileManager contentsAtPath:[self getURL: image.imageLocalURL]];
        [deferred resolveWithValue:loadedImage];
    });
    return deferred.promise;
}

- (KSPromise *) saveImage: (NSString *)url imageToSave:(NSData *)imageToSave{
    KSDeferred *deferred = [KSDeferred defer];
    NSString *directory = self.directoryPath;
    NSString *newURL = [url substringToIndex:[url length]-10];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", directory,newURL];
    dispatch_async(self.fileManagerQueue , ^{
        if([self.fileManager createFileAtPath:filePath contents:imageToSave attributes:nil]){
            [deferred resolveWithValue:newURL];
        }else{
            NSLog(@"ERROR");
        }
    });
    return deferred.promise;
}

- (NSString *) directory{
    NSURL * document = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    document = [document URLByAppendingPathComponent:@"myFolder"];
    if (![self.fileManager fileExistsAtPath:[document path]]) {
        [self.fileManager createDirectoryAtPath:[document path] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [document path];
}


@end
