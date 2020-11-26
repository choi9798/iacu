//
//  Chatbot_controller.swift
//  iacu
//
//  Created by mac on 20/12/2017.
//  Copyright © 2017 lens. All rights reserved.
//

import UIKit
import AVKit

struct Message_Frame {
    let iscurrentuser: Bool
    let message: String
    let isbtn: Bool
}

struct Get_back: Decodable{
    let acu_points:[String]?
    let `continue`:Bool?
    let question:String?
    let uid:Int?
}

struct Content: Decodable {
    let id: String?
    let type: String?
    let attributes: Attributes?
    let relationships: Relationships?
}

struct Attributes: Decodable {
    let name: String?
    let name_en: String?
    let area: String?
    let alt_name: [String]?
    let alt_name_en: [String]?
    let symptom: [String]?
    let symptom_en: [String]?
}

struct Relationships: Decodable {
    let points: Points?
}

struct Points: Decodable {
    let data: [DD]?
}

struct DD: Decodable {
    let type: String?
    let id: String?
}

class Chatbot_controller: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    let cellId = "cellId"
    let sendButton = UIButton()
    let inputTextField = UITextField()
    var containViewBottomAnchor: NSLayoutConstraint?
    //var currentState_init:Bool = false
    var currentPoint:String = ""
    
    var uid: Int = 0
    var message: [Message_Frame] = []
    var found_acu_id: String = ""
    var acupoint_position:[Int] = []
    let acuName:[String] = ["L_GB14",
                            "R_GB14",
                            "EX-HN3",
                            "L_TB23",
                            "L_U_EX-HN",
                            "R_TB23",
                            "R_U_EX-HN",
                            "L_BL2",
                            "R_BL2",
                            "L_BL1",
                            "R_GB1",
                            "R_BL1",
                            "L_GB1",
                            "R_EX-HN7",
                            "L_EX-HN7",
                            "L_ST1",
                            "R_ST1",
                            "R_EX-HN8",
                            "L_EX-HN8",
                            "R_ST2",
                            "L_ST2",
                            "R_LI20",
                            "L_LI20",
                            "R_SI18",
                            "L_SI18",
                            "R_ST3",
                            "L_ST3",
                            "R_LI19",
                            "DU26",
                            "L_LI19",
                            "R_ST4",
                            "L_ST4",
                            "R_D_EX-HN",
                            "REN24",
                            "L_D_EX-HN"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Diagnose"
        navigationController?.navigationBar.isHidden = false
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 0, 68)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatbotCell.self, forCellWithReuseIdentifier: cellId )
        collectionView?.keyboardDismissMode = .interactive
        
        JSONinit()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        sendButton.setTitle("送出", for: .normal)
        sendButton.setTitleColor(UIColor.blue, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        inputTextField.placeholder = "   輸入訊息"
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let sepratorLineView = UIView()
        sepratorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        sepratorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sepratorLineView)
        sepratorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        sepratorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sepratorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        sepratorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatbotCell
        
        cell.textView.text = self.message[indexPath.item].message
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(Text: self.message[indexPath.item].message).width + 32
        if self.message[indexPath.item].iscurrentuser == true {
            cell.bubbleView.backgroundColor = UIColor.blue
            cell.textView.textColor = UIColor.white
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
            cell.btnView.isHidden = true
        } else {
            if(self.message[indexPath.item].isbtn == false) {
                cell.bubbleView.backgroundColor = UIColor.init(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                cell.textView.textColor = UIColor.black
                cell.bubbleLeftAnchor?.isActive = true
                cell.bubbleRightAnchor?.isActive = false
                cell.btnView.isHidden = true
            } else {
                cell.btnView.isHidden = false
                cell.bubbleRightAnchor?.isActive = false
                cell.bubbleView.backgroundColor = UIColor.clear
                cell.btnView.addTarget(self, action: #selector(massage_btn_pressed), for: .touchUpInside)
            }
        }
        return cell
    }
    
    @objc func massage_btn_pressed() {
        performSegue(withIdentifier: "camSegue", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text: String = self.message[indexPath.item].message {
            height = estimateFrameForText(Text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(Text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: Text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputTextField.resignFirstResponder()
        return true
    }
    
    @objc func handleSend() {
        guard inputTextField.text?.isEmpty == false else { return }
        self.inputContainerView.endEditing(true)
        self.message.append(Message_Frame(iscurrentuser: true, message: inputTextField.text!, isbtn: false))
        collectionView?.reloadData()
        JSONblah()
        self.inputTextField.text = nil
    }
    
    func JSONblah() {
        //print("\n\n\n enter to JSON\n\n\n")
        let json = ["answer": inputTextField.text, "uid": self.uid] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "http://140.116.245.205:8080/ask")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription)
                return
            }
            do {
                let get_back = try JSONDecoder().decode(Get_back.self, from: data)
                print(get_back.acu_points, get_back.`continue`, get_back.question, get_back.uid)
                if(get_back.`continue`)! {
                    self.message.append(Message_Frame(iscurrentuser: false, message: get_back.question!, isbtn: false))
                    self.playText(text: get_back.question!)
                } else {
                    if(get_back.acu_points?.isEmpty == false) {
                        self.message.append(Message_Frame(iscurrentuser: false, message:  "建議您可以按摩以下穴道:  \(self.acuPointSearch(acu: get_back.acu_points![0]))", isbtn: false))
                        self.message.append(Message_Frame(iscurrentuser: false, message: "", isbtn: true))
                        self.acupoint_pos_search(acu: self.found_acu_id)
                        self.playText(text: "建議您可以按摩以下穴道:  \(self.acuPointSearch(acu: get_back.acu_points![0]))")
                        print("\n\n\n\n\n\n\n\(self.acupoint_position)\n\n\n\n\n\n")
                    } else {
                        self.message.append(Message_Frame(iscurrentuser: false, message: "找不到合適的穴位", isbtn: false))
                        self.playText(text: "找不到合適的穴位")
                    }
                    self.JSONinit()
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func JSONinit() {
        let urlString = "http://140.116.245.205:8080/init"
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "no data")
                return
            }
            //let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            do {
                let get_back = try JSONDecoder().decode(Get_back.self, from: data)
                print(get_back.uid, get_back.question)
                self.message.append(Message_Frame(iscurrentuser: false, message: get_back.question!, isbtn: false))
                self.playText(text: get_back.question!)
                self.uid = get_back.uid!
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func acuPointSearch(acu: String) -> String {
        let path = Bundle.main.path(forResource: "acupoints", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let datas = try Data(contentsOf: url)
            let acupoints = try JSONDecoder().decode([Content].self, from: datas)
            for ac in acupoints {
                if(ac.id == acu) {
                    found_acu_id = ac.id!
                    return (ac.attributes?.name)!
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    func acupoint_pos_search(acu: String) {
        self.acupoint_position = []
        let path = Bundle.main.path(forResource: "acupoints", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let datas = try Data(contentsOf: url)
            let acupoints = try JSONDecoder().decode([Content].self, from: datas)
            for ac in acupoints {
                if(ac.id == acu) {
                    let dd = ac.relationships?.points?.data
                    for d in dd! {
                        self.acupoint_position.append(acuName.index(of: d.id!)!)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "camSegue" {
            let cam_ViewController = segue.destination as! Camera
            cam_ViewController.acupoint_position = self.acupoint_position
        }
    }
    
    func playText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-TW")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    
}

