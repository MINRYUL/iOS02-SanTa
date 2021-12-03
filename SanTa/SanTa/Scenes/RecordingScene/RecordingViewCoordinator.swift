//
//  RecordingViewCoordinator.swift
//  SanTa
//
//  Created by shin jae ung on 2021/11/01.
//

import UIKit

final class RecordingViewCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var recordingViewController: RecordingViewController

    private let coreDataStorage: CoreDataStorage

    init(navigationController: UINavigationController, userDefaultsStorage: UserDefaultsStorage, coreDataStorage: CoreDataStorage) {
        self.navigationController = navigationController
        self.coreDataStorage = coreDataStorage
        self.recordingViewController = RecordingViewController(
            viewModel: RecordingViewModel(
                recordingUseCase: DefaultRecordingUseCase(
                    recordRepository: DefaultRecordRepository(
                        settingsStorage: userDefaultsStorage,
                        recordStorage: CoreDataRecordStorage(
                            coreDataStorage: self.coreDataStorage
                        )
                    ),
                    recordingModel: RecordingModel(),
                    recordingPhoto: RecordingPhotoModel()
                )
            )
        )
        self.recordingViewController.coordinator = self
    }

    func start() {
        self.recordingViewController.modalPresentationStyle = .fullScreen
        self.navigationController.present(recordingViewController, animated: true)
    }

    func hide() {
        self.navigationController.dismiss(animated: true)
        guard let mapViewCoordinator = parentCoordinator as? MapViewCoordinator else { return }
        mapViewCoordinator.recordingViewDidHide()
    }

    func dismiss() {
        self.navigationController.dismiss(animated: true)
        guard let mapViewCoordinator = parentCoordinator as? MapViewCoordinator else { return }
        mapViewCoordinator.recordingViewDidDismiss()
        self.parentCoordinator?.childCoordinators.removeLast()
    }
}

extension RecordingViewCoordinator {
    func presentRecordingTitleViewController() {
        let recordingTitleViewCoordinator = RecordingTitleViewCoordinator(delegate: self.recordingViewController)
        self.childCoordinators.append(recordingTitleViewCoordinator)
        recordingTitleViewCoordinator.parentCoordinator = self

        recordingTitleViewCoordinator.start()
    }

    func presentRecordingPhotoViewController() {
        let recordingPhotoViewCoordinator = RecordingPhotoViewCoordinator(delegate: self.recordingViewController)
        self.childCoordinators.append(recordingPhotoViewCoordinator)
        recordingPhotoViewCoordinator.parentCoordinator = self

        recordingPhotoViewCoordinator.start()
    }
}
