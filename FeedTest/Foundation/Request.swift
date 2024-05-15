//
//  Request.swift
//  FeedTest
//
//  Created by Yehor Sobko on 15/05/24.
//

import HTTPTypes

protocol Request {
    associatedtype Response: Codable
    
    var method: HTTPRequest.Method { get }
    var path: String { get }
}
