import Foundation

private func escape(string: String) -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
}

private func unescape(string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string, nil)
}

public class URLEncodedSerialization {
    public class func objectFromData(data: NSData, encoding: NSStringEncoding, inout error: NSError?) -> AnyObject? {
        var dictionary: [String: AnyObject]?
        
        if let string = NSString(data: data, encoding: encoding) as? String {
            dictionary = [String: AnyObject]()
            
            for pair in split(string, { $0 == "&" }) {
                let contents = split(pair, { $0 == "=" })
                
                if contents.count == 2 {
                    dictionary?[contents[0]] = unescape(contents[1])
                }
            }
        }
        
        if dictionary == nil {
            let userInfo = [NSLocalizedDescriptionKey: "failed to decode urlencoded string."]
            error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
        }
        
        return dictionary
    }
    
    public class func dataFromObject(object: AnyObject, encoding: NSStringEncoding, inout error: NSError?) -> NSData? {
        let string = stringFromObject(object, encoding: encoding)
        let data = string.dataUsingEncoding(encoding, allowLossyConversion: false)
        
        if data == nil {
            let userInfo = [NSLocalizedDescriptionKey: "failed to decode urlencoded string."]
            error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
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
