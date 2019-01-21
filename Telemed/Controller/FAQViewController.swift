//
//  FAQViewController.swift
//  Telemed
//
//  Created by Macbook on 1/4/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    
    @IBOutlet weak var basicHealthButton: UIButton!
    @IBOutlet weak var generalProblemsButton: UIButton!
    @IBOutlet weak var medicationButton: UIButton!
    @IBOutlet weak var teledocTutorialsButton: UIButton!
    
    var destinationFAQ : Int?
    var categoryTitle : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        basicHealthButton.layer.cornerRadius = 10.0
        generalProblemsButton.layer.cornerRadius = 10.0
        medicationButton.layer.cornerRadius = 10.0
        teledocTutorialsButton.layer.cornerRadius = 10.0
    }
    

    @IBAction func faqButtonsPressed(_ sender: UIButton) {
        
        if sender.tag == 4 {
            performSegue(withIdentifier: "goToTutorials", sender: self)
        }
        else {
            categoryTitle = sender.titleLabel?.text
            destinationFAQ = sender.tag
            performSegue(withIdentifier: "goToFAQs", sender: self)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFAQs" {
            if let destinationFAQ = destinationFAQ {
                let destinationVC = segue.destination as! FAQSubViewController
                destinationVC.selectedFAQ = destinationFAQ
                if let name = categoryTitle {
                    let string = String(name.map { $0 == " " ? "\n" : $0 })
                    destinationVC.titleText = string
                }
                
                switch destinationFAQ {
                    
                case 1:
                    destinationVC.faqArray = [["Don't drink sugary drink", "Eat nuts", "Avoid processed junk food", "Don't fear coffee", "Eat fatty fish", "Get enough sleep", "Eat probiotics and fibers", "Drink some water especially before meals", "Don't overcook or burn your meat", "Avoid bright lights before sleep"]]
                case 2:
                    destinationVC.faqArray = [["Do I have insomnia?", "Do I have obesity?", "How do I develop headaches during hard work despite having had eyesight corrections?", "Why do I feel loss of apetite?"]]
                case 3:
                    destinationVC.faqArray = [["Metformin", "(Glucophage, Glumetza, etc.,)"], ["Sulfonylureas", "(Glyburide (DiaBeta, Glynase), Glipizide (Glucotrol), Glimepiride (Amaryl))"], ["Insulin therapy", ""], ["Loop diuretics", "(Lasix (furosemide), Bumetanide, Demadex (torsemide), Edecrin (ethacrynic acid))"]]
                default:
                    print("hello")
                }
            }
        }
    }

}
