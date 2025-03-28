//
//  MockModel+Helper.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 18.06.21.
//
// swiftlint:disable type_body_length file_length

import Shared
import Foundation
import HealthKit

enum MockModelFactory {
    static func createPatientsSummaries() -> [PatientSummary] {
        [patientSummaryOne, patientSummaryTwo]
    }

    static var patientSummaryOne: PatientSummary {
        PatientSummary(
            accountId: 1,
            active: true,
            birthday: Date.createDateDayFromComponents(year: 1997, month: 12, day: 27),
            firstName: "Christopher",
            heartRateProfileRunning: PatientHeartRateProfile(
                zone0: 49.0,
                zone1: 86.0,
                zone2: 187.0,
                zone3: 54.0,
                zone4: 117.0
            ),
            heartRateProfileCycling: PatientHeartRateProfile(
                zone0: 49.0,
                zone1: 86.0,
                zone2: 187.0,
                zone3: 54.0,
                zone4: 117.0
            ),
            id: 5,
            lastName: "Schütz",
            lastTraining: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 16, hour: 21, minute: 0, second: 1)
            ) ?? Date(),
            ratings: RatingAmounts(bad: 1, good: 1, medium: 1, unrated: 0),
            studyGroups: ["Marathon Training"],
            trainingProgress: ProgressObject(completed: 3, total: 7),
            treatmentFinished: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 12, day: 31, hour: 0, minute: 0, second: 0)
            ) ?? Date(),
            treatmentStarted: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 1, day: 1, hour: 0, minute: 0, second: 0)
            ) ?? Date(),
            weekProgress: ProgressObject(completed: 0, total: 0),
            totalHours: 29.0,
            email: "c.schuetz@tum.de",
            username: "cdschtz",
            treatmentGoal: "Marathon in sub 4h schaffen",
            trainingZoneIntervals: [
                PatientTrainingIntervalProfile(
                    id: 1337,
                    workoutType: 37,
                    unit: "HEARTRATE",
                    upper0Bound: 80,
                    upper1Bound: 110,
                    upper2Bound: 140,
                    upper3Bound: 170
                )
            ]
        )
    }

    static var patientSummaryTwo: PatientSummary {
        PatientSummary(
            accountId: 2,
            active: true,
            birthday: Date.createDateDayFromComponents(year: 1993, month: 11, day: 30),
            firstName: "Jannis",
            heartRateProfileRunning: PatientHeartRateProfile(
                zone0: 14.0,
                zone1: 45.0,
                zone2: 90.0,
                zone3: 89.0,
                zone4: 150.0
            ),
            heartRateProfileCycling: PatientHeartRateProfile(
                zone0: 49.0,
                zone1: 86.0,
                zone2: 187.0,
                zone3: 54.0,
                zone4: 117.0
            ),
            id: 4,
            lastName: "Mainczyk",
            lastTraining: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 16, hour: 21, minute: 0, second: 1)
            ) ?? Date(),
            ratings: RatingAmounts(bad: 1, good: 1, medium: 1, unrated: 0),
            studyGroups: ["Half-Marathon Training"],
            trainingProgress: ProgressObject(completed: 3, total: 7),
            treatmentFinished: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 12, day: 31, hour: 0, minute: 0, second: 0)
            ) ?? Date(),
            treatmentStarted: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 1, day: 1, hour: 0, minute: 0, second: 0)
            ) ?? Date(),
            weekProgress: ProgressObject(completed: 5, total: 12),
            totalHours: 34.0,
            email: "jannis.mainczyk@tum.de",
            username: "jmm",
            treatmentGoal: "Marathon in sub 4h schaffen",
            trainingZoneIntervals: [
                PatientTrainingIntervalProfile(
                    id: 1337,
                    workoutType: 37,
                    unit: "HEARTRATE",
                    upper0Bound: 80,
                    upper1Bound: 110,
                    upper2Bound: 140,
                    upper3Bound: 170
                )
            ]
        )
    }
    
    static func createPatientsOverviews() -> [WorkoutsOverviewMediator] {
        let workoutsOverviewOne = WorkoutsOverviewMediator(
            name: "Andreas Christoffel",
            studyGroup: "Marathon Training",
            treatmentGoal: "Marathon laufen",
            workouts: [
                MockModelFactory.getFirstWorkout(),
                MockModelFactory.getSecondWorkout(),
                MockModelFactory.getThirdWorkout(),
                MockModelFactory.getCyclingWorkout()
            ],
            steps: MockModelFactory.steps,
            runningOverview: RunningOverview(
                distance: 17829.096784226007,
                duration: 5095.0,
                heartRateTrainingZones: HeartRateZones(
                    total: 557,
                    zone0HeartRate: 49,
                    zone1HeartRate: 86,
                    zone2HeartRate: 187,
                    zone3HeartRate: 54,
                    zone4HeartRate: 117
                ),
                trainingsDone: 3,
                trainingsDue: 4
            ),
            cyclingOverview: CyclingOverview(
                distance: 3214321.096784226007,
                duration: 90345.0,
                heartRateTrainingZones: HeartRateZones(
                    total: 557,
                    zone0HeartRate: 56,
                    zone1HeartRate: 180,
                    zone2HeartRate: 117,
                    zone3HeartRate: 86,
                    zone4HeartRate: 54
                ),
                trainingsDone: 4,
                trainingsDue: 4
            ),
            //Created one planned running workout for today
            plannedWorkouts: [
                PlannedWorkout(
                    id: 1,
                    patientId: 5,
                    type: 37, //37 -> running, 13 -> cycling
                    maxHeartRate: 140,
                    minDistance: 5000,
                    minDuration: 42,
                    plannedDate: Date())
            ]
        )
        
        return [workoutsOverviewOne]
    }

    private static var steps: [GetStepMediator] {
        [
            GetStepMediator(
                amount: 7465,
                date: Foundation.Calendar.current.date(
                    from: DateComponents(year: 2021, month: 6, day: 1)
                ) ?? Date(),
                id: 1,
                patientId: 5
            ),
            GetStepMediator(
                amount: 5342,
                date: Date(),
                id: 2,
                patientId: 5
            ),
            GetStepMediator(
                amount: 5342,
                date: Date().yesterday,
                id: 2,
                patientId: 5
            ),
            GetStepMediator(
                amount: 13750,
                date: Date().advanced(by: -2 * 60 * 60 * 24),  // the day before yesterday
                id: 2,
                patientId: 5
            )
        ]
    }
    
    static func getFirstWorkout() -> WorkoutsOverviewWorkoutMediator {
        WorkoutsOverviewWorkoutMediator(
            workoutId: 84,
            appleUUID: "84A0854B-9D03-4E40-ACDB-9CB8819D5A9E",
            duration: 1451.0,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 1, hour: 21, minute: 0, second: 1)
            ) ?? Date(),
            type: 37,
            mainHeartRateSegment: 2,
            rating: 1,
            comment: "ich fand das training maximal anstrengend, hatte währenddessen auch starke knieschmerzen",
            intensity: 20,
            distance: 4991.255285416973,
            calories: 357
        )
    }
    
    static func getSecondWorkout() -> WorkoutsOverviewWorkoutMediator {
        WorkoutsOverviewWorkoutMediator(
            workoutId: 85,
            appleUUID: "429F5470-D36F-4A9A-85E1-4DDEAA14035F",
            duration: 1928.0,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 1, hour: 17, minute: 8, second: 23)
            ) ?? Date(),
            type: 37,
            mainHeartRateSegment: 2,
            rating: 3,
            comment: "kam mit super leicht vor, werde wohl fitter!!",
            intensity: 10,
            distance: 6433.0966,
            calories: 470
        )
    }
    
    static func getThirdWorkout() -> WorkoutsOverviewWorkoutMediator {
        WorkoutsOverviewWorkoutMediator(
            workoutId: 86,
            appleUUID: "A5C13612-8D1F-4F51-89C1-3720E935D00B",
            duration: 1716.0,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 1, hour: 16, minute: 07, second: 23)
            ) ?? Date(),
            type: 37,
            mainHeartRateSegment: 4,
            rating: 2,
            comment: "war okay...\n",
            intensity: 11,
            distance: 6404.744825452113,
            calories: 466
        )
    }

    static func getCyclingWorkout() -> WorkoutsOverviewWorkoutMediator {
        WorkoutsOverviewWorkoutMediator(
            workoutId: 87,
            appleUUID: "A5C13642-8D1F-4F51-89C1-3720E935D00B",
            duration: 2455.0,
            startTime: Date(),
            type: Int(HKWorkoutActivityType.cycling.rawValue),
            mainHeartRateSegment: 2,
            rating: 2,
            comment: "Gute Tour!",
            intensity: 14,
            distance: 123654.744825452113,
            calories: 1098
        )
    }
    
    static func createPatientDetailedWorkouts() -> [GetWorkoutMediator] {
        let detailedWorkoutOne = MockModelFactory.createDetailedWorkoutOne()
        let detailedWorkoutTwo = MockModelFactory.createDetailedWorkoutTwo()
        let detailedWorkoutThree = MockModelFactory.createDetailedWorkoutThree()
        return [detailedWorkoutOne, detailedWorkoutTwo, detailedWorkoutThree]
    }
    
    static func createDetailedWorkoutOne() -> GetWorkoutMediator {
        GetWorkoutMediator(
            id: 84,
            dayOfWorkout: "16 Juni 2021",
            timeWorkoutWasStarted: "21:00",
            comment: "ich fand das training maximal anstrengend, hatte währenddessen auch starke knieschmerzen",
            distance: 4991.255285416973,
            distanceRounded: 4991,
            duration: 1451.0,
            endTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 16, hour: 21, minute: 28, second: 15)
            ) ?? Date(),
            heartRateAverage: 155.13569321533924,
            heartRateMaximum: 171.0,
            heartRateMinimum: 111.0,
            intensity: 20,
            kcal: 357,
            kilometerPace: MockModelFactory.getDetailedWorkoutKilometerPaceSamples(),
            paceMaximum: 336.8491859802702,
            paceMinimum: 289.7491009881139,
            rating: 1,
            speedAverage: 12.441280961493481,
            speedMaximum: 19.212126952586228,
            speedMinimum: 1.251098657376812,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 16, hour: 21, minute: 0, second: 1)
            ) ?? Date(),
            terrainDown: 0.0,
            terrainUp: 0.0,
            trainingZones: TrainingZones(
                heartRate: TrainingZone(
                    total: 169,
                    zone0: 26,
                    zone1: 25,
                    zone2: 88,
                    zone3: 18,
                    zone4: 0
                ),
                speed: TrainingZone(
                    total: 169,
                    zone0: 17,
                    zone1: 9,
                    zone2: 9,
                    zone3: 78,
                    zone4: 49
                )
            ),
            type: 37,
            combinedProfiles: MockModelFactory.getDetailedWorkoutCombinedProfiles()
        )
    }
    
    static func createDetailedWorkoutTwo() -> GetWorkoutMediator {
        GetWorkoutMediator(
            id: 85,
            dayOfWorkout: "07 Juni 2021",
            timeWorkoutWasStarted: "17:42",
            comment: "kam mit super leicht vor, werde wohl fitter!!",
            distance: 6433.096673356923,
            distanceRounded: 6433,
            duration: 1928.0,
            endTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 7, hour: 17, minute: 42, second: 50)
            ) ?? Date(),
            heartRateAverage: 154.77722772277227,
            heartRateMaximum: 167.0,
            heartRateMinimum: 113.0,
            intensity: 10,
            kcal: 470,
            kilometerPace: MockModelFactory.getDetailedWorkoutKilometerPaceSamples(),
            paceMaximum: 320.5897191451072,
            paceMinimum: 315.259356794468,
            rating: 3,
            speedAverage: 12.066761226369174,
            speedMaximum: 18.001381522175866,
            speedMinimum: 0.2736466963391842,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 7, hour: 17, minute: 08, second: 23)
            ) ?? Date(),
            terrainDown: 0.0,
            terrainUp: 0.0,
            trainingZones: TrainingZones(
                heartRate: TrainingZone(
                    total: 206,
                    zone0: 22,
                    zone1: 58,
                    zone2: 89,
                    zone3: 2,
                    zone4: 0
                ),
                speed: TrainingZone(
                    total: 206,
                    zone0: 13,
                    zone1: 5,
                    zone2: 5,
                    zone3: 127,
                    zone4: 43
                )
            ),
            type: 37,
            combinedProfiles: MockModelFactory.getDetailedWorkoutCombinedProfiles()
        )
    }
    
    static func createDetailedWorkoutThree() -> GetWorkoutMediator {
        GetWorkoutMediator(
            id: 86,
            dayOfWorkout: "01 Juni 2021",
            timeWorkoutWasStarted: "16:37",
            comment: "war okay...",
            distance: 6404.744825452113,
            distanceRounded: 6405,
            duration: 1716.0,
            endTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 1, hour: 16, minute: 37, second: 48)
            ) ?? Date(),
            heartRateAverage: 175.1060171919771,
            heartRateMaximum: 182.0,
            heartRateMinimum: 144.0,
            intensity: 11,
            kcal: 466,
            kilometerPace: MockModelFactory.getDetailedWorkoutKilometerPaceSamples(),
            paceMaximum: 284.78735614353343,
            paceMinimum: 270.66284874443636,
            rating: 2,
            speedAverage: 13.473641498034665,
            speedMaximum: 24.599626035618137,
            speedMinimum: 1.2550174474461269,
            startTime: Foundation.Calendar.current.date(
                from: DateComponents(year: 2021, month: 6, day: 1, hour: 16, minute: 07, second: 23)
            ) ?? Date(),
            terrainDown: 0.0,
            terrainUp: 0.0,
            trainingZones: TrainingZones(
                heartRate: TrainingZone(
                    total: 182,
                    zone0: 1,
                    zone1: 3,
                    zone2: 10,
                    zone3: 34,
                    zone4: 117
                ), speed: TrainingZone(
                    total: 182,
                    zone0: 11,
                    zone1: 3,
                    zone2: 3,
                    zone3: 45,
                    zone4: 119
                )
            ),
            type: 37,
            combinedProfiles: MockModelFactory.getDetailedWorkoutCombinedProfiles()
        )
    }
    
    static func getDetailedWorkoutCombinedProfiles() -> [CombinedProfileSample] {
        var result: [CombinedProfileSample] = []
        var cumulativeDistance: Double = 0.0
        var cumulativeSecondsSinceStart: Double = 0.0
        for _ in 1...200 {
            result.append(CombinedProfileSample(
                altitude: Double.random(in: 400.0..<450.0),
                distance: cumulativeDistance,
                heartRate: Double.random(in: 110.0..<196.0),
                secondsSinceStart: cumulativeSecondsSinceStart,
                speed: Double.random(in: 8.0..<16.0)
            ))
            cumulativeDistance += Double.random(in: 25..<40)
            cumulativeSecondsSinceStart += 10.0
        }
        return result
    }
    
    static func getDetailedWorkoutKilometerPaceSamples() -> [KilometerPaceSample] {
        [
            KilometerPaceSample(
                kilometre: 1,
                minutes: 4,
                seconds: 49.74910098811392,
                avgHeartRate: 152.88095238095235,
                avgSpeed: 12.544818112377921,
                maxHeartRate: 160.0,
                maxSpeed: 13.97493782972451
            ),
            KilometerPaceSample(
                kilometre: 2,
                minutes: 5,
                seconds: 5.669028814288481,
                avgHeartRate: 156.66161616161617,
                avgSpeed: 12.064018301741497,
                maxHeartRate: 163.0,
                maxSpeed: 16.509225272889132
            ),
            KilometerPaceSample(
                kilometre: 3,
                minutes: 5,
                seconds: 5.784952777984984,
                avgHeartRate: 160.70114942528735,
                avgSpeed: 11.930880835152879,
                maxHeartRate: 164.0,
                maxSpeed: 13.574398769506375
            ),
            KilometerPaceSample(
                kilometre: 4,
                minutes: 5,
                seconds: 13.61026065754919,
                avgHeartRate: 155.30208333333334,
                avgSpeed: 12.038392424057687,
                maxHeartRate: 166.5,
                maxSpeed: 14.725356393362631
            ),
            KilometerPaceSample(
                kilometre: 5,
                minutes: 5,
                seconds: 5.741984368289081,
                avgHeartRate: 166.6851851851852,
                avgSpeed: 13.12929507564703,
                maxHeartRate: 170.5,
                maxSpeed: 16.31566336571988
            ),
            KilometerPaceSample(
                kilometre: 6,
                minutes: 5,
                seconds: 36.84918598027019,
                avgHeartRate: 124.83333333333333,
                avgSpeed: 8.075850631641087,
                maxHeartRate: 157.0,
                maxSpeed: 10.318138168451611
            )
        ]
    }
}

extension Date {
    static func createDateDayFromComponents(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        return Foundation.Calendar.current.date(from: components) ?? Date()
    }
}
