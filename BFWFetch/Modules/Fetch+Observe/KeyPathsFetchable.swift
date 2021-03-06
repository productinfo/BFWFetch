//
//  KeyPathsFetchable.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 29/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//

import Foundation

public protocol KeyPathsFetchable: Observable {
    
    func request<T>(for keyPath: KeyPath<Self, T>) throws -> URLRequest
    func decoder<T>(for keyPath: KeyPath<Self, T>) -> JSONDecoder?
    
}

public extension KeyPathsFetchable {
    
    func request<T>(for keyPath: KeyPath<Self, T>) throws -> URLRequest {
        throw Fetch.Error.missingRequest
    }
    
    /// Implement to provide a specific JSONDecoder for all or some keypaths. e.g. With decoder.dateDecodingStrategy = .iso8601
    func decoder<T>(for keyPath: KeyPath<Self, T>) -> JSONDecoder? {
        return nil
    }
    
    func fetch<T: Decodable>(
        keyPath: ReferenceWritableKeyPath<Self, T>,
        from request: URLRequest? = nil
        ) throws
    {
        let request = try request ?? self.request(for: keyPath)
        let decoder = self.decoder(for: keyPath)
        post(keyPath: keyPath, event: .inProgress)
        FetchManager.shared.fetch(T.self, from: request, decoder: decoder) { result in
            switch result {
            case .success(let value):
                self[keyPath : keyPath] = value
            case .failure(let error):
                debugPrint("fetch error = \(error)")
                // The post below takes care of notifying observers of the failure.
            }
            self.post(keyPath: keyPath, event: result.event)
        }
    }
    
}
