//
//  StudyGroupService.swift
//  
//
//  Created by Christopher Schütz on 04.07.21.
//

import Combine
import Foundation

// MARK: StudyGroupService
/// Service class for sending requests to studyGroup endpoints
public class StudyGroupService: BaseService {
    /// initialize StudyGroupService with `/studyGroup` prefix
    override public init() {
        super.init()
        self.prefixPath = "/studyGroup"
    }
    
    // MARK: GET /studyGroup/overviews
    /// publishes a GET request for StudyGroup array
    public func getStudyGroups() -> AnyPublisher<[StudyGroup], ServiceError> {
        RestfulManager.getElements(
            on: self.baseUrl + "/overviews",
            query: nil
        )
    }
    
    // MARK: POST /studyGroup
    /// publishes a POST request with a postStudyGroupMediator payload in the body
    /// - Parameters
    ///     - postRating: PostStudyGroupMediator to be sent in the body
    public func postStudyGroup(
        _ postStudyGroup: PostStudyGroupMediator
    ) -> AnyPublisher<PostStudyGroupResponse, ServiceError> {
        RestfulManager.postElement(
            postStudyGroup,
            on: self.baseUrl
        )
    }
    
    // MARK: POST /studyGroup/Trainer
    /// publishes a POST request with a postStudyGroupTrainerMediator payload in the body
    /// - Parameters
    ///     - postRating: PostStudyGroupTrainerMediator to be sent in the body
    public func postStudyGroupTrainer(
        _ postStudyGroupTrainer: PostStudyGroupTrainerMediator
    ) -> AnyPublisher<PostStudyGroupTrainerResponse, ServiceError> {
        RestfulManager.postElement(
            postStudyGroupTrainer,
            on: self.baseUrl + "/trainer"
        )
    }
    
    // MARK: POST /studyGroup/member
    /// publishes a POST request with a postStudyGroupMemberMediator payload in the body
    /// - Parameters
    ///     - postRating: PostStudyGroupMemberMediator to be sent in the body
    public func postStudyGroupMember(
        _ postStudyGroupMember: PostStudyGroupMemberMediator
    ) -> AnyPublisher<PostStudyGroupMemberResponse, ServiceError> {
        RestfulManager.postElement(
            postStudyGroupMember,
            on: self.baseUrl + "/member"
        )
    }
    
    public func deleteStudyGroup(id: Int) -> AnyPublisher<PostStudyGroupResponse, ServiceError> {
        RestfulManager.deleteElement(on: self.baseUrl, query: "id=\(id)")
    }
}
