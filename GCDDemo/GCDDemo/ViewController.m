//
//  ViewController.m
//  GCDDemo
//
//  Created by Wang on 16/4/27.
//  Copyright © 2016年 云客. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self dispatch_barrier2];
}

#pragma mark - 1、同步执行 
#pragma mark (1) 死锁
- (void)sync_inSame_queue{
    __block NSInteger sum = 0;
    NSLog(@"before gcd");
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 1000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd :%ld",(long)sum);
    });
    NSLog(@"after gcd");
}

/** 解释：
 dispatch_sync runs a block on a given queue and waits for it to complete. In this case, the queue is the main dispatch queue. The main queue runs all its operations on the main thread, in FIFO (first-in-first-out) order. That means that whenever you call dispatch_sync, your new block will be put at the end of the line, and won't run until everything else before it in the queue is done.
 同步执行 会在给定的队列里面执行block，而且会等待block执行完毕。上面这种情况，block实在main队列里面执行的。main队列会在主线程里面按照先进先出的原则，执行所有的操作。这就意味着当以调用dispatch_sync时，新的block会被放到最后，知道多有的操作都执行完以后 才会被调用。

 */

#pragma mark (2) 不死锁
- (void)sync_inOthe_Queue{
    __block NSInteger sum = 0;
    NSLog(@"before gcd");
     // 非ARC需要释放手动创建的队列 dispatch_release(queue)
    dispatch_queue_t newQueue = dispatch_queue_create([@"WKJ" UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_sync(newQueue, ^{
        for (NSInteger i = 0; i < 1000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd :%ld",(long)sum);
    });
    NSLog(@"after gcd");
}
/* log:
 2016-04-27 11:02:20.873 GCDDemo[27533:3958566] before gcd
 2016-04-27 11:02:20.873 GCDDemo[27533:3958566] in gcd :499500
 2016-04-27 11:02:20.874 GCDDemo[27533:3958566] after gcd
 */

#pragma mark - 异步执行
- (void)async_inMain_Queue{
    __block NSInteger sum = 0;
    NSLog(@"before gcd");
    dispatch_queue_t newQueue = dispatch_queue_create([@"WKJ" UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(newQueue, ^{
        for (NSInteger i = 0; i < 1000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd :%ld",(long)sum);
    });
    NSLog(@"after gcd");
}

/* log:
 2016-04-27 11:05:07.073 GCDDemo[27553:3961579] before gcd
 2016-04-27 11:05:07.073 GCDDemo[27553:3961579] after gcd
 2016-04-27 11:05:07.073 GCDDemo[27553:3961614] in gcd :499500
*/

#pragma mark - 串行队列
//dispatch_queue_create(["queue name", DISPATCH_QUEUE_SERIAL) 创建串行队列
//dispatch_get_main_queue 主队列是GCD自带的一种特殊的串行队列,放在主队列中的任务，都会放到主线程中执行

#pragma mark mainQueue
- (void)serial_Main_Queue{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"1、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"4、%@",[NSThread currentThread]);
    });
}
/* log:
 2016-04-27 11:15:58.520 GCDDemo[27569:3972464] 1、<NSThread: 0x7f8d796053c0>{number = 1, name = main}
 2016-04-27 11:15:58.522 GCDDemo[27569:3972464] 2、<NSThread: 0x7f8d796053c0>{number = 1, name = main}
 2016-04-27 11:15:58.522 GCDDemo[27569:3972464] 3、<NSThread: 0x7f8d796053c0>{number = 1, name = main}
 2016-04-27 11:15:58.522 GCDDemo[27569:3972464] 4、<NSThread: 0x7f8d796053c0>{number = 1, name = main}
*/

#pragma mark create queue
- (void)serial_Create_Queue{
    dispatch_queue_t queue = dispatch_queue_create([@"WKJ" UTF8String], DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"1、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"2、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"3、%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"4、%@",[NSThread currentThread]);
    });
}
/* log: 在同一个线程里面 顺序执行
 2016-04-27 11:18:25.192 GCDDemo[27580:3974104] 1、<NSThread: 0x7ff6735039c0>{number = 2, name = (null)}
 2016-04-27 11:18:25.193 GCDDemo[27580:3974104] 2、<NSThread: 0x7ff6735039c0>{number = 2, name = (null)}
 2016-04-27 11:18:25.193 GCDDemo[27580:3974104] 3、<NSThread: 0x7ff6735039c0>{number = 2, name = (null)}
 2016-04-27 11:18:25.193 GCDDemo[27580:3974104] 4、<NSThread: 0x7ff6735039c0>{number = 2, name = (null)}
 */

- (void)serial_Create_Queue2{
    NSLog(@"before gcd");
    dispatch_queue_t queue = dispatch_queue_create([@"WKJ" UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 10000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd 1 :%ld",(long)sum);
    });
    dispatch_async(queue, ^{
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 500; i ++) {
            sum += i;
        }
        NSLog(@"in gcd 2 :%ld",(long)sum);
    });
    dispatch_async(queue, ^{
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 1000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd 3 :%ld",(long)sum);
    });
    dispatch_async(queue, ^{
        NSInteger sum = 0;
        for (NSInteger i = 0; i < 2000; i ++) {
            sum += i;
        }
        NSLog(@"in gcd 4 :%ld",(long)sum);
    });
    NSLog(@"after gcd");
}
/* log:
 2016-04-27 11:23:52.426 GCDDemo[27625:3978769] before gcd
 2016-04-27 11:23:52.426 GCDDemo[27625:3978769] after gcd
 2016-04-27 11:23:52.426 GCDDemo[27625:3978807] in gcd 1 :49995000
 2016-04-27 11:23:52.426 GCDDemo[27625:3978807] in gcd 2 :124750
 2016-04-27 11:23:52.427 GCDDemo[27625:3978807] in gcd 3 :499500
 2016-04-27 11:23:52.427 GCDDemo[27625:3978807] in gcd 4 :1999000
 */

#pragma mark - 并行队列
- (void)async_Concurrent_Queue{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(concurrentQueue, ^{
        NSLog(@"1、%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"2、%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"3、%@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"4、%@",[NSThread currentThread]);
    });
}
/* log: 不在同一个线程里面执行
2016-04-27 11:28:06.813 GCDDemo[27636:3981562] 3、<NSThread: 0x7fc943d1a590>{number = 4, name = (null)}
2016-04-27 11:28:06.813 GCDDemo[27636:3981576] 4、<NSThread: 0x7fc943d0c4a0>{number = 5, name = (null)}
2016-04-27 11:28:06.813 GCDDemo[27636:3981568] 1、<NSThread: 0x7fc943c0c3d0>{number = 2, name = (null)}
2016-04-27 11:28:06.813 GCDDemo[27636:3981554] 2、<NSThread: 0x7fc943d0bb80>{number = 3, name = (null)}
*/

- (void)async_Concurrent_Queue2{
    NSLog(@"main thread: %@",[NSThread mainThread]);
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"1、%@",[NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"2、%@",[NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"3、%@",[NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        NSLog(@"4、%@",[NSThread currentThread]);
    });
}
/* log: 失去并发作用 都在主线程执行
 2016-04-27 11:40:18.204 GCDDemo[27691:3993391] main thread: <NSThread: 0x7fff49605070>{number = 1, name = main}
 2016-04-27 11:40:18.204 GCDDemo[27691:3993391] 1、<NSThread: 0x7fff49605070>{number = 1, name = main}
 2016-04-27 11:40:18.204 GCDDemo[27691:3993391] 2、<NSThread: 0x7fff49605070>{number = 1, name = main}
 2016-04-27 11:40:18.204 GCDDemo[27691:3993391] 3、<NSThread: 0x7fff49605070>{number = 1, name = main}
 2016-04-27 11:40:18.205 GCDDemo[27691:3993391] 4、<NSThread: 0x7fff49605070>{number = 1, name = main}
 */

#pragma mark - dispatch_group_async
//dispatch_group_async可以实现监听一组任务是否完成，
//完成后得到通知执行其他的操作。
- (void)dispatch_group{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"1、%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2、%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"3、%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"4、%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, concurrentQueue, ^{
        NSLog(@"notify、%@",[NSThread currentThread]);
    });
}
/* log: 倒数两行实在同一个线程里面执行的，
 2016-04-27 11:47:16.701 GCDDemo[27719:3998723] 3、<NSThread: 0x7f8959c152e0>{number = 3, name = (null)}
 2016-04-27 11:47:16.701 GCDDemo[27719:3998719] 2、<NSThread: 0x7f8959f11d60>{number = 4, name = (null)}
 2016-04-27 11:47:16.701 GCDDemo[27719:3998731] 4、<NSThread: 0x7f8959d7faf0>{number = 5, name = (null)}
 2016-04-27 11:47:16.701 GCDDemo[27719:3998713] 1、<NSThread: 0x7f8959c201e0>{number = 2, name = (null)}
 2016-04-27 11:47:16.702 GCDDemo[27719:3998713] notify、<NSThread: 0x7f8959c201e0>{number = 2, name = (null)}
*/

#pragma mark - dispatch_barrier_async
//dispatch_barrier_async是在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
//dispatch_queue_create创建的，而且attr参数值必需是DISPATCH_QUEUE_CONCURRENT
//dispatch_get_global_queue 不行
- (void)dispatch_barrier{
#warning 只有使用DISPATCH_QUEUE_CONCURRENT 这个参数时才起作用
    dispatch_queue_t queue = dispatch_queue_create("WKJ", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"dispatch_async1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async2");
    });
//    dispatch_async(queue, ^{
//        NSLog(@"dispatch_barrier_async");
//        [NSThread sleepForTimeInterval:0.5];
//        
//    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:0.5];
        
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async3");
    });

}
/*
 使用dispatch_async log：
 2016-04-27 12:06:13.286 GCDDemo[27772:4016681] dispatch_barrier_async
 2016-04-27 12:06:14.291 GCDDemo[27772:4016688] dispatch_async3
 2016-04-27 12:06:14.291 GCDDemo[27772:4016675] dispatch_async2
 2016-04-27 12:06:16.288 GCDDemo[27772:4016668] dispatch_async1

 使用dispatch_barrier_async log：
 2016-04-27 12:07:27.061 GCDDemo[27784:4017769] dispatch_async2
 2016-04-27 12:07:29.060 GCDDemo[27784:4017762] dispatch_async1
 2016-04-27 12:07:29.060 GCDDemo[27784:4017762] dispatch_barrier_async
 2016-04-27 12:07:30.568 GCDDemo[27784:4017762] dispatch_async3
 */

- (void)dispatch_barrier2{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"dispatch_async1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async2");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:0.5];
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"dispatch_async3");
    });
    
}
/*
  log：
 2016-04-27 12:17:02.780 GCDDemo[27853:4027914] dispatch_barrier_async
 2016-04-27 12:17:03.785 GCDDemo[27853:4027922] dispatch_async3
 2016-04-27 12:17:03.785 GCDDemo[27853:4027903] dispatch_async2
 2016-04-27 12:17:05.784 GCDDemo[27853:4027910] dispatch_async1
 */
// 说明dispatch_barrier_async的顺序执行还是依赖queue的类型啊，必需要queue的类型为dispatch_queue_create创建的，而且attr参数值必需是DISPATCH_QUEUE_CONCURRENT类型，前面两个非dispatch_barrier_async的类型的执行是依赖其本身的执行时间的，如果attr如果是DISPATCH_QUEUE_SERIAL时，那就完全是符合Serial queue的FIFO特征了。








#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
