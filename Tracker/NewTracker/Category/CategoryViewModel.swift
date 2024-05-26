//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by Anna on 20.05.2024.
//

import Foundation

final class CategoryViewModel {
    typealias Binding<T> = (T) -> Void
    
    private let trackerCategoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoryBinding?(categories)
        }
    }
    
    var categoryBinding: Binding<[TrackerCategory]>?
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    func fetchCategories() {
        do {
            let fetchedCategories = try trackerCategoryStore.fetchCategories()
            print("Fetched categories: \(fetchedCategories.map { $0.title ?? "nil" })")
            categories = fetchedCategories.compactMap { trackerCategoryStore.updateTrackerCategory($0) }
            print("Categories after update: \(categories.map { $0.title })")
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func bindCategories(_ binding: @escaping Binding<[TrackerCategory]>) {
            self.categoryBinding = binding
        }
    
    func addCategory(_ category: TrackerCategory) {
        do {
            try trackerCategoryStore.addNewCategory(category)
            fetchCategories()
        } catch {
            print("Error adding category: \(error)")
        }
    }
    
    func deleteCategory(at index: Int) {
        let categoryToDelete = categories[index]
        do {
            guard let categoryCoreData = trackerCategoryStore.category(with: categoryToDelete.title) else { return }
            try trackerCategoryStore.deleteCategory(categoryCoreData)
            fetchCategories()
        } catch {
            print("Error deleting category: \(error)")
        }
    }
}
