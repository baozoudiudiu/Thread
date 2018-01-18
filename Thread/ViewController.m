//
//  ViewController.m
//  Thread
//
//  Created by chenwang on 2018/1/9.
//  Copyright © 2018年 chenwang. All rights reserved.
//

#import "ViewController.h"
#import "NSArray+safe.h"
//
#import <pthread.h>
#import "Thread-Swift.h"

static NSCondition *condition = nil;

@interface ViewController ()

@property (nonatomic, assign) NSInteger     count;
@property (nonatomic, strong) NSThread      *thread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.count = 1000;
    CGFloat btnWidth = 100;
    CGFloat btnHeight = 50;
    CGFloat space = 20;
    UIButton *pThreadBtn = [self createBtnWithTtitle:@"pThread" selector:@selector(pThread_test) frame:CGRectMake(space, space, btnWidth, btnHeight)];
    [self.view addSubview:pThreadBtn];
    
    UIButton *NSThread = [self createBtnWithTtitle:@"NSThread" selector:@selector(NSThread_test) frame:CGRectMake(space, space + btnHeight, btnWidth, btnHeight)];
    [self.view addSubview:NSThread];
}

#pragma mark - Event Response
- (void)pThread_test {
    self.count = 1000;
    for(int i = 0; i < 4; i++) {
        [self create_pThread];
    }
}

- (void)NSThread_test {
//    if(self.thread && (!self.thread.isFinished && !self.thread.isCancelled)) {
//        [self.thread start];
//        return;
//    }
//    //静态创建方法
    NSThread *thread1 = [[NSThread alloc] initWithBlock:^{
        for(int i = 0; i < 10; i++) {
            NSLog(@"%d", i);
            if(i == 5) {
                [self performSelectorOnMainThread:@selector(testMethod) withObject:nil waitUntilDone:NO];
            }
            sleep(1);
        }
    }];
//    self.thread = thread1;
//    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(testMethod) object:nil];
//
    [thread1 setName:@"blockThread"];
//    [thread2 setName:@"targetThread"];
//
    [thread1 setThreadPriority:0.5];
//    [thread2 setThreadPriority:0.8];
//
    [thread1 start];
//    [thread2 start];
}

#pragma mark - Logic Helper
- (void)testMethod {
    sleep(2);
    NSLog(@"----");
}

- (UIButton *)createBtnWithTtitle:(NSString *)title selector:(SEL)selector frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    return button;
}

- (void)create_pThread {
    //创建线程对象
    pthread_t thread;
    //创建线程
    /*
     参数：
     1.指向线程标识符的指针，C 语言中类型的结尾通常 _t/Ref，而且不需要使用 *;
     2.用来设置线程属性;
     3.指向函数的指针,传入函数名(函数的地址)，线程要执行的函数/任务;
     4.运行函数的参数;
     */
    int success = pthread_create(&thread, NULL, run, &(_count));
    if(success == 0) {
        /*
         c语言中,有时成功及成功,错误却会有很多种原因
         所以这里返回0表示开辟线程成功
         非0表示失败开启线程失败
         */
        NSLog(@"开启线程...");
    }
    //这里需要手动设置子线程的状态设置为detached,则该线程运行结束后会自动释放所有资源.否则不会释放.
    pthread_detach(thread);
}

void *run(void* sender) {
    if(!condition) {
        condition = [[NSCondition alloc] init];
    }
    while (1) {
        [condition lock];
        int* s = sender;
        int count = *s;
        if(count <= 0) {
            [condition unlock];
            break;
        }
        test(s);
        [condition unlock];
    }
    return NULL;
}

void test(int *count) {
    static int i = -1;
    if(i == -1)
        i = *count;
    
    *count = *count - 1;
    if(*count == i) {
        NSLog(@"--------------------------------------------");
    }else {
        i = *count;
    }
    NSLog(@"%d", *count);
}

#pragma mark - Property


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
