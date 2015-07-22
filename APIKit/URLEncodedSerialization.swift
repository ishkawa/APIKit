import Foundation

private func escape(string: String) -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue) as String
}

private func unescape(string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string, nil) as String
}

public class URLEncodedSerialization {
    public enum Error: ErrorType {
        case CannotGetStringFromData(NSData, NSStringEncoding)
        case CannotGetDataFromString(String, NSStringEncoding)
        case CannotCastObjectToDictionary(AnyObject)
        case InvalidFormatString(String)
    }

    /// - Throws: URLEncodedSerialization.Error
    public class func objectFromData(data: NSData, encoding: NSStringEncoding) throws -> [String: String] {
        guard let string = NSString(data: data, encoding: encoding) as? String else {
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
    public class func dataFromObject(object: AnyObject, encoding: NSStringEncoding) throws -> NSData {
        guard let dictionary = object as? [String: AnyObject] else {
            throw Error.CannotCastObjectToDictionary(object)
        }

        let string = stringFromDictionary(dictionary)
        guard let data = string.dataUsingEncoding(encoding, allowLossyConversion: false) else {
            throw Error.CannotGetDataFromString(string, encoding)
        }

        return data
    }
    
    public class func stringFromDictionary(dictionary: [String: AnyObject]) -> String {
        let pairs = dictionary.map { key, value -> String in
            let valueAsString = (value as? String) ?? "\(value)"
            return "\(key)=\(escape(valueAsString))"
        }

        return "&".join(pairs)
    }
}
