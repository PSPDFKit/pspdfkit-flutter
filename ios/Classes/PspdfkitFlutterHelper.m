//
//  Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "PspdfkitFlutterHelper.h"
#include <objc/NSObjCRuntime.h>
#include <Foundation/Foundation.h>
#import "PspdfkitFlutterConverter.h"
#import "nutrient_flutter-Swift.h"

#warning "This file is deprecated. Use PspddfkitHelper.swift instead."

@implementation PspdfkitFlutterHelper

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
            return nil;
        }

        // Copy the provided file to a writable location if it exists.
        NSURL *fileURL = [self fileURLWithPath:path];
        NSError *copyError;
        if (copyIfNeeded && [fileManager fileExistsAtPath:(NSString *)fileURL.path]) {
            if (![fileManager copyItemAtURL:fileURL toURL:writableFileURL error:&copyError]) {
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
    } else if ([barButtonItem isEqualToString:@"aiAssistantButtonItem"])  {
        return pdfViewController.aiAssistantButtonItem;
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

    NSDictionary *jsonDict = nil;
    if ([jsonAnnotation isKindOfClass:NSString.class]) {
        NSData *jsonData = [jsonAnnotation dataUsingEncoding:NSUTF8StringEncoding];
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    } else if ([jsonAnnotation isKindOfClass:NSDictionary.class])  {
        jsonDict = jsonAnnotation;
    }

    // Get identifiers - name is user-defined, id is Instant JSON identifier
    NSString *name = jsonDict[@"name"];
    NSString *instantId = jsonDict[@"id"];

    if (name.length <= 0 && instantId.length <= 0) {
        return [FlutterError errorWithCode:@"" message:@"Annotation has no identifier (name or id)." details:nil];
    }

    NSArray<PSPDFAnnotation *> *allAnnotations = [[document allAnnotationsOfType:PSPDFAnnotationTypeAll].allValues valueForKeyPath:@"@unionOfArrays.self"];

    PSPDFAnnotation *foundAnnotation = nil;

    // Strategy 1: Try to find by name
    if (name.length > 0) {
        for (PSPDFAnnotation *annotation in allAnnotations) {
            if ([annotation.name isEqualToString:name]) {
                foundAnnotation = annotation;
                break;
            }
        }
    }

    // Strategy 2: Try to find by uuid
    if (!foundAnnotation && instantId.length > 0) {
        for (PSPDFAnnotation *annotation in allAnnotations) {
            if ([annotation.uuid isEqualToString:instantId]) {
                foundAnnotation = annotation;
                break;
            }
        }

        // Strategy 3: Try to find by Instant JSON id
        if (!foundAnnotation) {
            for (PSPDFAnnotation *annotation in allAnnotations) {
                NSError *error = nil;
                NSData *annJsonData = [annotation generateInstantJSONWithError:&error];
                if (annJsonData && !error) {
                    NSDictionary *annJson = [NSJSONSerialization JSONObjectWithData:annJsonData options:0 error:nil];
                    NSString *annId = annJson[@"id"];
                    if ([annId isEqualToString:instantId]) {
                        foundAnnotation = annotation;
                        break;
                    }
                }
            }
        }
    }

    if (!foundAnnotation) {
        return @(NO);
    }

    BOOL success = [document removeAnnotations:@[foundAnnotation] options:nil];
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
