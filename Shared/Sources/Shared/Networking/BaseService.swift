//
//  BaseService.swift
//  
//
//  Created by Christopher Schütz on 04.07.21.
//

import Foundation

/// Parent class of all service classes.
public class BaseService {
    /// base url for all requests on specific service class
    internal var baseUrl: String {
        RestfulManager.baseURL + self.prefixPath
    }
    
    internal var prefixPath: String
    
    /// initialize BaseService with `/` prefix
    public init() {
        self.prefixPath = "/"
    }
}
