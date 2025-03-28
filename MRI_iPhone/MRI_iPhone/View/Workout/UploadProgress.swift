//
//  UploadProgress.swift
//  tumsm
//
//  Created by Christopher Schütz on 28.06.21.
//

import SwiftUI
import Foundation

struct UploadProgress: View {
    @Binding var total: Int
    @Binding var uploaded: Int
    @Binding var failed: Int
    @Binding var uploadState: LoadingState
    
    var progress: Double {
        Double(uploaded + failed) / Double(total)
    }
    
    var missingWorkouts: Int {
        total - uploaded - failed
    }

    var body: some View {
        if uploadState != .loading {
            EmptyView()
        } else {
            VStack {
                ProgressView(value: progress)
            }
            .padding([.leading, .trailing], 30)
            .padding([.top], 15)
        }
    }
}

struct WorkoutsUploadProgress_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // progress: 0.94
            UploadProgress(
                total: .constant(50),
                uploaded: .constant(37),
                failed: .constant(10),
                uploadState: .constant(.loading)
            )
            .previewLayout(.fixed(width: 500, height: 100))
            
            // progress: 0.00
            UploadProgress(
                total: .constant(50),
                uploaded: .constant(0),
                failed: .constant(0),
                uploadState: .constant(.loading)
            )
            .previewLayout(.fixed(width: 500, height: 100))
            
            // progress: 1.00
            UploadProgress(
                total: .constant(50),
                uploaded: .constant(40),
                failed: .constant(10),
                uploadState: .constant(.success)
            )
            .previewLayout(.fixed(width: 500, height: 100))
        }
    }
}
