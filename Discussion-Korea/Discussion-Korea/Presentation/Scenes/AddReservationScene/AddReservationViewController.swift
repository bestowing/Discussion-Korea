//
//  AddReservationViewController.swift
//  Discussion-Korea
//
//  Created by 이청수 on 2022/04/04.
//

import UIKit

final class AddReservationViewController: UIViewController {

    @IBOutlet private weak var submitButton: UIBarButtonItem!
    @IBOutlet private weak var topicTextField: UITextField!
    @IBOutlet private weak var introTimeLabel: UILabel!
    @IBOutlet private weak var mainTimeLabel: UILabel!
    @IBOutlet private weak var conclusionTimeLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!

    private var introDuration: Int = 1
    private var mainDuration: Int = 1
    private var conclusionDuration: Int = 1

    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTapGestureRecognizer()
    }

    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func viewDidTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func introStepperValueChanged(_ sender: UIStepper) {
        self.introDuration = Int(sender.value)
        self.introTimeLabel.text = String(Int(sender.value))
    }

    @IBAction func mainStepperValueChanged(_ sender: UIStepper) {
        self.mainDuration = Int(sender.value)
        self.mainTimeLabel.text = String(Int(sender.value))
    }

    @IBAction func conclusionStepperValueChanged(_ sender: UIStepper) {
        self.conclusionDuration = Int(sender.value)
        self.conclusionTimeLabel.text = String(Int(sender.value))
    }

    @IBAction func submitButtonTouched(_ sender: UIBarButtonItem) {
        guard let topic = self.topicTextField.text,
              !topic.isEmpty
        else { return }
        let date = self.datePicker.date
        let schedule = DisscussionSchedule(ID: "",
                                           date: date,
                                           introduction: self.introDuration,
                                           main: self.mainDuration,
                                           conclusion: self.conclusionDuration,
                                           topic: topic)
        self.repository.addSchedule(schedule)
        self.navigationController?.popViewController(animated: true)
    }

}
