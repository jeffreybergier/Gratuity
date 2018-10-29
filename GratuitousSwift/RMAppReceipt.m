//
//  RMAppReceipt.m
//  RMStore
//
//  Created by Hermes on 10/12/13.
//  Copyright (c) 2013 Robot Media. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RMAppReceipt.h"
#import <UIKit/UIKit.h>
#import <openssl/pkcs7.h>
#import <openssl/objects.h>
#import <openssl/sha.h>
#import <openssl/x509.h>

// From https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
NSInteger const RMAppReceiptASN1TypeBundleIdentifier = 2;
NSInteger const RMAppReceiptASN1TypeAppVersion = 3;
NSInteger const RMAppReceiptASN1TypeOpaqueValue = 4;
NSInteger const RMAppReceiptASN1TypeHash = 5;
NSInteger const RMAppReceiptASN1TypeInAppPurchaseReceipt = 17;
NSInteger const RMAppReceiptASN1TypeOriginalAppVersion = 19;
NSInteger const RMAppReceiptASN1TypeExpirationDate = 21;

NSInteger const RMAppReceiptASN1TypeQuantity = 1701;
NSInteger const RMAppReceiptASN1TypeProductIdentifier = 1702;
NSInteger const RMAppReceiptASN1TypeTransactionIdentifier = 1703;
NSInteger const RMAppReceiptASN1TypePurchaseDate = 1704;
NSInteger const RMAppReceiptASN1TypeOriginalTransactionIdentifier = 1705;
NSInteger const RMAppReceiptASN1TypeOriginalPurchaseDate = 1706;
NSInteger const RMAppReceiptASN1TypeSubscriptionExpirationDate = 1708;
NSInteger const RMAppReceiptASN1TypeWebOrderLineItemID = 1711;
NSInteger const RMAppReceiptASN1TypeCancellationDate = 1712;

#pragma mark - ANS1

static int RMASN1ReadInteger(const uint8_t **pp, long omax)
{
    int tag, asn1Class;
    long length;
    int value = 0;
    ASN1_get_object(pp, &length, &tag, &asn1Class, omax);
    if (tag == V_ASN1_INTEGER)
    {
        for (int i = 0; i < length; i++)
        {
            value = value * 0x100 + (*pp)[i];
        }
    }
    *pp += length;
    return value;
}

static NSData* RMASN1ReadOctectString(const uint8_t **pp, long omax)
{
    int tag, asn1Class;
    long length;
    NSData *data = nil;
    ASN1_get_object(pp, &length, &tag, &asn1Class, omax);
    if (tag == V_ASN1_OCTET_STRING)
    {
        data = [NSData dataWithBytes:*pp length:length];
    }
    *pp += length;
    return data;
}

static NSString* RMASN1ReadString(const uint8_t **pp, long omax, int expectedTag, NSStringEncoding encoding)
{
    int tag, asn1Class;
    long length;
    NSString *value = nil;
    ASN1_get_object(pp, &length, &tag, &asn1Class, omax);
    if (tag == expectedTag)
    {
        value = [[NSString alloc] initWithBytes:*pp length:length encoding:encoding];
    }
    *pp += length;
    return value;
}

static NSString* RMASN1ReadUTF8String(const uint8_t **pp, long omax)
{
    return RMASN1ReadString(pp, omax, V_ASN1_UTF8STRING, NSUTF8StringEncoding);
}

static NSString* RMASN1ReadIA5SString(const uint8_t **pp, long omax)
{
    return RMASN1ReadString(pp, omax, V_ASN1_IA5STRING, NSASCIIStringEncoding);
}

static NSURL *_appleRootCertificateURL = nil;

@implementation RMAppReceipt

- (id)initWithASN1Data:(NSData*)asn1Data
{
    if (self = [super init])
    {
        NSMutableArray *purchases = [NSMutableArray array];
         // Explicit casting to avoid errors when compiling as Objective-C++
        [RMAppReceipt enumerateASN1Attributes:(const uint8_t*)asn1Data.bytes length:asn1Data.length usingBlock:^(NSData *data, int type) {
            const uint8_t *s = (const uint8_t*)data.bytes;
            const NSUInteger length = data.length;
            switch (type)
            {
                case RMAppReceiptASN1TypeBundleIdentifier:
                    self->_bundleIdentifierData = data;
                    self->_bundleIdentifier = RMASN1ReadUTF8String(&s, length);
                    break;
                case RMAppReceiptASN1TypeAppVersion:
                    self->_appVersion = RMASN1ReadUTF8String(&s, length);
                    break;
                case RMAppReceiptASN1TypeOpaqueValue:
                    self->_opaqueValue = data;
                    break;
                case RMAppReceiptASN1TypeHash:
                    self->_receiptHash = data;
                    break;
                case RMAppReceiptASN1TypeInAppPurchaseReceipt:
                {
                    RMAppReceiptIAP *purchase = [[RMAppReceiptIAP alloc] initWithASN1Data:data];
                    [purchases addObject:purchase];
                    break;
                }
                case RMAppReceiptASN1TypeOriginalAppVersion:
                    self->_originalAppVersion = RMASN1ReadUTF8String(&s, length);
                    break;
                case RMAppReceiptASN1TypeExpirationDate:
                {
                    NSString *string = RMASN1ReadIA5SString(&s, length);
                    self->_expirationDate = [RMAppReceipt formatRFC3339String:string];
                    break;
                }
            }
        }];
        _inAppPurchases = purchases;
    }
    return self;
}

- (BOOL)containsInAppPurchaseOfProductIdentifier:(NSString*)productIdentifier
{
    for (RMAppReceiptIAP *purchase in _inAppPurchases)
    {
        if ([purchase.productIdentifier isEqualToString:productIdentifier]) return YES;
    }
    return NO;
}

-(BOOL)containsActiveAutoRenewableSubscriptionOfProductIdentifier:(NSString *)productIdentifier forDate:(NSDate *)date
{
    RMAppReceiptIAP *lastTransaction = nil;
    
    for (RMAppReceiptIAP *iap in [self inAppPurchases])
    {
        if (![iap.productIdentifier isEqualToString:productIdentifier]) continue;
        
        if (!lastTransaction || [iap.subscriptionExpirationDate compare:lastTransaction.subscriptionExpirationDate] == NSOrderedDescending)
        {
            lastTransaction = iap;
        }
    }
    
    return [lastTransaction isActiveAutoRenewableSubscriptionForDate:date];
}

- (BOOL)verifyReceiptHash
{
    // TODO: Getting the uuid in Mac is different. See: https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html#//apple_ref/doc/uid/TP40010573-CH1-SW5
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    unsigned char uuidBytes[16];
    [uuid getUUIDBytes:uuidBytes];
    
    // Order taken from: https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html#//apple_ref/doc/uid/TP40010573-CH1-SW5
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:uuidBytes length:sizeof(uuidBytes)];
    [data appendData:self.opaqueValue];
    [data appendData:self.bundleIdentifierData];
    
    NSMutableData *expectedHash = [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];
    SHA1((const uint8_t*)data.bytes, data.length, (uint8_t*)expectedHash.mutableBytes); // Explicit casting to avoid errors when compiling as Objective-C++
    
    return [expectedHash isEqualToData:self.receiptHash];
}

+ (RMAppReceipt*)bundleReceipt
{
    NSURL *URL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString *path = URL.path;
    const BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
    if (!exists) return nil;
    
    NSData *data = [RMAppReceipt dataFromPCKS7Path:path];
    if (!data) return nil;
    
    RMAppReceipt *receipt = [[RMAppReceipt alloc] initWithASN1Data:data];
    return receipt;
}

+ (void)setAppleRootCertificateURL:(NSURL*)url
{
    _appleRootCertificateURL = url;
}

#pragma mark - Utils

#define krej6fUksh5Oj8doI9hUk3Zec8paSk9uV5lyD4Yar6eD0Jurf3 @"<308204bb 308203a3 a0030201 02020102 300d0609 2a864886 f70d0101 05050030 62310b30 09060355 04061302 55533113 30110603 55040a13 0a417070 6c652049 6e632e31 26302406 0355040b 131d4170 706c6520 43657274 69666963 6174696f 6e204175 74686f72 69747931 16301406 03550403 130d4170 706c6520 526f6f74 20434130 1e170d30 36303432 35323134 3033365a 170d3335 30323039 32313430 33365a30 62310b30 09060355 04061302 55533113 30110603 55040a13 0a417070 6c652049 6e632e31 26302406 0355040b 131d4170 706c6520 43657274 69666963 6174696f 6e204175 74686f72 69747931 16301406 03550403 130d4170 706c6520 526f6f74 20434130 82012230 0d06092a 864886f7 0d010101 05000382 010f0030 82010a02 82010100 e491a909 1f91db1e 4750eb05 ed5e7984 2deb36a2 574c55ec 8b1989de f94b6cf5 07ab2230 02e8183e f85009d3 7f41a898 f9d1ca66 9c246b11 d0a3bbe4 1b2ac31f 959e7a0c a4478b5b d4163733 cbc40f4d ce1469d1 c91972f5 5d0ed57f 5f9bf225 03ba558f 4d5d0df1 64352315 4b15591d b394f7f6 9c9ecf50 bac15850 678f08b4 20f7cbac 2c206f70 b63f0130 8cb743cf 0f9d3df3 2b49281a c8feceb5 b90ed95e 1cd6cb3d b53aadf4 0f0e0092 0bb12116 2e74d53c 0ddb6216 aba37192 475355c1 af2f41b3 f8fbe370 cde6a34c 457e1f4c 6b509641 89c47462 0b108341 87338a81 b13058ec 5a04328c 68b38f1d de6573ff 675e65bc 49d8769f 331465a1 7794c92d 02030100 01a38201 7a308201 76300e06 03551d0f 0101ff04 04030201 06300f06 03551d13 0101ff04 05300301 01ff301d 0603551d 0e041604 142bd069 47947609 fef46b8d 2e40a6f7 474d7f08 5e301f06 03551d23 04183016 80142bd0 69479476 09fef46b 8d2e40a6 f7474d7f 085e3082 01110603 551d2004 82010830 82010430 82010006 092a8648 86f76364 05013081 f2302a06 082b0601 05050702 01161e68 74747073 3a2f2f77 77772e61 70706c65 2e636f6d 2f617070 6c656361 2f3081c3 06082b06 01050507 02023081 b61a81b3 52656c69 616e6365 206f6e20 74686973 20636572 74696669 63617465 20627920 616e7920 70617274 79206173 73756d65 73206163 63657074 616e6365 206f6620 74686520 7468656e 20617070 6c696361 626c6520 7374616e 64617264 20746572 6d732061 6e642063 6f6e6469 74696f6e 73206f66 20757365 2c206365 72746966 69636174 6520706f 6c696379 20616e64 20636572 74696669 63617469 6f6e2070 72616374 69636520 73746174 656d656e 74732e30 0d06092a 864886f7 0d010105 05000382 0101005c 36994c2d 78b7ed8c 9bdcf377 9bf276d2 77304fc1 1f858385 1b993d47 37f2a99b 408e2cd4 b19012d8 bef4739b eed2640f cb794f34 d8a23ef9 78ff6bc8 07ec7d39 838b5320 d338c4b1 bf9a4f0a 6bff2bfc 59a70509 7c174056 111e74d3 b78b233b 47a3d56f 24e2ebd1 b770df0f 45e127ca f16d78ed e7b51717 a8dc7e22 35ca25d5 d90fd66b d4a22423 11f7a1ac 8f738160 c61b5b09 2f92b2f8 4448f060 389e15f5 3d266720 8a336af7 0d82cfde eba32ff9 536a5b64 c0633377 f73a072c 56ebda0f 210edaba 73194fb5 d9367fc1 8755d9a7 99b93242 fbd8d571 9e7ea152 b71bbd93 4224122a c70f1db6 4d9c5e63 c84b8017 50aa8ad5 dae4fcd0 090737b0 757521>"

+ (NSData *)Ea5huev8yEash9saf2uG2woY1Ru2drowD9aK7oal1kes8ond5O:(NSString *)string
{
    // Converts the NSData string representation back into NSData object
    const char *chars = [string UTF8String];
    int i = 0, len = (int)string.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len)
    {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

+ (NSData*)dataFromPCKS7Path:(NSString*)path
{
    const char *cpath = [[path stringByStandardizingPath] fileSystemRepresentation];
    FILE *fp = fopen(cpath, "rb");
    if (!fp) return nil;
    
    PKCS7 *p7 = d2i_PKCS7_fp(fp, NULL);
    fclose(fp);
    
    if (!p7) return nil;
    
    NSData *data;
    NSData *certificateData = [self Ea5huev8yEash9saf2uG2woY1Ru2drowD9aK7oal1kes8ond5O:[[[krej6fUksh5Oj8doI9hUk3Zec8paSk9uV5lyD4Yar6eD0Jurf3 stringByReplacingOccurrencesOfString:@"<" withString:@""]stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if ([self verifyPCKS7:p7 withCertificateData:certificateData])
    {
        struct pkcs7_st *contents = p7->d.sign->contents;
        if (PKCS7_type_is_data(contents))
        {
            ASN1_OCTET_STRING *octets = contents->d.data;
            data = [NSData dataWithBytes:octets->data length:octets->length];
        }
    }
    PKCS7_free(p7);
    return data;
}

+ (BOOL)verifyPCKS7:(PKCS7*)container withCertificateData:(NSData*)certificateData
{ // Based on: https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html#//apple_ref/doc/uid/TP40010573-CH1-SW17
    static int verified = 1;
    int result = 0;
    OpenSSL_add_all_digests(); // Required for PKCS7_verify to work
    X509_STORE *store = X509_STORE_new();
    if (store)
    {
        const uint8_t *certificateBytes = (uint8_t *)(certificateData.bytes);
        X509 *certificate = d2i_X509(NULL, &certificateBytes, (long)certificateData.length);
        if (certificate)
        {
            X509_STORE_add_cert(store, certificate);
            
            BIO *payload = BIO_new(BIO_s_mem());
            result = PKCS7_verify(container, NULL, store, NULL, payload, 0);
            BIO_free(payload);
            
            X509_free(certificate);
        }
    }
    X509_STORE_free(store);
    EVP_cleanup(); // Balances OpenSSL_add_all_digests (), perhttp://www.openssl.org/docs/crypto/OpenSSL_add_all_algorithms.html
    
    return result == verified;
}

/*
 Based on https://github.com/rmaddy/VerifyStoreReceiptiOS
 */
+ (void)enumerateASN1Attributes:(const uint8_t*)p length:(long)tlength usingBlock:(void (^)(NSData *data, int type))block
{
    int type, tag;
    long length;
    
    const uint8_t *end = p + tlength;
    
    ASN1_get_object(&p, &length, &type, &tag, end - p);
    if (type != V_ASN1_SET) return;
    
    while (p < end)
    {
        ASN1_get_object(&p, &length, &type, &tag, end - p);
        if (type != V_ASN1_SEQUENCE) break;
        
        const uint8_t *sequenceEnd = p + length;
        
        const int attributeType = RMASN1ReadInteger(&p, sequenceEnd - p);
        RMASN1ReadInteger(&p, sequenceEnd - p); // Consume attribute version
        
        NSData *data = RMASN1ReadOctectString(&p, sequenceEnd - p);
        if (data)
        {
            block(data, attributeType);
        }
        
        while (p < sequenceEnd)
        { // Skip remaining fields
            ASN1_get_object(&p, &length, &type, &tag, sequenceEnd - p);
            p += length;
        }
    }
}

+ (NSDate*)formatRFC3339String:(NSString*)string
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    NSDate *date = [formatter dateFromString:string];
    return date;
}

@end

@implementation RMAppReceiptIAP

- (id)initWithASN1Data:(NSData*)asn1Data
{
    if (self = [super init])
    {
        // Explicit casting to avoid errors when compiling as Objective-C++
        [RMAppReceipt enumerateASN1Attributes:(const uint8_t*)asn1Data.bytes length:asn1Data.length usingBlock:^(NSData *data, int type) {
            const uint8_t *p = (const uint8_t*)data.bytes;
            const NSUInteger length = data.length;
            switch (type)
            {
                case RMAppReceiptASN1TypeQuantity:
                    self->_quantity = RMASN1ReadInteger(&p, length);
                    break;
                case RMAppReceiptASN1TypeProductIdentifier:
                    self->_productIdentifier = RMASN1ReadUTF8String(&p, length);
                    break;
                case RMAppReceiptASN1TypeTransactionIdentifier:
                    self->_transactionIdentifier = RMASN1ReadUTF8String(&p, length);
                    break;
                case RMAppReceiptASN1TypePurchaseDate:
                {
                    NSString *string = RMASN1ReadIA5SString(&p, length);
                    self->_purchaseDate = [RMAppReceipt formatRFC3339String:string];
                    break;
                }
                case RMAppReceiptASN1TypeOriginalTransactionIdentifier:
                    self->_originalTransactionIdentifier = RMASN1ReadUTF8String(&p, length);
                    break;
                case RMAppReceiptASN1TypeOriginalPurchaseDate:
                {
                    NSString *string = RMASN1ReadIA5SString(&p, length);
                    self->_originalPurchaseDate = [RMAppReceipt formatRFC3339String:string];
                    break;
                }
                case RMAppReceiptASN1TypeSubscriptionExpirationDate:
                {
                    NSString *string = RMASN1ReadIA5SString(&p, length);
                    self->_subscriptionExpirationDate = [RMAppReceipt formatRFC3339String:string];
                    break;
                }
                case RMAppReceiptASN1TypeWebOrderLineItemID:
                    self->_webOrderLineItemID = RMASN1ReadInteger(&p, length);
                    break;
                case RMAppReceiptASN1TypeCancellationDate:
                {
                    NSString *string = RMASN1ReadIA5SString(&p, length);
                    self->_cancellationDate = [RMAppReceipt formatRFC3339String:string];
                    break;
                }
            }
        }];
    }
    return self;
}

- (BOOL)isActiveAutoRenewableSubscriptionForDate:(NSDate*)date
{
    NSAssert(self.subscriptionExpirationDate != nil, @"The product %@ is not an auto-renewable subscription.", self.productIdentifier);
    
    if (self.cancellationDate) return NO;
    
    return [self.purchaseDate compare:date] != NSOrderedDescending && [date compare:self.subscriptionExpirationDate] != NSOrderedDescending;
}

@end
