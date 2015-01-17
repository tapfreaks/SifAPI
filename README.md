SifAPI
======

SifAPI is written for swift (Apple programming language), which manages REST API calling &amp; manage returning results magically.

SifAPI also includes an image caching tool, which allows you to download and cache images.
<br /><br />
<B>SifAPI :</B><br />
<pre>
<code>
let sifAPI = SifAPI.shareSifAPI<br />
sifAPI.method = "GET" // Requesting method POST or GET<br />
sifAPI.action = "student.php" // Action would be added at the end of your base URL<br />
sifAPI.params.append(key:"action", value:"1") // Append Paramenters<br />
// sifAPI.baseURI = "imageURL" // To use other than baseURL check Preferences.swift<br />
// sifAPI.fromKey = "data" //Extract information from a particular from returning JSON<br />
// sifAPI.model = "StudentModel" // Map a NSObject class with returning JSON<br />
// if returning JSON is an array, you would receive NSArray of model calss in syncDataRequest()<br />
sifAPI.cache = true // If you want to cache the response<br />
sifAPI.cacheTime = 120 // How long response would remain cache // in seconds<br />
sifAPI.timeOut = 100 // Request time out, by default its 60 secs<br />
<br />
sifAPI.syncDataRequest() { (response:AnyObject) in<br />
    var resString = NSString(data: response as NSData, encoding:NSUTF8StringEncoding)<br />
    println(resString)<br />
}<br />
</code>
</pre>
<B>SifImageCache :</B>
<pre>
<code>
var sifImg = SifImageCache()<br />
sifImg.baseURL = "imageURL" //To use other than baseURL check Preferences.swift<br />
sifImg.getImage("me.jpg") { (image: UIImage) in<br />
    // self.view.cellImage!.image = image 
    // Image would be loaded from internet for first time only 
    // Next time it would be loaded from local resources.
}
</pre>
</code>
<b>Thanks for using, <a href="http://www.tapfreaks.net/">TapFreaks!</a></b>
