//
//  FPLibrary.m
//  FPPicker
//
//  Created by Liyan David Chang on 6/20/12.
//  Copyright (c) 2012 Filepicker.io (Cloudtop Inc), All rights reserved.
//

#import <LFJSONKit/JSONKit.h>
#import "FPLibrary.h"
#import "FPConstants.h"
#import "FPInternalHeaders.h"
#import "FPProgressTracker.h"


NSDictionary* FPDictionaryFromJSONInfoPhoto(id JSON, UIImage* image, NSURL *localurl) {
    id dataFirst = [[JSON objectForKey:@"data"] objectAtIndex:0];
    id dataFirstData = [dataFirst objectForKey:@"data"];
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            (NSString*) kUTTypeImage, FPPickerControllerMediaType,
            image, FPPickerControllerOriginalImage,
            localurl, FPPickerControllerMediaURL,
            [dataFirst objectForKey:@"url"], FPPickerControllerRemoteURL,
            [dataFirstData objectForKey:@"filename"], FPPickerControllerFilename,
            [dataFirstData objectForKey:@"key"], FPPickerControllerKey,
            nil];
}

NSDictionary* FPDictionaryFromJSONInfoPhotoFailure(UIImage* image, NSURL *localurl, NSString* filename) {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            (NSString*) kUTTypeImage, FPPickerControllerMediaType,
            image, FPPickerControllerOriginalImage,
            localurl, FPPickerControllerMediaURL,
            @"", FPPickerControllerRemoteURL,
            filename, FPPickerControllerFilename,
            nil];
}

NSDictionary* FPDictionaryFromJSONInfoVideo(id JSON, NSURL *localurl) {
    id dataFirst = [[JSON objectForKey:@"data"] objectAtIndex:0];
    id dataFirstData = [dataFirst objectForKey:@"data"];
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            (NSString *) kUTTypeVideo, FPPickerControllerMediaType,
            localurl, FPPickerControllerMediaURL,
            [dataFirst objectForKey:@"url"], FPPickerControllerRemoteURL,
            [dataFirstData objectForKey:@"filename"], FPPickerControllerFilename,
            [dataFirstData objectForKey:@"key"], FPPickerControllerKey,
            nil];
}

NSDictionary* FPDictionaryFromJSONInfoVideoFailure(NSURL *localurl, NSString* filename) {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            (NSString *) kUTTypeVideo , FPPickerControllerMediaType,
            localurl, FPPickerControllerMediaURL,
            @"", FPPickerControllerRemoteURL,
            filename, FPPickerControllerFilename,
            nil];
}

static NSString* buildSessionString()
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:fpPARAMS];
    [parameters setObject:fpAPIKEY forKey:@"apikey"];
    return [[NSDictionary dictionaryWithObject:parameters forKey:@"app"] JSONString];
}


@implementation FPLibrary

+ (void) uploadDataToFilepicker:(NSURL*) fileURL
                          named:(NSString*) filename
                     ofMimetype:(NSString*) mimetype
                   shouldUpload:(BOOL) shouldUpload
                        success:(void (^)(id JSON))success
                        failure:(void (^)(NSError *error, id JSON)) failure
                       progress:(void (^)(float progress))progress
{
    
    if (!shouldUpload){
        NSLog(@"Not Uploading");
        NSError *error = [NSError errorWithDomain:@"io.filepicker" code:200 userInfo:[[NSDictionary alloc] init]];
        id JSON = [[NSDictionary alloc] init];
        failure(error, JSON);
        return;
    }
    
    NSData *filedata = [NSData dataWithContentsOfURL:fileURL];

    NSInteger filesize = [filedata length];

    if (filesize <= fpMaxChunkSize){
        NSLog(@"Uploading singlepart");

        [FPLibrary singlepartUploadData:filedata named:filename ofMimetype:mimetype success:success failure:failure progress:progress];
    } else {
        NSLog(@"Uploading Multipart");
        [FPLibrary multipartUploadData:filedata named:filename ofMimetype:mimetype success:success failure:failure progress:progress];
    }
    
}

//single file upload
+ (void) singlepartUploadData:(NSData*) filedata
                       named:(NSString*) filename
                  ofMimetype:(NSString*) mimetype
                     success:(void (^)(id JSON))success
                     failure:(void (^)(NSError *error, id JSON)) failure
                     progress:(void (^)(float progress))progress
{
    NSURL *url = [NSURL URLWithString: fpBASE_URL];
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *js_sessionString = buildSessionString();
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            js_sessionString, @"js_session",
                            nil];
    
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/api/path/computer/" parameters:params constructingBodyWithBlock: ^(id <FPAFMultipartFormData>formData) {
        [formData appendPartWithFileData:filedata name:@"fileUpload" fileName:filename mimeType:mimetype];
    }];
    
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([@"ok" isEqual:[JSON valueForKey:@"result"]]){
            success(JSON);
        } else {
            failure([[NSError alloc] initWithDomain:FPPickerDomain code:0 userInfo:nil], JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error, JSON);
    }];
    
    if (progress) {
        [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
            if (totalBytesExpectedToWrite > 0) {
                progress(((float)totalBytesWritten)/totalBytesExpectedToWrite);
            }
        }];
    }
    
    [operation start];
    
}

//multipart
+ (void) multipartUploadData:(NSData*) filedata
                       named:(NSString*) filename
                  ofMimetype:(NSString*) mimetype
                     success:(void (^)(id JSON))success
                     failure:(void (^)(NSError *error, id JSON)) failure
                     progress:(void (^)(float progress))progress
{
    NSInteger filesize = [filedata length];
    NSInteger numOfChunks = ceil(1.0*filesize/fpMaxChunkSize);
    NSLog(@"Filesize: %ld chuncks: %ld", (long)filesize, (long)numOfChunks);
    
    NSURL *url = [NSURL URLWithString: fpBASE_URL];
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *js_sessionString = buildSessionString();
    
    /* begin multipart */
    if (filename == nil){
        filename = @"filename";
    }
    NSDictionary *start_params = [NSDictionary dictionaryWithObjectsAndKeys:
                                  filename, @"name",
                                  [NSNumber numberWithInteger:filesize], @"filesize",
                                  js_sessionString, @"js_session",
                                  nil];

    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/api/path/computer/?multipart=start" parameters:start_params];
    
    
    void (^beginPartSuccess)(NSURLRequest*, NSHTTPURLResponse*, id) =  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Response: %@", JSON);
        NSString* upload_id = [[JSON valueForKey:@"data"] valueForKey:@"id"];
        
        
        
        void (^endMultipart)() = ^(){
            __block int numberOfTriesFinish = 0;
            
            NSDictionary *end_params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        upload_id, @"id",
                                        [NSNumber numberWithInteger:numOfChunks], @"total",
                                        js_sessionString, @"js_session",
                                        nil];
            
            NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/api/path/computer/?multipart=end" parameters:end_params];
            
            void (^endPartSuccess)(NSURLRequest*, NSHTTPURLResponse*, id) =  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"DONE!: %@", JSON);
                success(JSON);
            };
            
            __block void (^endPartFail) (NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-retain-cycles"
            endPartFail = [^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (numberOfTriesFinish >= fpNumRetries){
                    NSLog(@"failed at the end: %@ %@", error, JSON);
                    failure(error, JSON);
                } else {
                    numberOfTriesFinish += 1;
                    [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:endPartSuccess failure:endPartFail] start];
                }
            } copy];
            #pragma clang diagnostic pop
            
            [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:endPartSuccess failure:endPartFail] start];
        };
        
        
        
        
        FPProgressTracker* progressTracker = [[FPProgressTracker alloc] initWithObjectCount:numOfChunks];
        __block int numberSent = 0;
        /* send the chunks */
        for (int i = 0; i<numOfChunks; i++){
            
            
            NSDictionary *params = [[NSDictionary alloc] init];
            
            NSString *uploadPath = [NSString stringWithFormat:@"/api/path/computer/?multipart=upload&id=%@&index=%d&js_session=%@", upload_id, i, [js_sessionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
            NSLog(@"Sending slice #%d", i);
            
            NSData *slice;
            if (i == numOfChunks -1){            
                NSInteger finalPartSize = filesize - i*fpMaxChunkSize;
                slice = [NSData dataWithBytesNoCopy:(void*)[[filedata subdataWithRange:NSMakeRange(i*fpMaxChunkSize, finalPartSize)] bytes]  length:finalPartSize freeWhenDone:NO];
            } else {
                slice = [NSData dataWithBytesNoCopy:(void*)[[filedata subdataWithRange:NSMakeRange(i*fpMaxChunkSize, fpMaxChunkSize)] bytes]  length:fpMaxChunkSize freeWhenDone:NO];
            }
            
            NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:uploadPath parameters:params constructingBodyWithBlock: ^(id <FPAFMultipartFormData>formData) {
                [formData appendPartWithFileData:slice name:@"fileUpload" fileName:filename mimeType:mimetype];
            }];
            [request setHTTPShouldUsePipelining:YES];
            
            
            void (^onePartSuccess)(NSURLRequest*, NSHTTPURLResponse*, id) =  ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                numberSent += 1;
                
                if (progress) {
                    float overallProgress = [progressTracker setProgress:1.f forKey:[NSNumber numberWithInt:i]];
                    progress(overallProgress);
                }
                
                NSLog(@"Send %d: %@ (sent: %d)", i, JSON, numberSent);
                if (numberSent == numOfChunks ){
                    endMultipart();
                }
            };
            
            __block int numberOfTries = 0;
            __block void (^onePartFail)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-retain-cycles"
            onePartFail =  [^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (numberOfTries > fpNumRetries){
                    NSLog(@"Fail: %@ %@", error, JSON);
                    failure(error, JSON);
                } else {
                    NSLog(@"Retrying part %d time: %d", i, numberOfTries);
                    numberOfTries += 1;
                    [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:onePartSuccess failure:onePartFail] start];
                }
            } copy];
            #pragma clang diagnostic pop
            
            FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:onePartSuccess failure:onePartFail];
            if (progress) {
                [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
                    if (totalBytesExpectedToWrite > 0) {
                        float overallProgress = [progressTracker setProgress:((float)totalBytesWritten)/totalBytesExpectedToWrite forKey:[NSNumber numberWithInt:i]];
                        progress(overallProgress);
                    }
                }];
            }
            [operation start];
        };
    };
    
    __block int numberOfTriesBegin = 0;
    __block void (^beginPartFail) (NSURLRequest *, NSHTTPURLResponse *, NSError *, id);
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
    beginPartFail =  [^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (numberOfTriesBegin > fpNumRetries){
            NSLog(@"Response error: %@ %@", error, JSON);
            failure(error, JSON);
        } else {
            numberOfTriesBegin += 1;
            [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:beginPartSuccess failure:beginPartFail] start];
        }
    } copy];
    #pragma clang diagnostic pop
    
    [[FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:beginPartSuccess failure:beginPartFail] start];
    

}



#pragma mark camera upload

+ (void) uploadImage:(UIImage*)image
          ofMimetype:(NSString*)mimetype
         withOptions:(NSDictionary*)options
        shouldUpload:(BOOL) shouldUpload
             success:(void (^)(id JSON, NSURL *localurl))success 
             failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
            progress:(void (^)(float progress))progress
{
    
    NSString *filename;
    NSData *filedata;
    
    DONT_BLOCK_UI();
    
    image = [FPLibrary rotateImage:image];
    
    if ([mimetype isEqualToString:@"image/png"]){
        filedata = UIImagePNGRepresentation(image);
        filename = @"camera.png";
    } else {
        filedata = UIImageJPEGRepresentation(image, 0.6);
        filename = @"camera.jpg";
        mimetype = @"image/jpeg";
    }
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPLibrary genRandStringLength:20]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    [filedata writeToURL:tempURL atomically:YES];
    
    [FPLibrary uploadDataToFilepicker:tempURL named: filename ofMimetype:mimetype shouldUpload:shouldUpload success:^(id JSON) {
        success(JSON, tempURL);
    } failure:^(NSError *error, id JSON) {
        NSLog(@"FAILTURE %@ %@", error, JSON);
        failure(error, JSON, tempURL);
    } progress:progress];
    
}

+ (void) uploadVideoURL: (NSURL*) url
            withOptions:(NSDictionary*)options
           shouldUpload:(BOOL) shouldUpload
                success:(void (^)(id JSON, NSURL *localurl))success 
                failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
               progress:(void (^)(float progress))progress
{
    
    NSString *filename = @"movie.MOV";
    NSString * mimetype = @"video/quicktime";
    
    [FPLibrary uploadDataToFilepicker:url named: filename ofMimetype:mimetype shouldUpload:shouldUpload success:^(id JSON) {
        success(JSON, url);
    } failure:^(NSError *error, id JSON) {
        NSLog(@"FAILTURE %@ %@", error, JSON);
        failure(error, JSON, url);
    } progress:progress];

}

#pragma mark local source controller

+ (void) uploadAsset:(ALAsset*)asset
         withOptions:(NSDictionary*)options
        shouldUpload:(BOOL) shouldUpload
             success:(void (^)(id JSON, NSURL *localurl))success
             failure:(void (^)(NSError *error, id JSON, NSURL *localurl))failure
            progress:(void (^)(float progress))progress
{

    NSString *filename;
    NSData *filedata;

    ALAssetRepresentation *representation = [asset defaultRepresentation];
    
    NSString *mimetype = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[representation UTI], kUTTagClassMIMEType);
    NSLog(@"mimetype: %@", mimetype);
    
    
    if ([mimetype isEqualToString:@"video/quicktime"]){
        Byte *buffer = (Byte*)malloc((unsigned long)representation.size);
        NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(unsigned long)representation.size error:nil];
        filedata = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        //filedata = [[NSData alloc] initWithContentsOfURL:[representation url]];
    } else if ([mimetype isEqualToString:@"image/png"]){
        NSLog(@"using png");

        UIImage* image = [UIImage imageWithCGImage:[representation fullResolutionImage] 
                                             scale:[representation scale] orientation:(UIImageOrientation)[representation orientation]];
        
        filedata = UIImagePNGRepresentation(image);
    } else {
        NSLog(@"using jpeg");
        UIImage* image = [UIImage imageWithCGImage:[representation fullResolutionImage] 
                                             scale:[representation scale] orientation:(UIImageOrientation)[representation orientation]];
        
        filedata = UIImageJPEGRepresentation(image, 0.6);
        mimetype = @"image/jpeg";
    }

    if ([representation respondsToSelector:@selector(filename)]){
        filename = [representation filename];
    } else {
        NSString *extension = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[representation UTI], kUTTagClassFilenameExtension);
        filename = [NSString stringWithFormat:@"file.%@", extension];
    }
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPLibrary genRandStringLength:20]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    [filedata writeToURL:tempURL atomically:YES];


    [FPLibrary uploadDataToFilepicker:tempURL named: filename ofMimetype:mimetype shouldUpload:shouldUpload success:^(id JSON) {
        success(JSON, tempURL);            
    } failure:^(NSError *error, id JSON) {
        NSLog(@"FAILTURE %@ %@", error, JSON);
        failure(error, JSON, tempURL);
    } progress:progress];

}

#pragma mark for save as

+ (void) uploadData:(NSData*)filedata
              named: (NSString *)filename
             toPath: (NSString*)path
               ofMimetype: (NSString*) mimetype
        withOptions:(NSDictionary*)options 
            success:(void (^)(id JSON))success 
            failure:(void (^)(NSError *error, id JSON))failure
           progress:(void (^)(float progress))progress
{
    
    NSLog(@"Type: %@", mimetype);
    //NSString *mimetype = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    //NSLog(@"Mime: %@", mimetype);
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[FPLibrary genRandStringLength:20]];
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath isDirectory:NO];
    [filedata writeToURL:tempURL atomically:YES];
    

    [FPLibrary uploadDataToFilepicker:tempURL named: filename ofMimetype:mimetype shouldUpload:YES success:^(id JSON) {
        NSString *filepickerURL = [[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"url"];
        [FPLibrary uploadDataHelper_saveAs:filepickerURL toPath:[NSString stringWithFormat:@"%@%@", path, filename] ofMimetype:mimetype withOptions:options success:success failure:failure];
    } failure:^(NSError *error, id JSON) {
        //NSLog(@"FAILTURE %@ %@", error, JSON);
        failure(error, JSON);
    } progress:progress];
}


+ (void) uploadDataURL:(NSURL*)filedataurl
              named: (NSString *)filename
             toPath: (NSString*)path
         ofMimetype: (NSString*) mimetype
        withOptions:(NSDictionary*)options
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error, id JSON))failure
              progress:(void (^)(float progress))progress
{
    
    NSLog(@"Type: %@", mimetype);
    //NSString *mimetype = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    //NSLog(@"Mime: %@", mimetype);
    
    
    [FPLibrary uploadDataToFilepicker:filedataurl named: filename ofMimetype:mimetype shouldUpload:YES success:^(id JSON) {
        NSString *filepickerURL = [[[JSON objectForKey:@"data"] objectAtIndex:0] objectForKey:@"url"];
        [FPLibrary uploadDataHelper_saveAs:filepickerURL toPath:[NSString stringWithFormat:@"%@%@", path, filename] ofMimetype:mimetype withOptions:options success:success failure:failure];
    } failure:^(NSError *error, id JSON) {
        //NSLog(@"FAILTURE %@ %@", error, JSON);
        failure(error, JSON);
    } progress:progress];
}

+ (void) uploadDataHelper_saveAs:(NSString *)fileLocation
         toPath:(NSString*)saveLocation
     ofMimetype:(NSString*)mimetype
    withOptions:(NSDictionary*)options 
        success:(void (^)(id JSON))success 
        failure:(void (^)(NSError *error, id JSON))failure
{
    
    FPAFHTTPClient *httpClient = [[FPAFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString: fpBASE_URL]];
    
    NSString *appString = [NSString stringWithFormat:@"{\"apikey\": \"%@\"}", fpAPIKEY];
    NSString *js_sessionString = [NSString stringWithFormat:@"{\"app\": %@, \"mimetypes\":[\"%@\"] }", appString, mimetype];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            js_sessionString, @"js_session",
                            fileLocation, @"url",
                            nil];
    
    NSString *savePath = [NSString stringWithFormat:@"/api/path%@", [saveLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:savePath parameters:params];
    
    NSLog(@"Saving %@", request);
    
    FPAFJSONRequestOperation *operation = [FPAFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ([JSON valueForKey:@"url"]){
            success(JSON);
        } else {
            failure([[NSError alloc] initWithDomain:fpBASE_URL code:0 userInfo:[[NSDictionary alloc] init]], JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error, JSON);
    }];
    [operation start];
    
}

#pragma mark helper functions
        
+(NSString*)urlEscapeString:(NSString *)unencodedString 
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}

+(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
            
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];

        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}

// Load the framework bundle.
+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"FilepickerSDK.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle;
}

+ (id) JSONObjectWithData:(NSData *)data {
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass) {
        //iOS < 5 didn't have the JSON serialization class
        return [data objectFromJSONData]; //JSONKit
    }
    else {
        NSError *jsonParsingError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0   error:&jsonParsingError];
        return jsonObject;
    }
    return nil;
}

+ (NSData *) dataWithJSONObject:(id)object {
    Class jsonSerializationClass = NSClassFromString(@"NSJSONSerialization");
    if (!jsonSerializationClass) {
        //iOS < 5 didn't have the JSON serialization class
        return [object JSONData]; //JSONKit
    }
    else {
        NSError *jsonParsingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0   error:&jsonParsingError];
        return data;
    }
    return nil;
}

+ (BOOL) mimetype:(NSString *)mimetype instanceOfMimetype:(NSString *)supermimetype {
    if ([supermimetype isEqualToString:@"*/*"]){
        return YES;
    }
    if (mimetype == supermimetype){
        return YES;
    }
    NSArray *splitType1 = [mimetype componentsSeparatedByString:@"/"];
    NSArray *splitType2 = [supermimetype componentsSeparatedByString:@"/"];
    if ([[splitType1 objectAtIndex:0] isEqualToString:[splitType2 objectAtIndex:0]]){
        return YES;
    }
    return NO;
}


+ (UIImage *)rotateImage:(UIImage *)image { 
    
    /*
     * http://stackoverflow.com/questions/10170009/image-became-horizontal-after-successfully-uploaded-on-server-using-http-post 
     */
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    /*
    int kMaxResolution = 640; // Or whatever

    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
     */
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (NSString *) formatTimeInSeconds: (int) timeInSeconds
{
    int seconds = timeInSeconds%60;
    int minutes = (timeInSeconds / 60);

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
                          
                          
+ (NSString *) genRandStringLength: (int) len {

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end

