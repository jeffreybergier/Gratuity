//
//  UIImage+PDFUtility.h
//  Hello World
//
//  Created by Erica Sadun on 8/14/14.
//  Copyright (c) 2014 Erica Sadun. All rights reserved.
//

@import UIKit;

@interface UIImage_PDFUtility : NSObject
UIImage *ImageFromPDFFile(NSString *pdfPath, CGSize targetSize);
UIImage *ImageFromPDFFileWithWidth(NSString *pdfPath, CGFloat targetWidth);
UIImage *ImageFromPDFFileWithHeight(NSString *pdfPath, CGFloat targetHeight);
@end
