//
//  GCDViewController.m
//  Thread
//
//  Created by chenwang on 2018/1/19.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import "GCDViewController.h"

static NSString *cellId = @"cellId";
@interface GCDViewController ()<UITableViewDelegate, UITableViewDataSource>
//UI
@property (nonatomic, strong) UITableView *tableView;

//Data
@property (nonatomic, strong) NSArray     *dataSource;
@end

@implementation GCDViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureUI];
}

#pragma mark - Configure UI
- (void)configureUI {
    self.navigationItem.title = @"GCD";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
}

- (void)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            [self sync_serial];
        }
            break;
        case 1: {
            [self sync_Concurrent];
        }
            break;
        case 2: {
            [self async_serial];
        }
            break;
        case 3: {
            [self async_concurrent];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Logic Helper
- (void)sync_serial {
    NSLog(@"mian_start");
    dispatch_queue_t queue = dispatch_queue_create("111", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        [self taskBegin];
    });
    dispatch_sync(queue, ^{
         [self taskBegin];
    });
    dispatch_sync(queue, ^{
         [self taskBegin];
    });
    NSLog(@"mian_end");
}

- (void)sync_Concurrent {
    NSLog(@"mian_start");
    dispatch_queue_t queue = dispatch_queue_create("222", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        [self taskBegin];
    });
    dispatch_sync(queue, ^{
        [self taskBegin];
    });
    dispatch_sync(queue, ^{
        [self taskBegin];
    });
    NSLog(@"mian_end");
}

- (void)async_serial {
    NSLog(@"mian_start");
    dispatch_queue_t queue = dispatch_queue_create("333", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    NSLog(@"mian_end");
}

- (void)async_concurrent {
    NSLog(@"mian_start");
    dispatch_queue_t queue = dispatch_queue_create("333", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    dispatch_async(queue, ^{
        [self taskBegin];
    });
    NSLog(@"mian_end");
}

- (void)taskBegin {
    NSThread *thread = [NSThread currentThread];
    NSLog(@"tread_begin ,%@",thread);
    [NSThread sleepForTimeInterval:3];
    NSLog(@"tread_end ,%@",thread);
}

#pragma mark - Property
- (NSArray *)dataSource {
    if(!_dataSource) {
        self.dataSource = @[@"同步串行",
                            @"同步并行",
                            @"异步串行",
                            @"异步并行"];
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
