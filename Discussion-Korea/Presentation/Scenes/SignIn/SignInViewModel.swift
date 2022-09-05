//
//  SignInViewModel.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/09/06.
//

final class SignInViewModel: ViewModelType {

    // MARK: - properties

    private let navigator: SignInNavigator

    private let userInfoUsecase: UserInfoUsecase

    // MARK: - init/deinit

    init(navigator: SignInNavigator,
         userInfoUsecase: UserInfoUsecase) {
        self.navigator = navigator
        self.userInfoUsecase = userInfoUsecase
    }

    // MARK: - methods

    func transform(input: Input) -> Output {
        return Output()
    }

}

extension SignInViewModel {

    struct Input {
        
    }

    struct Output {
        
    }

}
