//
//  ViewController.m
//  TestHTMLParsing
//
//  Created by Alexander on 27.04.16.
//  Copyright © 2016 Alexander. All rights reserved.
//

#import "ViewController.h"
#import <Ono.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getItemsWithRequest:@"ONO" completion:^(NSArray *arr, NSError *err) {
        
    }];
}

- (void)getItemsWithRequest:(NSString *)requestStr completion:(void(^)(NSArray *arr, NSError *err))completion {
    NSString *urlStr = @"https://habrahabr.ru/";
    NSURL *url = [NSURL URLWithString:urlStr];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
        } else {
            NSArray *arr = [self parseData:data];
            completion(arr, nil);
        }
    }] resume];
}

- (NSArray *)parseData:(NSData *)data {
    ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
    ONOXMLElement *root = [doc rootElement];
//    NSLog(@"%@", root);
    [root enumerateElementsWithXPath:@"//div[@class='posts shortcuts_items']/div" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        NSDictionary *dictionary = [self parseElement:element];
        NSLog(@"%@", dictionary);
    }];
//    NSLog(@"%@", root);
    return nil;
}

- (NSDictionary *)parseElement:(ONOXMLElement *)elem {
    NSString *title = [[[elem firstChildWithTag:@"h1"] firstChildWithTag:@"a"] stringValue];
    NSString *imgUrlStr = nil;
    for (ONOXMLElement *child in [elem childrenWithTag:@"div"]) {
        if (![child[@"class"] isEqual:@"content html_format"])
            continue;
        ONOXMLElement *imgChild = [child firstChildWithTag:@"img"];
        imgUrlStr = imgChild[@"src"];
    }
    NSMutableDictionary *dictionary = [@{@"title" : title} mutableCopy];
    if (imgUrlStr) {
        dictionary[@"img"] = imgUrlStr;
    }
    return dictionary;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
