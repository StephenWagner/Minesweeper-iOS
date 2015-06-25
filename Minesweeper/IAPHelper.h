//
//  IAPHelper.h
//  Minesweeper
//
//  Created by Stephen Wagner on 6/17/15.
//  Copyright (c) 2015 Stephen Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

-(instancetype)initWithConsumableProducts:(NSSet*)consumableProducts andNonConsumableProducts:(NSSet*)nonConsumableProducts;
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
-(void)buyProduct: (SKProduct*)product;
-(BOOL)productPurchased:(NSString*)productIdentifier;
-(void)restoreCompletedTransactions;

@end

