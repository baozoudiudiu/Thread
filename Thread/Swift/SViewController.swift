//
//  SViewController.swift
//  Thread
//
//  Created by chenwang on 2018/1/9.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

let condition = NSCondition()

class SViewController : UIViewController {
    //MARK: life cycle
    override func viewDidLoad() {
        let space: CGFloat = 100
        let btnWidth: CGFloat = 100
        let btnHeight: CGFloat = 50
        let pThreadBtn = self.createBtn(title: "pthread", action: #selector(pThread_test), frame: CGRect(x: space, y: space, width: btnWidth, height: btnHeight))
        self.view.addSubview(pThreadBtn)
        self.view.addSubview(self.createBtn(title: "NSThread", action: #selector(NSThread_test), frame: CGRect(x: space, y: space +  btnHeight, width: btnWidth, height: btnHeight)));
        self.view.addSubview(self.createBtn(title: "perform", action: #selector(performTest), frame: CGRect(x: space, y: space + btnHeight * 2, width: btnWidth, height: btnHeight)));
        self.view.addSubview(self.createBtn(title: "GCD", action: #selector(gcd_test), frame: CGRect(x: space, y: space + btnHeight * 3, width: btnWidth, height: btnHeight)));
    }
    override func didReceiveMemoryWarning() {
        
    }
    
    @objc private func gcd_test() -> Void {
        let vc = SGCDViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createBtn(title: String, action: Selector, frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(UIColor.orange, for: .normal)
        button.frame = frame
        button.setTitle(title, for: .normal)
        return button
    }
    var count = 1000
    let run : @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? =
    { (pktlist:UnsafeMutableRawPointer) in
        while true {
            condition.lock()
            let p:UnsafeMutableRawPointer = pktlist
            let t = p.assumingMemoryBound(to: Int.self)
            guard t.pointee > 0 else {
                condition.unlock()
                break;
            }
            t.pointee -= 1;
            NSLog("%d", t.pointee)
            condition.unlock()
        }
        return nil
    }
    //MARK: Event Response
    @objc private func pThread_test() -> Void
    {
        self.count = 1000
        for i in 0..<4
        {
            if i < 4
            {
                let pthread: UnsafeMutablePointer<pthread_t?> = UnsafeMutablePointer<pthread_t?>.allocate(capacity: MemoryLayout<pthread_t?>.size)
                let param = UnsafeMutableRawPointer(&count)
                let success = pthread_create(pthread, nil, self.run, param)
                if success == 0 {
                    NSLog("开启线程...")
                }
                pthread_detach((pthread.pointee)!)
                pthread.deinitialize()
                pthread.deallocate(capacity: MemoryLayout<pthread_t?>.size)
            }
        }
    }
    //MARK: NSThread
    @objc private func NSThread_test() -> Void {
        let thread2 = Thread(block: {
            for i in 0..<10 {
                guard !Thread.current.isCancelled else {
                    break;
                }
                print("\(i)")
                if i == 5 {
                    Thread.current.cancel()
                }
            }
        })
        thread2.start()
        thread2.name = "threadName"
        thread2.threadPriority = 0.8
    }
    
    @objc private func testMethod() -> Void {
        NSLog("开始调用!!!")
    }
    
    @objc private func performTest() -> Void {
        NSLog("设置方法!!!")
        ///< 默认模式
        self.perform(#selector(testMethod), with: nil, afterDelay: 3, inModes: [RunLoopMode.defaultRunLoopMode])
        ///<UITrackingRunLoopMode
        self.perform(#selector(testMethod), with: nil, afterDelay: 3, inModes: [RunLoopMode.UITrackingRunLoopMode])
        ///<common
        self.perform(#selector(testMethod), with: nil, afterDelay: 3, inModes: [RunLoopMode.commonModes])
    }
}
