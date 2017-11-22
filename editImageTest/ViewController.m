//
//  ViewController.m
//  editImageTest
//
//  Created by pjpjpj on 2017/11/21.
//  Copyright © 2017年 #incloud. All rights reserved.
//

#import "ViewController.h"
#import "PJEditImageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:btn];
    [btn setTitle:@"2333" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
 
}

- (void)btnClick {
    PJEditImageViewController *vc = [PJEditImageViewController new];
    vc.inputImage = [UIImage imageNamed:@"timg"];
    [self presentViewController:vc animated:true completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
