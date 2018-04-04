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
    [self demoCode];
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
        case 4: {
            [self group_test];
        }
            break;
        case 5: {
            [self group_asynBlock];
        }
            break;
        case 6: {
            [self barrier];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Logic Helper
- (void)demoCode {
    
}

- (void)barrier {
    NSInteger count = 3;
    dispatch_queue_t queue = dispatch_queue_create("queue_label", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for(int i = 0; i < count; i++) {
            NSLog(@"Thread1 --> %d", i);
        }
    });
    
    dispatch_async(queue, ^{
        for(int i = 0; i < count; i++) {
            NSLog(@"Thread2 --> %d", i);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        for(int i = 0; i < count; i++) {
            NSLog(@"barrier --> %d", i);
        }
    });
    
    dispatch_async(queue, ^{
        for(int i = 0; i < count; i++) {
            NSLog(@"Thread3 --> %d", i);
        }
    });
}

- (void)group_asynBlock {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"group 开始执行 !!!");
   
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"block1 begin !!!");
        [self request:1 block:^{
            dispatch_group_leave(group);
        }];
        NSLog(@"block1 end !!!");
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"block2 begin !!!");
        [self request:2 block:^{
            dispatch_group_leave(group);
        }];
        NSLog(@"block2 end !!!");
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"block3 begin !!!");
        [self request:3 block:^{
            dispatch_group_leave(group);
        }];
        NSLog(@"block3 end !!!");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"group 结束 !!!");
    });
}

- (void)request:(NSInteger)count block:(void(^)(void))complete{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"请求%ld 开始 !!!", count);
        [NSThread sleepForTimeInterval:3];
         NSLog(@"请求%ld 结束 !!!", count);
        if(complete)
            complete();
    });
}

- (void)group_test {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"调度组开始执行!!!");
    dispatch_group_async(group, queue, ^{
        for(int i = 0; i < 6; i++) {
            NSLog(@"thread1 -> %d", i);
        }
    });
    dispatch_group_async(group, queue, ^{
        for(int i = 0; i < 6; i++) {
            NSLog(@"thread2 -> %d", i);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for(int i = 0; i < 6; i++) {
            NSLog(@"thread3 -> %d", i);
        }
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"所有循环执行完毕!!!");
    });
}

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
                            @"异步并行",
                            @"调度组:同步任务",
                            @"调度组:异步任务",
                            @"栅栏",
                            @"挂起"];
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
