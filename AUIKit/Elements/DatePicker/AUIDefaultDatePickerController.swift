//
//  AUIDefaultDatePickerController.swift
//  AUIKit
//
//  Created by Ihor Myroniuk on 1/17/19.
//

import UIKit

open class AUIDefaultDatePickerController: AUIDefaultControlController, AUIDatePickerController {
  
  // MARK: UIDatePicker
  
  public var datePicker: UIDatePicker? {
    set { view = newValue }
    get { return view as? UIDatePicker }
  }
  
  // MARK: Delegates
  
  public weak var didSelectDateDelegate: AUIDatePickerControllerDidSelectDateDelegate?
  
  // MARK: Dates
  
  public var date: Date = Date() {
    didSet {
      didSetDate(oldValue)
    }
  }
  
  open func didSetDate(_ oldValue: Date) {
    datePicker?.date = date
  }
  
  public var minimumDate: Date? = nil {
    didSet {
      didSetMinimumDate(oldValue)
    }
  }
  
  open func didSetMinimumDate(_ oldValue: Date?) {
    datePicker?.minimumDate = minimumDate
  }
  
  // MARK: View
  
  open override func setupView() {
    super.setupView()
    datePicker?.date = date
    datePicker?.minimumDate = minimumDate
  }
  
  open override func unsetupView() {
    super.unsetupView()
    datePicker?.date = date
    datePicker?.minimumDate = minimumDate
  }
  
  // MARK: Events
  
  open override func valueChangedEventAction() {
    super.valueChangedEventAction()
    didSelectDateDelegate?.datePickerController(self, didSelectDate: date)
  }
  
}
