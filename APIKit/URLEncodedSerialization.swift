import Foundation

private func escape(string: String) -> String {
    // Reserved characters defined by RFC 3986
    // Reference: https://www.ietf.org/rfc/rfc3986.txt
    let generalDelimiters = ":/?#[]@"
    let subDelimiters = "!$&'()*+,;="
    let reservedCharacters = generalDelimiters + subDelimiters
    
    let allowedCharacterSet = NSMutableCharacterSet()
    allowedCharacterSet.formUnionWithCharacterSet(NSCharacterSet.URLQueryAllowedCharacterSet())
    allowedCharacterSet.removeCharactersInString(reservedCharacters)
    
    return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
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
            if value is NSNull {
                return "\(escape(key))"
            }
            
            let valueAsString = (value as? String) ?? "\(value)"
            return "\(escape(key))=\(escape(valueAsString))"
        }

        return pairs.joinWithSeparator("&")
    }
}
