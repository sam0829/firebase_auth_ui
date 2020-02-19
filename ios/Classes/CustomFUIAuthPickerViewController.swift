import UIKit
import FirebaseUI

class CustomFUIAuthPickerViewController: FUIAuthPickerViewController {
    
    @IBOutlet weak var logo: UIImageView!

    override func viewWillAppear(_ animated: Bool) {
        let uiImage = UIImage(named: "auth_ui_logo")
        if uiImage != nil {
            logo.image = uiImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
