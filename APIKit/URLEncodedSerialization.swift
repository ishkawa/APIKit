import Foundation

private func escape(string: String) -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue) as! String
}

private func unescape(string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string, nil) as! String
}

public class URLEncodedSerialization {
    public class func objectFromData(data: NSData, encoding: NSStringEncoding, error: NSErrorPointer) -> AnyObject? {
        var dictionary: [String: AnyObject]?
        
        if let string = NSString(data: data, encoding: encoding) as? String {
            dictionary = [String: AnyObject]()
            
            for pair in string.componentsSeparatedByString("&") {
                let contents = pair.componentsSeparatedByString("=")
                
                if contents.count == 2 {
                    dictionary?[contents[0]] = unescape(contents[1])
                }
            }
        }
        
        if dictionary == nil {
            let userInfo = [NSLocalizedDescriptionKey: "failed to decode urlencoded string."]
            error.memory = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
        }
        
        return dictionary
    }
    
    public class func dataFromObject(object: AnyObject, encoding: NSStringEncoding, error: NSErrorPointer) -> NSData? {
        let string = stringFromObject(object, encoding: encoding)
        let data = string.dataUsingEncoding(encoding, allowLossyConversion: false)
        
        if data == nil {
            let userInfo = [NSLocalizedDescriptionKey: "failed to decode urlencoded string."]
            error.memory = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
        }
        
        return data
    }
    
    public class func stringFromObject(object: AnyObject, encoding: NSStringEncoding) -> String {
        var pairs = [String]()
        
        if let dictionary = object as? [String: AnyObject] {
            for (key, value) in dictionary {
                let string = (value as? String) ?? "\(value)"
                let pair = "\(key)=\(escape(string))"
                pairs.append(pair)
            }
        }
        
        return join("&", pairs)
    }
}
