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
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!

    private var duration: Int = 1

    private let repository: MessageRepository = DefaultMessageRepository(
        roomID: "1"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        self.duration = Int(sender.value)
        self.durationLabel.text = String(Int(sender.value))
    }

    @IBAction func submitButtonTouched(_ sender: UIBarButtonItem) {
        guard let topic = self.topicTextField.text
        else { return }
        let date = self.datePicker.date
        let duration = self.duration
        let schedule = DisscussionSchedule(ID: "",
                                           date: date,
                                           duration: duration,
                                           topic: topic)
        self.repository.addSchedule(schedule)
        self.navigationController?.popViewController(animated: true)
    }

}
