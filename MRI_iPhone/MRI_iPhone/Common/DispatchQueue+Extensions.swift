//
//  DispatchQueue+Extensions.swift
//  tumsm
//
//  Created by Christopher Schütz on 30.06.21.
//

import Foundation

// https://stackoverflow.com/a/40997652/10567115
/// Run tasks in background to not block app behavior
extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
