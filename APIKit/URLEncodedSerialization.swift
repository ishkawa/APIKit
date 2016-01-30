import Foundation

private func escape(string: String) -> String {
    // Reserved characters defined by RFC 3986
    // Reference: https://www.ietf.org/rfc/rfc3986.txt
    let generalDelimiters = ":#[]@"
    let subDelimiters = "!$&'()*+,;="
    let reservedCharacters = generalDelimiters + subDelimiters
    
    let allowedCharacterSet = NSMutableCharacterSet()
    allowedCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
    allowedCharacterSet.removeCharactersInString(reservedCharacters)
    
    // Crashes due to internal bug in iOS 7 ~ iOS 8.2.
    // References:
    //   - https://github.com/Alamofire/Alamofire/issues/206
    //   - https://github.com/AFNetworking/AFNetworking/issues/3028
    // return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
    
    let batchSize = 50
    var index = string.startIndex
    
    var escaped = ""
    
    while index != string.endIndex {
        let startIndex = index
        let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
        let range = Range(start: startIndex, end: endIndex)
        
        let substring = string.substringWithRange(range)
        
        escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
        
        index = endIndex
    }
    
    return escaped
}

private func unescape(string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string, nil) as String
}

public final class URLEncodedSerialization {
    public enum Error: ErrorType {
        case CannotGetStringFromData(NSData, NSStringEncoding)
        case CannotGetDataFromString(String, NSStringEncoding)
        case CannotCastObjectToDictionary(AnyObject)
        case InvalidFormatString(String)
    }

    /// - Throws: URLEncodedSerialization.Error
    public static func objectFromData(data: NSData, encoding: NSStringEncoding) throws -> [String: String] {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.CannotGetStringFromData(data, encoding)
        }

        var dictionary = [String: String]()
        for pair in string.componentsSeparatedByString("&") {
            let contents = pair.componentsSeparatedByString("=")

            guard contents.count == 2 else {
                throw Error.InvalidFormatString(string)
            }

            dictionary[contents[0]] = unescape(contents[1])
        }

        return dictionary
    }

    /// - Throws: URLEncodedSerialization.Error
    public static func dataFromObject(object: AnyObject, encoding: NSStringEncoding) throws -> NSData {
        guard let dictionary = object as? [String: AnyObject] else {
            throw Error.CannotCastObjectToDictionary(object)
        }

        let string = stringFromDictionary(dictionary)
        guard let data = string.dataUsingEncoding(encoding, allowLossyConversion: false) else {
            throw Error.CannotGetDataFromString(string, encoding)
        }

        return data
    }
    
    public static func stringFromDictionary(dictionary: [String: AnyObject]) -> String {
        let pairs = dictionary.map { key, value -> String in
            guard let valueAsString = value.description where !(value is NSNull) else {
                return "\(escape(key))"
            }
            
            return "\(escape(key))=\(escape(valueAsString))"
        }

        return pairs.joinWithSeparator("&")
    }
}
