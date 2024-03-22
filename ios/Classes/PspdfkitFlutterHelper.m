//
//  Copyright © 2018-2024 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitFlutterHelper.h"
#import "PspdfkitFlutterConverter.h"
#import "pspdfkit_flutter-Swift.h"


@implementation PspdfkitFlutterHelper

+ (void)processMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result forViewController:(PSPDFViewController *)pdfViewController {
    if ([@"save" isEqualToString:call.method]) {
        PSPDFDocument *document = pdfViewController.document;
        if (!document || !document.isValid) {
            result([FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil]);
            return;
        }
        [document saveWithOptions:nil completionHandler:^(NSError * _Nullable error, NSArray<__kindof PSPDFAnnotation *> * _Nonnull savedAnnotations) {
            if (error == nil) {
                result(@(YES));
            } else {
                result([FlutterError errorWithCode:@"" message:error.description details:nil]);
            }
        }];
    } else if ([@"setFormFieldValue" isEqualToString:call.method]) {
        NSString *value = call.arguments[@"value"];
        NSString *fullyQualifiedName = call.arguments[@"fullyQualifiedName"];
        result([PspdfkitFlutterHelper setFormFieldValue:value forFieldWithFullyQualifiedName:fullyQualifiedName forViewController:pdfViewController]);
    } else if ([@"getFormFieldValue" isEqualToString:call.method]) {
        NSString *fullyQualifiedName = call.arguments[@"fullyQualifiedName"];
        result([PspdfkitFlutterHelper getFormFieldValueForFieldWithFullyQualifiedName:fullyQualifiedName forViewController:pdfViewController]);
    } else if ([@"applyInstantJson" isEqualToString:call.method]) {
        NSString *annotationsJson = call.arguments[@"annotationsJson"];
        if (annotationsJson.length == 0) {
            result([FlutterError errorWithCode:@"" message:@"annotationsJson may not be nil or empty." details:nil]);
            return;
        }
        PSPDFDocument *document = pdfViewController.document;
        if (!document || !document.isValid) {
            result([FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil]);
            return;
        }
        PSPDFDataContainerProvider *jsonContainer = [[PSPDFDataContainerProvider alloc] initWithData:[annotationsJson dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *error;
        BOOL success = [document applyInstantJSONFromDataProvider:jsonContainer toDocumentProvider:document.documentProviders.firstObject lenient:NO error:&error];
        if (!success) {
            result([FlutterError errorWithCode:@"" message:@"Error while importing document Instant JSON." details:nil]);
        } else {
            [pdfViewController reloadData];
            result(@(YES));
        }
    } else if ([@"exportInstantJson" isEqualToString:call.method]) {
        PSPDFDocument *document = pdfViewController.document;
        if (!document || !document.isValid) {
            result([FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil]);
            return;
        }
        NSError *error;
        NSData *data = [document generateInstantJSONFromDocumentProvider:document.documentProviders.firstObject error:&error];
        NSString *annotationsJson = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (annotationsJson == nil) {
            result([FlutterError errorWithCode:@"" message:@"Error while exporting document Instant JSON." details:error.localizedDescription]);
        } else {
            result(annotationsJson);
        }
    } else if ([@"addAnnotation" isEqualToString:call.method]) {
        id jsonAnnotation = call.arguments[@"jsonAnnotation"];
        result([PspdfkitFlutterHelper addAnnotation:jsonAnnotation forViewController:pdfViewController]);
    } else if ([@"removeAnnotation" isEqualToString:call.method]) {
        id jsonAnnotation = call.arguments[@"jsonAnnotation"];
        result([PspdfkitFlutterHelper removeAnnotation:jsonAnnotation forViewController:pdfViewController]);
    } else if ([@"getAnnotations" isEqualToString:call.method]) {
        PSPDFPageIndex pageIndex = [call.arguments[@"pageIndex"] longLongValue];
        NSString *typeString = call.arguments[@"type"];
        result([PspdfkitFlutterHelper getAnnotationsForPageIndex:pageIndex andType:typeString forViewController:pdfViewController]);
    } else if ([@"getAllUnsavedAnnotations" isEqualToString:call.method]) {
        result([PspdfkitFlutterHelper getAllUnsavedAnnotationsForViewController:pdfViewController]);
    } else if ([@"importXfdf" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"xfdfPath"];
        result([PspdfkitFlutterHelper importXFDFFromPath:path forViewController:pdfViewController]);
    } else if ([@"exportXfdf" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"xfdfPath"];
        result([PspdfkitFlutterHelper exportXFDFToPath:path forViewController:pdfViewController]);
    } else if ([@"processAnnotations" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"type"];
        NSString *processingMode = call.arguments[@"processingMode"];
        NSString *destinationPath = call.arguments[@"destinationPath"];
        result([PspdfkitFlutterHelper processAnnotationsOfType:type withProcessingMode:processingMode andDestinationPath:destinationPath forViewController:pdfViewController]);
    } else if ([@"generatePdfFromHtmlString" isEqualToString:call.method]) {
        NSString *html = call.arguments[@"html"];
        NSString *outputPath = call.arguments[@"outputPath"];
        NSURL *processedDocumentURL = [PspdfkitFlutterHelper writableFileURLWithPath:outputPath override:YES copyIfNeeded:NO];
        NSDictionary *options = call.arguments[@"options"];
        [PspdfkitHtmlPdfConvertor generateFromHtmlStringWithHtml:html outputFileURL:processedDocumentURL convertionOptions:options results:result];
    } else if ([@"generatePdfFromHtmlUri" isEqualToString:call.method]){
        NSString *htmlURLString = call.arguments[@"htmlUri"];
        NSString *outputPath = call.arguments[@"outputPath"];
        NSURL *processedDocumentURL = [PspdfkitFlutterHelper writableFileURLWithPath:outputPath override:YES copyIfNeeded:NO];
        NSURL *htmlURL = [[NSURL alloc] initWithString:htmlURLString];
        NSDictionary *options = call.arguments[@"options"];
        [PspdfkitHtmlPdfConvertor generateFromHtmlURLWithHtmlURL:htmlURL outputFileURL:processedDocumentURL convertionOptions:options results:result];
    } else if ([@"generatePDF" isEqualToString:call.method]){
        NSString *outputPath = call.arguments[@"outputFilePath"];
        NSArray<NSDictionary<NSString *,NSObject *> *> *pages = call.arguments[@"pages"];
        NSURL *processedDocumentURL = [PspdfkitFlutterHelper writableFileURLWithPath:outputPath override:YES copyIfNeeded:NO];
        [PspdfkitPdfGenerator generatePdfWithPages:pages outputUrl:processedDocumentURL results:result];
        
    } else if ([@"setDelayForSyncingLocalChanges" isEqualToString:call.method]){
          
        NSNumber *delay = call.arguments[@"delay"];
        
          if (delay == nil || [delay doubleValue] < 0) {
            result([FlutterError errorWithCode:@"InvalidArgument"
            message:@"Delay must be a positive number"
            details:nil]);
            return;
          }

        // if pdfViewController is an instance of InstantDocumentViewController, then we can set the delay
        if ([pdfViewController isKindOfClass:[InstantDocumentViewController class]]) {
            InstantDocumentViewController *instantDocumentViewController = (InstantDocumentViewController *)pdfViewController;
            instantDocumentViewController.documentDescriptor.delayForSyncingLocalChanges = [delay doubleValue];
            result(@(YES));
        } else {
            result([FlutterError errorWithCode:@"InvalidArgument"
            message:@"Delay can only be set for Instant documents"
            details:nil]);
        }
        
     } else if ([@"setListenToServerChanges" isEqualToString:call.method]){
         BOOL listenToServerChanges = [call.arguments[@"listen"] boolValue];
        
        if ([pdfViewController isKindOfClass:[InstantDocumentViewController class]]) {
            InstantDocumentViewController *instantDocumentViewController = (InstantDocumentViewController *)pdfViewController;
            instantDocumentViewController.shouldListenForServerChangesWhenVisible = listenToServerChanges;
            result(@(YES));
        } else {
            result([FlutterError errorWithCode:@"InvalidArgument"
            message:@"listenToServerChanges can only be set for Instant documents"
            details:nil]);
        }

    } else if ([@"syncAnnotations" isEqualToString:call.method]){
        // if pdfViewController is an instance of InstantDocumentViewController, then we can set the delay
        if ([pdfViewController isKindOfClass:[InstantDocumentViewController class]]) {
            InstantDocumentViewController *instantDocumentViewController = (InstantDocumentViewController *)pdfViewController;
            [instantDocumentViewController.documentDescriptor sync];
            result(@(YES));
        } else {
            result([FlutterError errorWithCode:@"InvalidArgument"
            message:@"syncAnnotations can only be called on Instant document"
            details:nil]);
        }
    }else if ([@"setAnnotationPresetConfigurations" isEqualToString:call.method]) {
        [AnnotationsPresetConfigurations setConfigurationsWithAnnotationPreset:call.arguments[@"annotationConfigurations"]];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

# pragma mark - Document Helpers

+ (nullable PSPDFDocument *)documentFromPath:(NSString *)path {
    NSURL *url;

    if ([path hasPrefix:@"/"]) {
        url = [NSURL fileURLWithPath:path];
    } else {
        url = [NSBundle.mainBundle URLForResource:path withExtension:nil];
    }
    
    if (url == nil) {
        return nil;
    }

    if ([PspdfkitFlutterHelper isImageDocument:path]) {
        return [[PSPDFImageDocument alloc] initWithImageURL:url];
    } else {
        return [[PSPDFDocument alloc] initWithURL:url];
    }
}

+ (BOOL)isImageDocument:(NSString *)path {
    NSString *fileExtension = path.pathExtension.lowercaseString;
    return [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"tiff"] || [fileExtension isEqualToString:@"tif"];
}

# pragma mark - File Helpers

+ (NSURL *)fileURLWithPath:(NSString *)path {
    if (path) {
        path = [path stringByExpandingTildeInPath];
        path = [path stringByReplacingOccurrencesOfString:@"file:" withString:@""];
        if (![path isAbsolutePath]) {
            path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"] stringByAppendingPathComponent:path];
        }
        return [NSURL fileURLWithPath:path];
    }
    return nil;
}

+ (NSURL *)writableFileURLWithPath:(NSString *)path override:(BOOL)override copyIfNeeded:(BOOL)copyIfNeeded {
    NSURL *writableFileURL;
    if (path.absolutePath) {
        writableFileURL = [NSURL fileURLWithPath:path];
    } else {
        NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        writableFileURL = [NSURL fileURLWithPath:[docsFolder stringByAppendingPathComponent:path]];
    }

    NSFileManager *fileManager = NSFileManager.defaultManager;
    if (override) {
        [fileManager removeItemAtURL:writableFileURL error:NULL];
    }

    // If we don't have a writable file already, we move the provided file to the ~/Documents folder.
    if (![fileManager fileExistsAtPath:(NSString *)writableFileURL.path]) {
        // Create the folder where the writable file will be saved.
        NSError *createFolderError;
        if (![fileManager createDirectoryAtPath:writableFileURL.path.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:&createFolderError]) {
            NSLog(@"Failed to create directory: %@", createFolderError.localizedDescription);
            return nil;
        }

        // Copy the provided file to a writable location if it exists.
        NSURL *fileURL = [self fileURLWithPath:path];
        NSError *copyError;
        if (copyIfNeeded && [fileManager fileExistsAtPath:(NSString *)fileURL.path]) {
            if (![fileManager copyItemAtURL:fileURL toURL:writableFileURL error:&copyError]) {
                NSLog(@"Failed to copy item at URL '%@' with error: %@", path, copyError.localizedDescription);
                return nil;
            }
        }
    }
    return writableFileURL;
}

# pragma mark - Password Helper

+ (void)unlockWithPasswordIfNeeded:(PSPDFDocument *)document dictionary:(NSDictionary *)dictionary {
    if ((id)dictionary == NSNull.null || !dictionary || dictionary.count == 0) {
        return;
    }
    NSString *password = dictionary[@"password"];
    if (password.length) {
        [document unlockWithPassword:password];
    }
}

# pragma mark - Toolbar Customization

+ (void)setToolbarTitle:(NSString *)toolbarTitle forViewController:(PSPDFViewController *)pdfViewController {
    // Early return if the toolbar title is not explicitly set in the configuration dictionary.
    if (!toolbarTitle) {
        return;
    }

    // We allow setting a null title.
    pdfViewController.title = (id)toolbarTitle == NSNull.null ? nil : toolbarTitle;
}

+ (void)setLeftBarButtonItems:(nullable NSArray <NSString *> *)items forViewController:(PSPDFViewController *)pdfViewController {
    if ((id)items == NSNull.null || !items || items.count == 0) {
        return;
    }
    NSMutableArray *leftItems = [NSMutableArray array];
    for (NSString *barButtonItemString in items) {
        UIBarButtonItem *barButtonItem = [self barButtonItemFromString:barButtonItemString forViewController:pdfViewController];
        if (barButtonItem && ![pdfViewController.navigationItem.rightBarButtonItems containsObject:barButtonItem]) {
            [leftItems addObject:barButtonItem];
        }
    }

    [pdfViewController.navigationItem setLeftBarButtonItems:[leftItems copy] animated:NO];
}

+ (void)setRightBarButtonItems:(nullable NSArray <NSString *> *)items forViewController:(PSPDFViewController *)pdfViewController {
    if ((id)items == NSNull.null || !items || items.count == 0) {
        return;
    }
    NSMutableArray *rightItems = [NSMutableArray array];
    for (NSString *barButtonItemString in items) {
        UIBarButtonItem *barButtonItem = [PspdfkitFlutterHelper barButtonItemFromString:barButtonItemString forViewController:pdfViewController];
        if (barButtonItem && ![pdfViewController.navigationItem.leftBarButtonItems containsObject:barButtonItem]) {
            [rightItems addObject:barButtonItem];
        }
    }

    [pdfViewController.navigationItem setRightBarButtonItems:[rightItems copy] animated:NO];
}

+ (UIBarButtonItem *)barButtonItemFromString:(NSString *)barButtonItem forViewController:(PSPDFViewController *)pdfViewController {
    if ([barButtonItem isEqualToString:@"closeButtonItem"]) {
        return pdfViewController.closeButtonItem;
    } else if ([barButtonItem isEqualToString:@"outlineButtonItem"]) {
        return pdfViewController.outlineButtonItem;
    } else if ([barButtonItem isEqualToString:@"searchButtonItem"]) {
        return pdfViewController.searchButtonItem;
    } else if ([barButtonItem isEqualToString:@"thumbnailsButtonItem"]) {
        return pdfViewController.thumbnailsButtonItem;
    } else if ([barButtonItem isEqualToString:@"documentEditorButtonItem"]) {
        return pdfViewController.documentEditorButtonItem;
    } else if ([barButtonItem isEqualToString:@"printButtonItem"]) {
        return pdfViewController.printButtonItem;
    } else if ([barButtonItem isEqualToString:@"openInButtonItem"]) {
        return pdfViewController.openInButtonItem;
    } else if ([barButtonItem isEqualToString:@"emailButtonItem"]) {
        return pdfViewController.emailButtonItem;
    } else if ([barButtonItem isEqualToString:@"messageButtonItem"]) {
        return pdfViewController.messageButtonItem;
    } else if ([barButtonItem isEqualToString:@"annotationButtonItem"]) {
        return pdfViewController.annotationButtonItem;
    } else if ([barButtonItem isEqualToString:@"bookmarkButtonItem"]) {
        return pdfViewController.bookmarkButtonItem;
    } else if ([barButtonItem isEqualToString:@"brightnessButtonItem"]) {
        return pdfViewController.brightnessButtonItem;
    } else if ([barButtonItem isEqualToString:@"activityButtonItem"]) {
        return pdfViewController.activityButtonItem;
    } else if ([barButtonItem isEqualToString:@"settingsButtonItem"]) {
        return pdfViewController.settingsButtonItem;
    } else if ([barButtonItem isEqualToString:@"readerViewButtonItem"]) {
        return pdfViewController.readerViewButtonItem;
    } else {
        return nil;
    }
}

# pragma mark - Forms

+ (id)setFormFieldValue:(NSString *)value forFieldWithFullyQualifiedName:(NSString *)fullyQualifiedName forViewController:(PSPDFViewController *)pdfViewController {
    PSPDFDocument *document = pdfViewController.document;

    if (!document || !document.isValid) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
        return error;
    }

    if (fullyQualifiedName == nil || fullyQualifiedName.length == 0) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"Fully qualified name may not be nil or empty." details:nil];
        return error;
    }

    BOOL success = NO;
    for (PSPDFFormElement *formElement in document.formParser.forms) {
        if ([formElement.fullyQualifiedFieldName isEqualToString:fullyQualifiedName]) {
            if ([formElement isKindOfClass:PSPDFButtonFormElement.class]) {
                if ([value isEqualToString:@"selected"]) {
                    [(PSPDFButtonFormElement *)formElement select];
                    success = YES;
                } else if ([value isEqualToString:@"deselected"]) {
                    [(PSPDFButtonFormElement *)formElement deselect];
                    success = YES;
                }
            } else if ([formElement isKindOfClass:PSPDFChoiceFormElement.class]) {
                ((PSPDFChoiceFormElement *)formElement).selectedIndices = [NSIndexSet indexSetWithIndex:value.integerValue];
                success = YES;
            } else if ([formElement isKindOfClass:PSPDFTextFieldFormElement.class]) {
                formElement.contents = value;
                success = YES;
            } else if ([formElement isKindOfClass:PSPDFSignatureFormElement.class]) {
                FlutterError *error = [FlutterError errorWithCode:@"" message:@"Signature form elements are not supported." details:nil];
                return error;
            } else {
                return @(NO);
            }
            break;
        }
    }

    if (!success) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:[NSString stringWithFormat:@"Error while searching for a form element with name %@.", fullyQualifiedName] details:nil];
        return error;
    }

    return @(YES);
}

+ (id)getFormFieldValueForFieldWithFullyQualifiedName:(NSString *)fullyQualifiedName forViewController:(PSPDFViewController *)pdfViewController {
    if (fullyQualifiedName == nil || fullyQualifiedName.length == 0) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:@"Fully qualified name may not be nil or empty." details:nil];
        return error;
    }

    PSPDFDocument *document = pdfViewController.document;
    id formFieldValue = nil;
    for (PSPDFFormElement *formElement in document.formParser.forms) {
        if ([formElement.fullyQualifiedFieldName isEqualToString:fullyQualifiedName]) {
            formFieldValue = formElement.value;
            break;
        }
    }

    if (formFieldValue == nil) {
        FlutterError *error = [FlutterError errorWithCode:@"" message:[NSString stringWithFormat:@"Error while searching for a form element with name %@.", fullyQualifiedName] details:nil];
        return error;
    }

    return formFieldValue;
}

# pragma mark - Annotation Processing

+ (id)processAnnotationsOfType:(NSString *)type withProcessingMode:(NSString *)processingMode andDestinationPath:(NSString *)destinationPath forViewController:(PSPDFViewController *)pdfViewController {
    PSPDFAnnotationChange change = [PspdfkitFlutterConverter annotationChangeFromString:processingMode];
    NSURL *processedDocumentURL = [PspdfkitFlutterHelper writableFileURLWithPath:destinationPath override:YES copyIfNeeded:NO];
    PSPDFAnnotationType annotationType = [PspdfkitFlutterConverter annotationTypeFromString:type];

    if (!processedDocumentURL) {
        return [FlutterError errorWithCode:@"" message:@"Could not create a new PDF file at the given path." details:nil];
    }

    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    // Create a processor configuration with the current document.
    PSPDFProcessorConfiguration *configuration = [[PSPDFProcessorConfiguration alloc] initWithDocument:document];

    // Modify annotations.
    [configuration modifyAnnotationsOfTypes:annotationType change:change];

    // Create the PDF processor and write the processed file.
    PSPDFProcessor *processor = [[PSPDFProcessor alloc] initWithConfiguration:configuration securityOptions:nil];

    NSError *error;
    [processor writeToFileURL:processedDocumentURL error:&error];
    if (error) {
        return [FlutterError errorWithCode:@"" message:@"Error writing to PDF file." details:error.localizedDescription];
    }

    return @(YES);
}

# pragma mark - Instant JSON

+ (id)addAnnotation:(id)jsonAnnotation forViewController:(PSPDFViewController *)pdfViewController {
    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    NSData *data;
    if ([jsonAnnotation isKindOfClass:NSString.class]) {
        data = [jsonAnnotation dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([jsonAnnotation isKindOfClass:NSDictionary.class])  {
        data = [NSJSONSerialization dataWithJSONObject:jsonAnnotation options:0 error:nil];
    }

    if (data == nil) {
        return [FlutterError errorWithCode:@"" message:@"Invalid JSON Annotation." details:nil];
    }

    PSPDFDocumentProvider *documentProvider = document.documentProviders.firstObject;
    PSPDFAnnotation *annotation = [PSPDFAnnotation annotationFromInstantJSON:data documentProvider:documentProvider error:NULL];
    BOOL success = [document addAnnotations:@[annotation] options:nil];

    if (!success) {
        return [FlutterError errorWithCode:@"" message:@"Failed to add annotation." details:nil];
    }

    return @(YES);
}

+ (id)removeAnnotation:(id)jsonAnnotation forViewController:(PSPDFViewController *)pdfViewController {
    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    NSString *annotationUUID;
    if ([jsonAnnotation isKindOfClass:NSString.class]) {
        NSData *jsonData = [jsonAnnotation dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        if (jsonDict) { annotationUUID = jsonDict[@"uuid"]; }
    } else if ([jsonAnnotation isKindOfClass:NSDictionary.class])  {
        if (jsonAnnotation) { annotationUUID = jsonAnnotation[@"uuid"]; }
    }

    if (annotationUUID.length <= 0) {
        return [FlutterError errorWithCode:@"" message:@"Invalid annotation UUID." details:nil];
    }

    BOOL success = NO;
    NSArray<PSPDFAnnotation *> *allAnnotations = [[document allAnnotationsOfType:PSPDFAnnotationTypeAll].allValues valueForKeyPath:@"@unionOfArrays.self"];
    for (PSPDFAnnotation *annotation in allAnnotations) {
        // Remove the annotation if the uuids match.
        if ([annotation.uuid isEqualToString:annotationUUID]) {
            success = [document removeAnnotations:@[annotation] options:nil];
            break;
        }
    }

    return @(success);
}

+ (id)getAnnotationsForPageIndex:(PSPDFPageIndex)pageIndex andType:(NSString *)typeString forViewController:(PSPDFViewController *)pdfViewController {
    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    PSPDFAnnotationType type = [PspdfkitFlutterConverter annotationTypeFromString:typeString];

    NSArray <PSPDFAnnotation *> *annotations = [document annotationsForPageAtIndex:pageIndex type:type];
    NSArray <NSDictionary *> *annotationsJSON = [PspdfkitFlutterConverter instantJSONFromAnnotations:annotations];

    if (annotationsJSON) {
        return annotationsJSON;
    } else {
        return [FlutterError errorWithCode:@"" message:@"Failed to get annotations." details:nil];
    }
}

+ (id)getAllUnsavedAnnotationsForViewController:(PSPDFViewController *)pdfViewController {
    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    PSPDFDocumentProvider *documentProvider = document.documentProviders.firstObject;
    NSData *data = [document generateInstantJSONFromDocumentProvider:documentProvider error:NULL];
    NSDictionary *annotationsJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];

    if (annotationsJSON) {
        return annotationsJSON;
    }  else {
        return [FlutterError errorWithCode:@"" message:@"Failed to get annotations." details:nil];
    }
}

# pragma mark - XFDF

+ (id)importXFDFFromPath:(NSString *)path forViewController:(PSPDFViewController *)pdfViewController {
    NSURL *fileURL = [PspdfkitFlutterHelper fileURLWithPath:path];
    if (![NSFileManager.defaultManager fileExistsAtPath:(NSString *)fileURL.path]) {
        return [FlutterError errorWithCode:@"" message:@"The XFDF file does not exist." details:nil];
    }

    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    PSPDFFileDataProvider *dataProvider = [[PSPDFFileDataProvider alloc] initWithFileURL:fileURL];
    PSPDFXFDFParser *parser = [[PSPDFXFDFParser alloc] initWithDataProvider:dataProvider documentProvider:document.documentProviders[0]];

    NSError *error;
    [parser parseWithError:&error];

    if (error) {
        return [FlutterError errorWithCode:@"" message:@"Error while parsing XFDF file." details:error.localizedDescription];
    }

    // Import annotations to the document.
    NSArray <PSPDFAnnotation *> *annotations = parser.annotations;
    if (annotations) {
        [document addAnnotations:annotations options:nil];
    }

    return @(YES);
}

+ (id)exportXFDFToPath:(NSString *)path forViewController:(PSPDFViewController *)pdfViewController {
    // Always overwrite the XFDF file we export to.
    NSURL *fileURL = [PspdfkitFlutterHelper writableFileURLWithPath:path override:YES copyIfNeeded:NO];

    if (!fileURL) {
        return [FlutterError errorWithCode:@"" message:@"Could not create a new XFDF file at the given path." details:nil];
    }

    PSPDFDocument *document = pdfViewController.document;
    if (!document || !document.isValid) {
        return [FlutterError errorWithCode:@"" message:@"PDF document not found or is invalid." details:nil];
    }

    // Collect all existing annotations from the document
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSArray *pageAnnotations in [document allAnnotationsOfType:PSPDFAnnotationTypeAll].allValues) {
        [annotations addObjectsFromArray:pageAnnotations];
    }

    // Write to the XFDF file.
    NSError *error;
    PSPDFFileDataSink *dataSink = [[PSPDFFileDataSink alloc] initWithFileURL:fileURL options:PSPDFDataSinkOptionNone error:&error];
    if (error) {
        return [FlutterError errorWithCode:@"" message:@"Error while exporting XFDF file." details:error.localizedDescription];
    }

    [[PSPDFXFDFWriter new] writeAnnotations:annotations toDataSink:dataSink documentProvider:document.documentProviders[0] error:&error];
    if (error) {
        return [FlutterError errorWithCode:@"" message:@"Error while exporting XFDF file." details:error.localizedDescription];
    }

    return @(YES);
}

@end
