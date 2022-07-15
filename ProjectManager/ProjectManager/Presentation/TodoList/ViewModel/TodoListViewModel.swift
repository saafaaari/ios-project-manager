//
//  TodoListViewModel.swift
//  ProjectManager
//
//  Created by 이시원 on 2022/07/07.
//

import Foundation
import RxSwift
import RxCocoa

struct TodoListViewModelActions {
    let presentEditViewController: (_ item: TodoModel?) -> Void
    let popoverMoveViewController: (_ cell: TodoListCell?, _ item: TodoModel) -> Void
}

protocol TodoListViewModelInput {
    func plusButtonDidTap()
    func cellSelected(id: UUID)
    func cellLongPress(cell: TodoListCell?, id: UUID)
}

protocol TodoListViewModelOutput {
    var todoList: Observable<[TodoCellContent]> { get }
    var doingList: Observable<[TodoCellContent]> { get }
    var doneList: Observable<[TodoCellContent]> { get }
    var todoListCount: Driver<String> { get }
    var doingListCount: Driver<String> { get }
    var doneListCount: Driver<String> { get }
}

protocol TodoListViewModel: TodoListViewModelInput, TodoListViewModelOutput {}

final class DefaultTodoListViewModel: TodoListViewModel {
    private let useCase: TodoListUseCase
    private let actions: TodoListViewModelActions?
    private let todoLists: BehaviorSubject<[TodoModel]>
    
    //MARK: - Output
    var todoList: Observable<[TodoCellContent]> {
        todoLists.map { items in
            items.filter { $0.state == .todo }
        }
        .distinctUntilChanged()
        .withUnretained(self)
        .map { (self, items) in
            self.toTodoCellContents(todoModels: items)
        }
    }

    var doingList: Observable<[TodoCellContent]> {
        todoLists.map { items in
            items.filter { $0.state == .doing }
        }
        .distinctUntilChanged()
        .withUnretained(self)
        .map { (self, items) in
            self.toTodoCellContents(todoModels: items)
        }
    }
    
    var doneList: Observable<[TodoCellContent]> {
        todoLists.map { items in
            items.filter { $0.state == .done }
        }
        .distinctUntilChanged()
        .withUnretained(self)
        .map { (self, items) in
            self.toTodoCellContents(todoModels: items)
        }
    }
    
    var todoListCount: Driver<String> {
        todoList
            .map { "\($0.count)" }
            .asDriver(onErrorJustReturn: "0")
    }
    var doingListCount: Driver<String> {
        doingList
            .map { "\($0.count)" }
            .asDriver(onErrorJustReturn: "0")
    }
    var doneListCount: Driver<String> {
        doneList
            .map { "\($0.count)" }
            .asDriver(onErrorJustReturn: "0")
    }
    
    //MARK: - Input
    func plusButtonDidTap() {
        actions?.presentEditViewController(nil)
    }
    
    func cellSelected(id: UUID) {
        let item = try? todoLists.value()
            .first { $0.id == id }
        actions?.presentEditViewController(item)
        
    }
    
    init(useCase: TodoListUseCase, actions: TodoListViewModelActions) {
    func cellLongPress(cell: TodoListCell?, id: UUID) {
        if let item = try? todoLists.value()
            .first(where: { $0.id == id }) {
                actions?.popoverMoveViewController(cell, item)
            }
    }
        self.useCase = useCase
        self.actions = actions
        
        todoLists = useCase.readItems()
    }
    
    private func toTodoCellContents(todoModels: [TodoModel]) -> [TodoCellContent] {
        todoModels.map { item in
            TodoCellContent(entity: item, isPast: useCase.checkDeadline(time: item.deadlineAt))
        }
    }
}

struct TodoCellContent {
    let title: String?
    let body: String?
    let deadlineAt: String
    let id: UUID
    let isPast: Bool
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. d"
        return dateFormatter
    }()
    
    init(entity: TodoModel, isPast: Bool) {
        self.title = entity.title
        self.body = entity.body
        self.deadlineAt = entity.deadlineAt.toString(dateFormatter)
        self.id = entity.id
        self.isPast = isPast
    }
}
