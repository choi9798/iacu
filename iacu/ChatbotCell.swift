//
//  ChatbotCell.swift
//  iacu
//
//  Created by mac on 20/12/2017.
//  Copyright © 2017 lens. All rights reserved.
//

import UIKit

class ChatbotCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let btnView: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 16
        btn.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("點我按摩", for: .normal)
        return btn
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(btnView)
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        btnView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18).isActive = true
        btnView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        btnView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btnView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
