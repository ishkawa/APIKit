import Foundation

private func escape(_ string: String) -> String {
    // Reserved characters defined by RFC 3986
    // Reference: https://www.ietf.org/rfc/rfc3986.txt
    let generalDelimiters = ":#[]@"
    let subDelimiters = "!$&'()*+,;="
    let reservedCharacters = generalDelimiters + subDelimiters

    var allowedCharacterSet = CharacterSet()
    allowedCharacterSet.formUnion(.urlQueryAllowed)
    allowedCharacterSet.remove(charactersIn: reservedCharacters)

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
        let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
        let range = startIndex..<endIndex

        let substring = string.substring(with: range)

        escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring

        index = endIndex
    }

    return escaped
}

private func unescape(_ string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string as CFString, nil) as String
}

/// `URLEncodedSerialization` parses `Data` and `String` as urlencoded,
/// and returns dictionary that represents the data or the string.
public final class URLEncodedSerialization {
    public enum Error: Swift.Error {
        case cannotGetStringFromData(Data, String.Encoding)
        case cannotGetDataFromString(String, String.Encoding)
        case cannotCastObjectToDictionary(Any)
        case invalidFormatString(String)
    }

    /// Returns `[String: String]` that represents urlencoded `Data`.
    /// - Throws: URLEncodedSerialization.Error
    public static func object(from data: Data, encoding: String.Encoding) throws -> [String: String] {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.cannotGetStringFromData(data, encoding)
        }

        var dictionary = [String: String]()
        for pair in string.components(separatedBy: "&") {
            let contents = pair.components(separatedBy: "=")

            guard contents.count == 2 else {
                throw Error.invalidFormatString(string)
            }

            dictionary[contents[0]] = unescape(contents[1])
        }

        return dictionary
    }

    /// Returns urlencoded `Data` from the object.
    /// - Throws: URLEncodedSerialization.Error
    public static func data(from object: Any, encoding: String.Encoding) throws -> Data {
        guard let dictionary = object as? [String: Any] else {
            throw Error.cannotCastObjectToDictionary(object)
        }

        let string = self.string(from: dictionary)
        guard let data = string.data(using: encoding, allowLossyConversion: false) else {
            throw Error.cannotGetDataFromString(string, encoding)
        }

        return data
    }

    /// Returns urlencoded `Data` from the string.
    public static func string(from dictionary: [String: Any]) -> String {
        let pairs = dictionary.map { key, value -> String in
            if value is NSNull {
                return "\(escape(key))"
            }

            let valueAsString = (value as? String) ?? "\(value)"
            return "\(escape(key))=\(escape(valueAsString))"
        }

        return pairs.joined(separator: "&")
    }
}
