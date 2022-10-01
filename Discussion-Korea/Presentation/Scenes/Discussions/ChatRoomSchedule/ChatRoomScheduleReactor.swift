//
//  ChatRoomScheduleReactor.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/05/06.
//

import ReactorKit

final class ChatRoomScheduleReactor: Reactor {

    enum Action {
        case viewWillAppear
        case exitTrigger
        case addDiscussionTrigger
    }

    enum Mutation {
        case setEnable(Bool)
        case initalizeSchedules
        case addSchedules(ScheduleItemViewModel)
        case events
    }

    struct State {
        var addEnabled: Bool = false
        var schedules: [ScheduleItemViewModel] = []
    }

    // MARK: - properties

    private let userID: String
    private let chatRoom: ChatRoom

    private let usecase: DiscussionUsecase
    private let navigator: ChatRoomScheduleNavigator

    let initialState: State

    // MARK: - init/deinit

    init(userID: String,
         chatRoom: ChatRoom,
         usecase: DiscussionUsecase,
         navigator: ChatRoomScheduleNavigator) {
        self.userID = userID
        self.chatRoom = chatRoom
        self.usecase = usecase
        self.navigator = navigator
        self.initialState = State()
    }

    deinit {
        print("🗑", self)
    }

    // MARK: - methods

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat(
                Observable.just(Mutation.initalizeSchedules),
                Observable.just(Mutation.setEnable(self.userID == self.chatRoom.adminUID)),
                self.usecase.discussions(roomUID: self.chatRoom.uid)
                    .map { Mutation.addSchedules(ScheduleItemViewModel(with: $0)) }
            )
        case .exitTrigger:
            return Observable.just(())
                .do(onNext: self.navigator.toChatRoom)
                .map { Mutation.events }
        case .addDiscussionTrigger:
            return Observable.just(self.chatRoom)
                .do(onNext: self.navigator.toAddDiscussion)
                .map { _ in Mutation.events }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setEnable(isEnabled):
            state.addEnabled = isEnabled
        case .initalizeSchedules:
            state.schedules = []
        case let .addSchedules(schedule):
            state.schedules.append(schedule)
        case .events:
            break
        }
        return state
    }

}
