//
//  MedicineAppEntity.swift
//  PillWave
//
//  Created by Foundation 34 on 11/03/26.
//

import AppIntents

struct MedicineAppEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Medicine"
    static var defaultQuery = MedicineQuery()
    
    var id: UUID
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct MedicineQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [MedicineAppEntity] {
        // fetch from UserDefaults bridge
        let names = UserDefaults.standard.stringArray(forKey: "siriMedicineNames") ?? []
        return names.map { MedicineAppEntity(id: UUID(), name: $0) }
    }
    
    func suggestedEntities() async throws -> [MedicineAppEntity] {
        let names = UserDefaults.standard.stringArray(forKey: "siriMedicineNames") ?? []
        return names.map { MedicineAppEntity(id: UUID(), name: $0) }
    }
}
