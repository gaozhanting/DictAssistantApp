//
//  Azure.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/5.
//

import Foundation

// Notice: Azure traslator API has limited access for every free account!

// azure dict cache
public var azureDictionary: [String: String] = [:]

public func translateFromAzure(_ word: String) {
    if azureDictionary[word] == nil {
        translate(word) { translation in
            DispatchQueue.main.async {
                azureDictionary[word] = translation
            }
        }
    }
}

let jsonEncoder = JSONEncoder()
let subscriptionKey = "6fc16e1d9f614f7baed5115f282acd29";
let location = "global"
let apiURL = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en&to=zh"
let jsonDecoder = JSONDecoder()

struct EncodeText: Codable {
    var text = String()
}

//*****TRANSLATION RETURNED DATA*****
struct ReturnedJson: Codable {
    var translations: [TranslatedStrings]
}
struct TranslatedStrings: Codable {
    var text: String
    var to: String
}

let config = URLSessionConfiguration.default
let session =  URLSession(configuration: config)

func translate(_ word: String, completionHandler: @escaping (_ translation: String) -> Void) {
    let url = URL(string: apiURL)!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
    request.addValue(location, forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    var encodeTextSingle = EncodeText()
    encodeTextSingle.text = word
    var toTranslate = [EncodeText]()
    toTranslate.append(encodeTextSingle)
    let jsonToTranslate = try? jsonEncoder.encode(toTranslate)
    
    request.httpBody = jsonToTranslate

    let task = session.dataTask(with: request, completionHandler: { responseData, response, responseError in
        if responseError != nil {
            print("this is the error ", responseError!)
        }
        if let data = responseData {
            let langTranslations = try? jsonDecoder.decode(Array<ReturnedJson>.self, from: data)
            let numberOfTranslations = langTranslations!.count - 1
            let translation = langTranslations![0].translations[numberOfTranslations].text
            completionHandler(translation)
        }
    })
    task.resume()
}
