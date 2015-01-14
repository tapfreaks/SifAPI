//
//  ViewController.swift
//  SifAPIExample
//
//  Created by IOS Developer on 1/14/15.
//  Copyright (c) 2015 TapFreaks.NeT. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    @IBOutlet var myImage:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func simple()         {
        
        let sifAPI = SifAPI.shareSifAPI
        sifAPI.method = "GET" // Requesting method POST or GET
        sifAPI.action = "student.php" // Action would be added at the end of your base URL
        sifAPI.params.append(key:"action", value:"1") // Append Paramenters
        // sifAPI.baseURI = "imageURL" // To use other than baseURL check Preferences.swift
        // sifAPI.fromKey = "data" //Extract information from a particular from returning JSON
        // sifAPI.model = "StudentModel" // Map a NSObject class to returning JSON
        // if returning JSON is an array, you would receive NSArray of model calss in syncDataRequest()
        sifAPI.cache = true // If you want to cache the response
        sifAPI.cacheTime = 120 // How long response would remain cache // in seconds
        sifAPI.timeOut = 100 // Request time out, by default its 60 secs
        
        sifAPI.syncDataRequest() { (response:AnyObject) in
            var resString = NSString(data: response as NSData, encoding:NSUTF8StringEncoding)
            println(resString)
        }
        
    }
    @IBAction func fromKey()        {
        let sifAPI = SifAPI.shareSifAPI
        sifAPI.method = "GET" // Requesting method POST or GET
        sifAPI.action = "student.php" // Action would be added at the end of your base URL
        sifAPI.params.append(key:"action", value:"1") // Append Paramenters
        // sifAPI.baseURI = "imageURL" // To use other than baseURL check Preferences.swift
        sifAPI.fromKey = "reason" //Extract information from a particular from returning JSON
        // sifAPI.model = "StudentModel" // Map a NSObject class to returning JSON
        // if returning JSON is an array, you would receive NSArray of model calss in syncDataRequest()
        sifAPI.cache = true // If you want to cache the response
        sifAPI.cacheTime = 120 // How long response would remain cache // in seconds
        sifAPI.timeOut = 100 // Request time out, by default its 60 secs
        
        sifAPI.syncDataRequest() { (response:AnyObject) in
            println(response)
        }
    }
    @IBAction func mapObject()      {
        let sifAPI = SifAPI.shareSifAPI
        sifAPI.method = "GET" // Requesting method POST or GET
        sifAPI.action = "student.php" // Action would be added at the end of your base URL
        sifAPI.params.append(key:"action", value:"1") // Append Paramenters
        // sifAPI.baseURI = "imageURL" // To use other than baseURL check Preferences.swift
        sifAPI.fromKey = "student" //Extract information from a particular from returning JSON
        sifAPI.model = "studentModel" // Map a NSObject class to returning JSON
        // if returning JSON is an array, you would receive NSArray of model calss in syncDataRequest()
        sifAPI.cache = true // If you want to cache the response
        sifAPI.cacheTime = 120 // How long response would remain cache // in seconds
        sifAPI.timeOut = 100 // Request time out, by default its 60 secs
        
        sifAPI.syncDataRequest() { (response:AnyObject) in
            println(response)
            if let student = response as? studentModel {
                println("ID \(student.id)")
                println("Name \(student.name)")
            }
        }
    }
    @IBAction func mapObjectArray() {
        let sifAPI = SifAPI.shareSifAPI
        sifAPI.method = "GET" // Requesting method POST or GET
        sifAPI.action = "student.php" // Action would be added at the end of your base URL
        sifAPI.params.append(key:"action", value:"2") // Append Paramenters
        // sifAPI.baseURI = "imageURL" // To use other than baseURL check Preferences.swift
        sifAPI.fromKey = "student" //Extract information from a particular from returning JSON
        sifAPI.model = "studentModel" // Map a NSObject class to returning JSON
        // if returning JSON is an array, you would receive NSArray of model calss in syncDataRequest()
        sifAPI.cache = true // If you want to cache the response
        sifAPI.cacheTime = 120 // How long response would remain cache // in seconds
        sifAPI.timeOut = 100 // Request time out, by default its 60 secs
        
        sifAPI.syncDataRequest() { (response:AnyObject) in
            println(response)
            
            if let studentArray = response as? NSArray {
                for student in studentArray {
                    if let student = student as? studentModel {
                        println("ID \(student.id)")
                        println("Name \(student.name)")
                    }
                }
            }
        }

    }
    @IBAction func simImagCache()   {
        
        var sifImg = SifImageCache()
        sifImg.baseURL = "imageURL" //To use other than baseURL check Preferences.swift
        sifImg.getImage("me.jpg") { (image: UIImage) in
            // self.view.cellImage!.image = image // Image would be loaded from internet for first time only, next time it would be loaded from local resources.
            self.myImage.image = image
        }
    }

}

