//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public struct ScheduleFilterViewModel {

  private enum Constants {
    static let topicsTitle =
      NSLocalizedString("Topics",
                        comment: "Title of schedule filter header item for topics.")
    static let levelsTitle =
      NSLocalizedString("Levels",
                        comment: "Title of schedule filter header item for levels.")
    static let typesTitle =
      NSLocalizedString("Event Types",
                        comment: "Title of schedule filter header item for event types.")
    static let tagKey = "tag"
    static let levelKey = "level"
    static let typeKey = "type"
  }

  var filterSections = [ScheduleFilterSectionViewModel]()
  var filterSectionsByType = [String: ScheduleFilterSectionViewModel]()

  var filterString: String? {
    // Build a string to display the selected filters.
    var filters = [String]()
    filters.append(contentsOf: selectedTags)
    filters.append(contentsOf: selectedTypes)
    filters.append(contentsOf: selectedLevels)
    return filters.count > 0 ? filters.joined(separator: ", ") : nil
  }

  var selectedTags: [String] {
    guard let tagsSection = filterSectionsByType[Constants.tagKey] else { return [] }
    let selectedTags = tagsSection.items.filter { tag -> Bool in
      return tag.selected
    }
    return selectedTags.map { tag in return tag.name }
  }

  var selectedTypes: [String] {
    guard let tagsSection = filterSectionsByType[Constants.typeKey] else { return [] }
    let selectedTags = tagsSection.items.filter { tag -> Bool in
      return tag.selected
    }
    return selectedTags.map { tag in return tag.name }
  }

  var selectedLevels: [String] {
    guard let tagsSection = filterSectionsByType[Constants.levelKey] else { return [] }
    let selectedTags = tagsSection.items.filter { tag -> Bool in
      return tag.selected
    }
    return selectedTags.map { tag in return tag.name }
  }

  init() {
    // Types section.
    let typeTags = EventTag.allTypes
    let typeItems: [ScheduleFilterItemViewModel] = typeTags.map { typeTag in
      return ScheduleFilterItemViewModel(name: typeTag.name,
                                         color: typeTag.colorString,
                                         orderInCategory: typeTag.orderInCategory)
      }.sorted(by: { (type1, type2) -> Bool in
        return type1.orderInCategory ?? 0 < type2.orderInCategory ?? 0
      })

    let typesFilterSection = ScheduleFilterSectionViewModel(name: Constants.typesTitle,
                                                            items: typeItems)
    filterSectionsByType[Constants.typeKey] = typesFilterSection
    filterSections.append(typesFilterSection)

    // Levels section.
    let levelTags = EventTag.allLevels
    let levelItems: [ScheduleFilterItemViewModel] = levelTags.map { levelTag in
      return ScheduleFilterItemViewModel(name: levelTag.name,
                                         color: levelTag.colorString,
                                         orderInCategory: levelTag.orderInCategory)
      }.sorted(by: { (level1, level2) -> Bool in
        return level1.orderInCategory ?? 0 < level2.orderInCategory ?? 0
      })

    let levelsFilterSection = ScheduleFilterSectionViewModel(name: Constants.levelsTitle, items: levelItems)
    filterSectionsByType[Constants.levelKey] = levelsFilterSection
    filterSections.append(levelsFilterSection)

    // Topics section.
    let trackTags = EventTag.allTopics
    let topicItems: [ScheduleFilterItemViewModel] = trackTags.map { trackTag in
      return ScheduleFilterItemViewModel(name: trackTag.name, color: trackTag.colorString)
    }.sorted(by: { (topic1, topic2) -> Bool in
      return topic1.name < topic2.name
    })

    let tagsFilterSection = ScheduleFilterSectionViewModel(name: Constants.topicsTitle, items: topicItems)
    filterSectionsByType[Constants.tagKey] = tagsFilterSection
    filterSections.append(tagsFilterSection)
  }

  func shouldShow(topics: [EventTag],
                  levels: [EventTag],
                  types: [EventTag]) -> Bool {
    // If we passed the live stream/session filters, each section is an AND if any items are selected.
    // Within a section the items match with OR.
    let topicsMatch = tagsMatch(selectedTags: selectedTags,
                                eventTags: topics.map { tag in return tag.name })
    let levelsMatch = tagsMatch(selectedTags: selectedLevels,
                                eventTags: levels.map { tag in return tag.name })
    let typesMatch = tagsMatch(selectedTags: selectedTypes,
                               eventTags: types.map { tag in return tag.name })
    return topicsMatch && levelsMatch && typesMatch
  }

  func tagsMatch(selectedTags: [String], eventTags: [String]) -> Bool {
    if selectedTags.isEmpty {
      return true
    }
    return eventTags.reduce(false, {(sum, tag) in
      return sum || selectedTags.contains(tag)
    })
  }

  func reset() {
    for section in filterSections {
      for item in section.items {
        item.selected = false
      }
    }
  }

  var isEmpty: Bool {
    for section in filterSections {
      for item in section.items where item.selected {
          return false
      }
    }
    return true
  }
}

class ScheduleFilterSectionViewModel {
  let name: String?
  let items: [ScheduleFilterItemViewModel]

  init(name: String?, items: [ScheduleFilterItemViewModel]) {
    self.name = name
    self.items = items
  }
}

class ScheduleFilterItemViewModel {
  let name: String
  var selected: Bool
  var color: String?
  var orderInCategory: Int?

  init(name: String, color: String?, orderInCategory: Int? = nil) {
    self.name = name
    self.color = color
    self.orderInCategory = orderInCategory
    selected = false
  }
}
