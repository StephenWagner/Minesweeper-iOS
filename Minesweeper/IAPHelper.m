//
//  IAPHelper.m
//  Minesweeper
//
//  Created by Stephen Wagner on 6/17/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "Constants.h"
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (strong, nonatomic) RequestProductsCompletionHandler completionHandler;
@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSSet *consumableProducts;
@property (strong, nonatomic) NSSet *nonConsumableProducts;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;
@end


@implementation IAPHelper
-(instancetype)initWithConsumableProducts:(NSSet*)consumableProducts andNonConsumableProducts:(NSSet*)nonConsumableProducts{
    if (self = [super init]) {
        _consumableProducts = consumableProducts;
        _nonConsumableProducts = nonConsumableProducts;
        _productIdentifiers = [consumableProducts setByAddingObjectsFromSet:nonConsumableProducts];
        
        for (NSString *productIdentifier in self.nonConsumableProducts) {
            BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (purchased) {
                [self.purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    return self;
}

-(instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if (self = [super init]) {
        self.productIdentifiers = productIdentifiers;
        for (NSString *productIdentifier in self.productIdentifiers) {
            BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (purchased) {
                [self.purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    
    return self;
}

-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler{
    self.completionHandler = [completionHandler copy];
    self.productsRequest.delegate = self; //lazily instantiated
    [self.productsRequest start];
}

#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Loaded list of products...");
    self.productsRequest = nil;
    NSArray *skProducts = response.products;
    
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found Product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Failed to load list of products.");
    
    self.productsRequest = nil;
    _completionHandler(NO, nil);
    self.completionHandler = nil;
}

-(BOOL)productPurchased:(NSString *)productIdentifier {
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

-(void)buyProduct:(SKProduct *)product {
    NSLog(@"Buying product %@...", product.productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

-(void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numOfProduct = 0;
    
    if ([self.consumableProducts containsObject:productIdentifier]) {
        //code for consumable products
        if ([productIdentifier containsString:@"mined"]) {
            numOfProduct = [defaults integerForKey:keyMinedHints];
            
        }
    } else if ([self.nonConsumableProducts containsObject:productIdentifier]){
        //code for non-consumable products
    }
    
    [self.purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

#pragma mark - lazy instantiation
-(NSMutableSet*)purchasedProductIdentifiers{
    if (!_purchasedProductIdentifiers) {
        _purchasedProductIdentifiers = [NSMutableSet set];
    }
    return _purchasedProductIdentifiers;
}

-(SKProductsRequest*)productsRequest{
    if (!_productsRequest) {
        _productsRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:self.productIdentifiers];
    }
    return _productsRequest;
}
@end
