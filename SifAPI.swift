//
//  SifAPI.swift
//  Paid App
//
//  Created by IOS Developer on 12/26/14.
//  Copyright (c) 2014 TapFreaks.NeT. All rights reserved.
//  Author : Mohammad Asif
//  Enjoye :)
//

import Foundation
import UIKit
private let _shareSifAPI:SifAPI = SifAPI()

class SifAPI:NSObject {
   
    class var shareSifAPI:SifAPI {
        return _shareSifAPI
    }
    
    var url:NSURL
    var method:String
    var timeOut:Double
    var params:[(key:String, value:String)]
    var cache:Bool
    var cacheTime:Int
    var action:String
    var baseURI:String
    
    var model:String
    var fromKey:String
    
    private var modelKeys:[String]
    
    override init() {
        self.url = NSURL()
        self.method = NSString()
        self.params = []
        self.timeOut = 0
        self.cache = false
        self.action = String()
        self.model = String()
        self.fromKey = String()
        self.modelKeys = []
        self.cacheTime = 60 // Seconds - by default
        self.baseURI = String() // If you need any other baseURL, defined in Preferences
    }
    
    // Public Section
    func syncDataRequest(completionHandler:(response:AnyObject) -> ()) {
        
        var oURL:String = String()
        
        if countElements(baseURI) > 0 {
            if Prefs.respondsToSelector(NSSelectorFromString(baseURI)) {
                oURL = "\(Prefs.valueForKey(baseURI)!)\(action)"
            } else {
                println("URI not found in Preferences.swift")
                return
            }
        } else {
            oURL = Prefs.baseURL + action
        }
        
        
        oURL = oURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var request = NSMutableURLRequest(URL: NSURL(string: oURL )!)
        var session = NSURLSession.sharedSession()
        
        if self.method.utf16Count > 0 {
            request.HTTPMethod = method
        } else {
            request.HTTPMethod = "GET"
        }
        
        var err: NSError?
        if self.params.count > 0 {
            if self.method == "POST" {
                var bodyData:String = String()
                for item in self.params {
                    bodyData = bodyData + item.key + "=" + item.value + "&"
                }
                bodyData = bodyData.substringToIndex(bodyData.endIndex.predecessor())
                request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding,
                    allowLossyConversion: false)
            } else {
                
                var x = 0
                for item in self.params {
                    if x == 0 {
                        oURL = oURL + "?" + item.key + "=" + item.value
                    } else {
                        oURL = oURL + "&" + item.key + "=" + item.value
                    }
                    x++
                }
                oURL = oURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                request.URL = NSURL(string: oURL)
            }
        }
        
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            //var datastring: String = NSString(data:data, encoding:NSUTF8StringEncoding)!
            //println(datastring)
            
            if data.length == 0 {
                println("Nothing recieved !")
                completionHandler(response: false)
                return ;
            }
            if self.cache {
                self.cacheResponse(request.URL!.absoluteString!, response: data)
            }
            var assRes:AnyObject = self.assembleResponse(data)
            completionHandler(response: assRes)
            
        })
        
        println(request.URL!.absoluteString!)
        
        if self.timeOut != 0 {
            request.timeoutInterval = timeOut
        }
        if self.cache {
            var (time, isValid) = self.hasValidCache(request.URL!.absoluteString!)
            if isValid {
                println("Valid caching found, with \(time) secs remaining")
                var cacheObj = self.getCacheObject(request.URL!.absoluteString!)
                var assRes:AnyObject = self.assembleResponse(cacheObj)
                completionHandler(response: assRes)
            } else {
                println("Invalid caching found !")
                task.resume()
            }
        } else {
            task.resume()
        }
        
    }
    func testParse() {
        self.extractModelKeys()
    }
    
    // Private Section
    private func assembleResponse(var data:NSData) -> AnyObject         {
        
        if self.model.utf16Count > 0 {
            
            self.extractModelKeys()
            
            var err: NSError?
            NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &err)
            if err != nil {
                println("Invalid JSON")
                return false
            }
            
            var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &err) as NSDictionary
            
            if self.fromKey.utf16Count > 0 {
                
                if json.valueForKey(self.fromKey) != nil {
                    
                    if let jsonArr = json.valueForKey(self.fromKey)! as? NSArray {
                        var genArray = self.mapArrayToModel(jsonArr)
                        return genArray
                    } else {
                        var dict = json.valueForKey(self.fromKey)! as NSDictionary
                        var mappedObj:AnyObject = self.mapObjectToModel(dict)
                        return mappedObj
                    }
                    
                } else {
                    println("Key \(self.fromKey) not found in JSON")
                }
                
            } else {
                var mappedObj:AnyObject = self.mapObjectToModel(json)
                return mappedObj
            }
        } else {
            if self.fromKey.utf16Count > 0 {
                
                var err: NSError?
                NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &err)
                if err != nil {
                    println("Invalid JSON")
                    return false
                }
                
                var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: &err) as NSDictionary
                
                if json.valueForKey(self.fromKey) != nil {
                    return json.valueForKey(self.fromKey)!
                } else {
                    println("Key \(self.fromKey) not found in JSON")
                }
                
            } else {
                return data
            }
        }
        return false
    }
    
    // Cache Functions
    private func getCacheObject(request:String) -> NSData               {
        var Dataproxy = NSUserDefaults.standardUserDefaults()
        
        if Dataproxy.valueForKey(request) != nil {
            var cachObj = Dataproxy.valueForKey(request)! as [String:AnyObject]
            var cache:NSData = cachObj["response"]! as NSData
            return cache
        }
        
        return NSData()
    }
    private func hasValidCache(request:String) -> (Int, Bool)           {
        var Dataproxy = NSUserDefaults.standardUserDefaults()
        var date = NSDate()
        
        if Dataproxy.valueForKey(request) != nil {
            var cachObj = Dataproxy.valueForKey(request)! as [String:AnyObject]
            var cacheTime:NSDate = cachObj["time"]! as NSDate
            var now:NSDate = NSDate()
            var compare = now.compare(cacheTime) == NSComparisonResult.OrderedAscending
            var remainingCacheTime = 0
            if compare {
                remainingCacheTime = Int(cacheTime.timeIntervalSinceDate(now))
            }
            return (remainingCacheTime, compare)
        }
        
        Dataproxy.synchronize()
        return (0, false)
    }
    private func cacheResponse(request:String, response:NSData)         {
        var Dataproxy = NSUserDefaults.standardUserDefaults()
        var date = NSDate()
        date = date.dateByAddingTimeInterval(Double(self.cacheTime))
        var cachObj:[String:AnyObject] = ["time": date, "response": response]
        Dataproxy.setObject(cachObj, forKey: request)
        Dataproxy.synchronize()
    }
    
    // Mapping Functions
    private func extractModelKeys() {
        
        if countElements(self.model) == 0 {
            return
        }
        
        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String? {
            
            appName = appName!.stringByReplacingOccurrencesOfString(" ", withString: "_",
                options: nil, range: nil)
            let validModelName = "\(appName!).\(self.model)"
            
            var count: UInt32 = 0
            var properties = class_copyPropertyList(NSClassFromString(validModelName) , &count)
            if count > 0 {
                
                self.modelKeys.removeAll(keepCapacity: false)
                
                for var i = 0; i < Int(count); ++i {
                    let property: objc_property_t = properties[i]
                    let name:String = NSString(CString:
                        property_getName(property), encoding: NSUTF8StringEncoding)!
                    self.modelKeys.append(name)
                }
            }
        }
    }
    private func underscoreToCamelCase(string: String) -> String        {
        var items: [String] = string.componentsSeparatedByString("_")
        var camelCase = ""
        var isFirst = true
        for item: String in items {
            if isFirst == true {
                isFirst = false
                camelCase += item
            } else {
                camelCase += item.capitalizedString
            }
        }
        return camelCase
    }
    private func mapArrayToModel(var arr:[AnyObject]) -> [AnyObject]    {
        
        var modelArray:[AnyObject] = Array()
        
        for item in arr {
            if let dict = item as? NSDictionary {
                var mappedObj:AnyObject = self.mapObjectToModel(dict)
                modelArray.append(mappedObj)
            }
        }
        
        return modelArray
    }
    private func mapObjectToModel(var dict:NSDictionary) -> AnyObject   {
        
        if  var appName: String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as String? {
            
            appName = appName!.stringByReplacingOccurrencesOfString(" ", withString: "_", options: nil, range: nil)
            let validModelName = "\(appName!).\(self.model)"
            
            var anyobjectype : AnyObject.Type = NSClassFromString(validModelName)
            var nsobjectype : NSObject.Type = anyobjectype as NSObject.Type
            var modelObj: AnyObject = nsobjectype()
            
            for key in self.modelKeys {
                if dict.valueForKey(key) != nil {
                    
                    
                    var ObjkeyValue:AnyObject = modelObj.valueForKey(key)!
                    var JsnkeyValue:AnyObject = dict.valueForKey(key)!
                    
                    if ObjkeyValue.isKindOfClass(JsnkeyValue.classForCoder) {
                        modelObj.setValue(dict.valueForKey(key)!, forKey: key)
                    } else {
                        var mdlClass = object_getClassName(ObjkeyValue)
                        var jsnClass = object_getClassName(JsnkeyValue)
                        var clsNameMdl = String.fromCString(mdlClass)
                        var clsNameJsn = String.fromCString(jsnClass)
                        println("\(key):\(clsNameMdl!) unable to set \(clsNameJsn!) value")
                    }
                    
                } else {
                    println("Key \(key) not found !")
                }
            }
            return modelObj
        }
        
        return ""
    }
}
