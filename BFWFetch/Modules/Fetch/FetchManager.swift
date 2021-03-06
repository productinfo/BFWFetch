//
//  FetchManager.swift
//
//  Created by Tom Brodhurst-Hill on 15/9/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public struct FetchManager {
    
    public static let shared = FetchManager()
    
    public func fetchData(
        from request: URLRequest,
        completion: @escaping ((Result<Data>) -> Void)
        )
    {
        debugPrint("fetch(from: \(request.url!.absoluteString))")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let result: Result<Data>
            if let error = error {
                debugPrint("response = \(String(describing: response))")
                result = .failure(error: error)
            } else {
                result = .success(value: data!)
            }
            completion(result)
        }
        .resume()
    }
    
    public func fetch<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Result<T>) -> Void)
        )
    {
        fetchData(from: request) { dataResult in
            let result: Result<T>
            switch dataResult {
            case .success(let data):
                do {
                    let decoder = decoder ?? JSONDecoder()
                    let decoded = try decoder.decode(type, from: data)
                    result = .success(value: decoded)
                } catch {
                    let string = String(data: data, encoding: .utf8)
                    // If the JSON just contains null, treat it as an empty array.
                    // TODO: More robust parsing of null using single value json decoder.
                    if string?.trimmingCharacters(in: .whitespacesAndNewlines) == "null",
                        let array = [] as? T
                    {
                        result = .success(value: array)
                    } else {
                        result = .failure(error: error)
                    }
                }
            case .failure(let error):
                result = .failure(error: error)
            }
            completion(result)
        }
    }
    
    public func fetch<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        decoder: JSONDecoder? = nil,
        completion: @escaping ((Result<T>) -> Void)
        )
    {
        fetch(type, from: URLRequest(url: url), completion: completion)
    }
    
}
