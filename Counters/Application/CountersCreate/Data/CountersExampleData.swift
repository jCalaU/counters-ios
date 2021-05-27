//
//  CountersExampleData.swift
//  Counters
//
//  Created by Javier Cala Uribe on 27/5/21.
//

struct TagsExampleJSON: Codable {
    let title_section: String
    let tags: [String]
}

extension TagsExampleJSON {
  static func tagsExampleJSON() -> [TagsExampleJSON] {
    guard
      let url = Bundle.main.url(forResource: "tagsExample", withExtension: "json"),
      let data = try? Data(contentsOf: url)
      else {
        return []
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([TagsExampleJSON].self, from: data)
    } catch {
      return []
    }
  }
}
