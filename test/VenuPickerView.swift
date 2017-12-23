import Foundation
import UIKit

extension UITextField {
    func loadDropdownData(data: [String], onSelect selectionHandler : @escaping (_ selectedText: String) -> Void) {
        self.inputView = VenuePickerView(pickerData: data, dropdownField: self, onSelect: selectionHandler)
    }
}

class VenuePickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
 
    var pickerData : [String]!
    var pickerTextField : UITextField!
    var selectionHandler: ((_ selectedText: String) -> Void)?

    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect(x: 0, y:0, width: 0, height: 0))
 
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
 
        self.delegate = self
        self.dataSource = self
        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0]
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        }
    }

    convenience init(pickerData: [String], dropdownField: UITextField, onSelect selectionHandler : @escaping (_ selectedText: String) -> Void) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        self.selectionHandler = selectionHandler
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
 
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
 
    // This function sets the text of the picker view to the content of the venue array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
 
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
        if self.pickerTextField.text != nil && self.selectionHandler != nil {
            self.selectionHandler!(self.pickerTextField.text!)
        }

    }
 
}
