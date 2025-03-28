//
//  PatientService.swift
//  
//
//  Created by Christopher Schütz on 16.06.21.
//

import Combine
import Foundation


// MARK: PatientService
/// Service class for sending requests to patient endpoints
public class PatientService: BaseService {
    /// initialize PatientService with `/patient` prefix
    override public init() {
        super.init()
        self.prefixPath = "/patient"
    }
    
    // MARK: GET /patient/overviews
    /// publishes a GET request for the summaries of patients
    public func getSummariesOfPatients(
        start startDate: Date? = nil,
        end endDate: Date? = nil
    ) -> AnyPublisher<[PatientSummary], ServiceError> {
        var query: String?
        
        if let startDate = startDate, let endDate = endDate {
            query = self.getFromDateToDateQuery(from: startDate, to: endDate)
        }
        
        return RestfulManager.getElements(
            on: self.baseUrl + "/overviews",
            query: query
        )
    }
    
    // MARK: GET /patient/export
    /// publishes a GET request for PatientExport data
    public func getPatientsExport(
        from fromDate: Date? = nil,
        to toDate: Date? = nil,
        ids patientIds: [Int]
    ) -> AnyPublisher<[PatientExport], ServiceError> {
        var query: String = patientIds.map { String("patientIds=\($0)") }.joined(separator: "&")
        
        if let fromDate = fromDate, let toDate = toDate {
            query += self.getFromDateToDateQuery(from: fromDate, to: toDate)
        }
        
        return RestfulManager.getElements(
            on: self.baseUrl + "/export",
            query: query
        )
    }
    
    // MARK: GET /patient
    /// publishes a GET request for data of a single patient
    /// - Parameters
    ///     - identifier: id of the requested patient
    public func getPatient(identifier: Int?) -> AnyPublisher<GetPatientMediator, ServiceError> {
        var query: String?
        if let identifier = identifier {
            query = "id=\(identifier)"
        }
        return RestfulManager.getElement(
            on: self.baseUrl,
            query: query
        )
    }
    
    public func getTrainingZones(identifier: Int) -> AnyPublisher<GetTrainingZonesMediator, ServiceError> {
        let query = "patientId=\(identifier)"
        return RestfulManager.getElement(
            on: self.baseUrl + "/trainingZones",
            query: query
        )
    }
    
    // MARK: POST /patient
    /// publishes a POST request with a postPatientMediator payload in the body
    /// - Parameters
    ///     - postRating: PostPatientMediator to be sent in the body
    public func postPatient(
        _ postPatient: PostPatientMediator
    ) -> AnyPublisher<PostPatientResponse, ServiceError> {
        RestfulManager.postElement(
            postPatient,
            on: self.baseUrl
        )
    }
    
    // MARK: POST /patient/trainingZones
    /// publishes a POST request with a postTrainingZonesMediator payload in the body
    /// - Parameters
    ///     - postRating: PostTrainingZonesMediator to be sent in the body
    public func postTrainingZones(
        _ postTrainingZones: PostTrainingZonesMediator
    ) -> AnyPublisher<PostTrainingZonesResponse, ServiceError> {
        RestfulManager.postElement(
            postTrainingZones,
            on: self.baseUrl + "/trainingZones"
        )
    }
    
    // MARK: DELETE /patient
    /// publishes a delete request for a single patient
    /// - Parameters
    ///     - identifier: id of the requested patient
    public func deletePatient(id: Int) -> AnyPublisher<PostPatientResponse, ServiceError> {
        RestfulManager.deleteElement(on: self.baseUrl, query: "id=\(id)")
    }
    
    // MARK: DELETE /patient/trainingZones
    /// publishes a delete request for a single training zones
    /// - Parameters
    ///     - identifier: id of the requested training zones
    public func deleteTrainingZones(id: Int) -> AnyPublisher<DeleteTrainingZonesResponse, ServiceError> {
        RestfulManager.deleteElement(on: self.baseUrl + "/trainingZones", query: "id=\(id)")
    }
    
    // MARK: PATCH /patient
    /// publishes a PATCH request with a patchPatientMediator payload in the body
    /// - Parameters
    ///     - postPatient: PostPatientMediator to be sent in the body
    public func patchPatient(
        _ patchPatient: PatchPatientMediator
    ) -> AnyPublisher<PostPatientResponse, ServiceError> {
        RestfulManager.patchElement(
            patchPatient,
            on: self.baseUrl
        )
    }
}

extension PatientService {
    /// builds String with fromDate and toDate query parameters in specified format by the api
    private func getFromDateToDateQuery(from fromDate: Date, to toDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return """
        fromDate=\(dateFormatter.string(from: fromDate))\
        &toDate=\(dateFormatter.string(from: toDate))
        """
    }
}
