//
//  RestfulManager.swift
//  
//
//  Created by Christopher Schütz on 04.07.21.
//

import Combine
import Foundation

/// Manager class for communication with the tumsm server
public enum RestfulManager {
    /// access token received on successful login
    public static var accessToken = ""
    
    /// remote base url for api
    public static var baseURL = "https://ios21tumsm.ase.in.tum.de/api/v1"
    // INFO: For local testing insert server ip here
    /// local base url for api
    //public static var baseURL = "http://127.0.0.1:5000/api/v1"
    
    /// Creates a `URLRequest` based on the parameters that has the `Content-Type` header field set to `application/json`
    /// - Parameters:
    ///   - method: The HTTP method
    ///   - url: The `URL` of the `URLRequest`
    ///   - authorization: Whether the request should be authorized with an access token or not
    ///   - body: The HTTP body that should be added to the `URLRequest`
    /// - Returns: The created `URLRequest`
    static func buildURLRequest(
        _ method: String,
        url: String,
        authorization: Bool = true,
        body: Data? = nil,
        query: String? = nil
    ) -> URLRequest {
        guard var urlComponents = URLComponents(string: url) else {
            fatalError("Could not build URL Components")
        }
        urlComponents.query = query
        guard let url = urlComponents.url else {
            fatalError("Could not extract url")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        if authorization {
            urlRequest.addValue("Bearer \(RestfulManager.accessToken)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = body
        return urlRequest
    }
    
    /// Returns a JSONDecoder with a date decoding strategy that responds to the server date format
    private static func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMMM yyyy HH:mm:ss zzz"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }

    /// Returns a JSOND with a date decoding strategy that responds to the server date format
    static func getEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }
    
    /// Publishes URLRequest's parsed response and handles errors along the way
    static func executeRequest<T: Decodable>(url: URLRequest) -> AnyPublisher<T, ServiceError> {
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response in
                print(String(data: data, encoding: .utf8) ?? "")
                print(response)
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: getDecoder())
            .mapError { error in
                print("Error: \(String(describing: error))")
                print(error.localizedDescription)
                return handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private static func httpError(_ statusCode: Int) -> ServiceError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    internal static func handleError(_ error: Error) -> ServiceError {
        switch error {
        case is Swift.DecodingError:
            print("Error" + error.localizedDescription)
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as ServiceError:
            return error
        default:
            return .unknownError
        }
    }
}
