//
//  FAQSubViewController.swift
//  Telemed
//
//  Created by Macbook on 1/4/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import UIKit

class FAQSubViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var faqTable: UITableView!
    
    var selectedFAQ : Int?
    var faqArray : [[String]]?
    var titleText : String?
    var formattedString = NSMutableAttributedString()
    var titleFormattedString = NSMutableAttributedString()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        faqTable.delegate = self
        faqTable.dataSource = self
        
        if let selectedFAQ = selectedFAQ {
            if selectedFAQ == 3 {
                faqTable.register(UINib(nibName: "MedicationTableViewCell", bundle: nil), forCellReuseIdentifier: "faqCell")
            }
            else {
                faqTable.register(UINib(nibName: "FAQTableViewCell", bundle: nil), forCellReuseIdentifier: "faqCell")
            }
        }
        
        if let titleText = titleText {
            titleLabel.text = titleText
        }
        
        configureTable(faqTable)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! FAQInfoViewController
        destinationVC.infoText = formattedString
        destinationVC.faqTitleText = titleFormattedString
        
        
    }

}

extension FAQSubViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let selectedFAQ = selectedFAQ {
            if selectedFAQ == 3 {
                return faqArray?.count ?? 1
            }
        }
        return faqArray?.first?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let selectedFAQ = selectedFAQ {
            if selectedFAQ == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "faqCell") as! MedicationTableViewCell
                cell.medication.text = faqArray?[indexPath.section][0] ?? "No information"
                cell.info.text = faqArray?[indexPath.section][1] ?? "No information"
                cell.view.layer.cornerRadius = 10.0
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "faqCell") as! FAQTableViewCell
        if let selectedFAQ = selectedFAQ {
            if selectedFAQ == 1 {
                cell.header.text = "\(indexPath.section + 1)."
                cell.selectionStyle = .none
            }
            else {
                cell.header.text = "Q:"
            }
        }
        cell.content.text = faqArray?.first?[indexPath.section] ?? "No information"
        cell.view.layer.cornerRadius = 10.0
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func configureTable(_ table: UITableView) {
        
        table.separatorStyle = .none
        table.estimatedRowHeight = 120.0
        table.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedFAQ = selectedFAQ {
            
            switch selectedFAQ {
                
            case 1:
                print("1")
            case 2:
                
                titleFormattedString = NSMutableAttributedString()
                titleFormattedString
                    .bigBold(faqArray?[0][indexPath.section] ?? "No category selected")
                
                switch indexPath.section {
                    
                case 0:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("A:\nYou might have insomnia if you:\n")
                        .normal("-have difficulty falling asleep at night.\n-wake up during the night.\n-wake up too early.\n-do not feel refreshed after waking up.\n-feel tired and sleepy during the day.\n-feel irritated, depressed, and anxious.\n-find it difficult to concentrate or remembering things.\n-have accidents more frequently.\n\n")
                        .bold("You can treat this by yourself using:\n")
                        .normal("-Stimulus control therapy\n-Sleep restriction\n-Remaining passively awake (paradoxical intention)\n-Light therapy")
                    

                
                case 1:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("A:\nSymptoms:\n")
                        .normal("-Body Mass Index (BMI): 30 or higher\n-BMI = weight(kg)/height^2(m^2)\n\n")
                        .bold("You can treat or prevent this by:\n")
                        .normal("-Exercising regularly\n-Moderate intensity activity: 150-300 minutes per day\n-Fast walking, swimming\n-Following a healthy eating plan\n-Healthy: low-calorie, nutrient-dense foods (fruits, vegetables, whole grains)\n-Unhealthy: saturated fat, sweets, alcohol\n-Monitoring your weight at least once a week\n-Being consistent and stick to your healthy eating plan")

                case 2:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("A:\nSigns and symptoms of a tension headache include:\n")
                        .normal("-Dull, aching head pain\n-Sensation of tightness or pressure across your forehead or on the sides and back of your head\n-Tenderness on your scalp, neck and shoulder muscles\n\n")
                        .bold("Prevention:\n")
                        .normal("-Biofeedback training. This technique teaches you to control certain body responses that help reduce pain. During a biofeedback session, you're connected to devices that monitor and give you feedback on body functions such as muscle tension, heart rate and blood pressure. You then learn how to reduce muscle tension and slow your heart rate and breathing yourself.\n-Cognitive behavioral therapy, a type of talk therapy, may help you learn to manage stress and may help reduce the frequency and severity of your headaches.\n-Other relaxation techniques such as deep breathing, yoga, meditation and progressive muscle relaxation, may help your headaches.")
                    

                case 3:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("A:\nCause:\n")
                        .normal("-Changing taste buds\n-Depression, loneliness\n-Medication side effects\n\n")
                        .bold("Treatment:\n")
                        .normal("-Increase nutrient density, not portion size (Ex: avocado, olive oil, peanut butter)\n-Set regular eating plan\n-Go to social meals\n-Chewing gum, brushing teeth and oral rinsing frequently to alleviate dry mouth problems from medication side effects\n-May consider using an appetite stimulant")
                    

                    
                default:
                    print("hello")
                }
                
                performSegue(withIdentifier: "goToAnswer", sender: self)
                
            case 3:
                
                titleFormattedString = NSMutableAttributedString()
                titleFormattedString
                    .bigBold((faqArray?[indexPath.section][0] ?? "No category selected") + "\n")
                    .bold(faqArray?[indexPath.section][1] ?? "No category")
                
                switch indexPath.section {
                    
                case 0:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("Tablets\n\nCautions\n")
                        .normal("-Avoid using this medication if allergic to this medication.\n-Patients with any disease relating to liver or kidney should consult with their doctor before using this medication.\n-Patients already using chlorpropamide should inform their physician before starting this medication.\n-This medication might cause lactic acidosis, which is a lethal condition. Patients drinking alcohol regularly should consult with their doctor first.\n-Using this medication along with iodinated contrast agents can increase risks of lactic acidosis.\n-Patients over 80 years old and have not check their kidneys should consult with their doctor before using this medication\n\n")
                        .bold("Possible side effects\n")
                        .normal("-nausea, diarrhea")
                
                case 1:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("Cautions\n")
                        .normal("-Avoid using this medication if allergic to this medication.\n-Patients with any disease relating to liver or kidney should consult with their doctor before using this medication.\n-Do not use sulfonylureas with other diabetes medications (by yourself) without prescription from your doctor.\n-Use this medication and control your diet that might increase blood sugar level\n-Check your blood sugar level regularly\n-If patients using this medication show signs of being allergic to this medication (symptoms: high fever, rash, difficulty breathing), medical attention is needed immediately.\n\n")
                        .bold("Possible side effects\n")
                        .normal("-low blood sugar, weight gain")
                
                case 2:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .normal("-Often, people with type 2 diabetes start insulin use with one long-acting shot at night.\n-Insulin injections involve using a fine needle and syringe or an insulin pen injector (a device that looks similar to an ink pen, except the cartridge is filled with insulin)\n-Read the instructions that come with the device that you are using or ask your doctor to show you how to use it.\n-Do not inject insulin into muscles, scars, or moles\n-Inject insulin in a different site each time -Never reuse needles and never share your pen injector\n-Possible side effects (if severe, tell your doctor): redness, swelling, and itching at the injection site, changes in the feel of your skin, skin thickening, or a little depression in the skin, weight gain, constipation")
                
                case 3:
                    formattedString = NSMutableAttributedString()
                    formattedString
                        .bold("For lowering blood pressure\n\nCautions\n")
                        .normal("You should be careful and consult your doctor before using this medication if you:\n-Have any severe liver or kidney disease\n-Are dehydrated\n-Have an irregular heartbeat\n-Are age 65 or older\n-Have gout\n-Are allergic to sulfa drugs, like Septra\nand Bactrim (sulfamethoxazole with\ntrimethoprim)\n-Are already taking drugs that can\ndamage hearing\n\n")
                        .bold("Common side effects\n")
                        .normal("-Dizziness or headache, thirstiness, rash or itching, higher blood glucose or cholesterol level, changes in your sexual function or menstrual period, muscle cramps, ringing in the ears")
                default:
                    print("hello")
                }
                
                performSegue(withIdentifier: "goToAnswer", sender: self)
            default:
                print("hell")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension NSMutableAttributedString {
                
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
    
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
    
        return self
    }
    
    @discardableResult func bigBold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "HelveticaNeue-Bold", size: 30)!]
        let bigBoldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(bigBoldString)
        
        return self
    }
    
//    @discardableResult func sub(_ text: String) -> NSMutableAttributedString {
//        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica Neue", size: 10)!, .baselineOffset:10]
//        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
//
//        append(boldString)
//
//        return self
//    }
}
