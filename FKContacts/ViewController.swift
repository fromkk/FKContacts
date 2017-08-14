//
//  ViewController.swift
//  FKContacts
//
//  Created by Kazuya Ueoka on 2016/05/17.
//  Copyright © 2016年 Timers inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FKContacts.requestPermission { (status) in
            switch status
            {
            case FKContactsPermissionResults.allowed:
                do {
                    let result: [FKContactItem] = try FKContacts.fetchContacts()
                    print("result! \(result)")
                } catch
                {
                    print("failed...")
                }
                break
            case FKContactsPermissionResults.denied:
                print("denied...")
                break
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

