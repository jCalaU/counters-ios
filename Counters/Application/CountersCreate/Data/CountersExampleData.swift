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
        let fileName = returnFileName(),
        let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
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
    static func returnFileName() -> String? {
        let languageSupported = ["en", "es", "fr", "pt", "sv"]
        let language:String = Locale.preferredLanguages[0] as String
        let languageES  = (language as NSString).substring(to: 2)
        let lang = languageSupported.contains(languageES) ? languageES : "en"
        let fileName = "tagsExample_" + lang
        return fileName
    }
}
