//
//  ViewController.swift
//  PickerView_Sample
//
//  Created by dev.faith on 2017. 11. 22..
//  Copyright © 2017년 kcs. All rights reserved.
//
// reference
// 1) https://stackoverflow.com/questions/24215117/how-to-recognize-swipe-in-all-4-directions
// 2) https://stackoverflow.com/questions/9202283/uipickerview-detect-rolling-wheel-start-and-stop
//

import UIKit

extension UIView {
    //MARK: 스크롤하고 있는 상태인지 체크합니다.
    func isScrolling () -> Bool {
        
        if let scrollView = self as? UIScrollView {
            if (scrollView.isDragging || scrollView.isDecelerating) {
                return true
            }
        }
        
        for subview in self.subviews {
            if ( subview.isScrolling() ) {
                return true
            }
        }
        return false
    }
    
    //MARK: 스크롤이 되고있는지 판단 후 스크롤이 마치면 Closer로 해당 내용을 리턴해 줍니다.
    func waitTillDoneScrolling (completion: @escaping () -> Void) {
        var isMoving = true
        DispatchQueue.global(qos: .background).async {
            while isMoving == true {
                isMoving = self.isScrolling()
            
            }
            DispatchQueue.main.async {
                completion()}
            
        }
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var _button: UIButton!
    
    @IBOutlet var _swipeGesture: UISwipeGestureRecognizer!
    @IBAction func _acitonButton(_ sender: Any) {
        print("Action Button!!")
//        let df = DateFormatter()
//        df.dateFormat = "yyyy-mm-dd  hh:mm"
//
//        let date = df.date(from: )

        Utils.showAlert(viewController: self, title: "notice", msg: "\(_datePicker.date)", buttonTitle: "OK", handler: ({ (UIAlertAction) in
                print("End")
        }))
    }
    @IBOutlet weak var _datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        settingDatePickerViewGesture()
    }
    
    
    //MARK: DatePicker 제스쳐 세팅
    func settingDatePickerViewGesture(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        // Gesture Delegate을 통하여 DatePicker 안에서 Gesture을 판단할 수 있습니다.
        swipeRight.delegate = self
        _datePicker.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.delegate = self
        _datePicker.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.delegate = self
        _datePicker.addGestureRecognizer(swipeUp)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Guesture 동작 있을 때 마다 호출 합니다.
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        // 스크롤 시작 시 Scrolling...으로 버튼을 변경합니다.
        DispatchQueue.main.async {
            self._button.setTitle("Scrolling...", for: .normal)
            self._button.isEnabled = false
            self._button.backgroundColor = Utils.hexStringToUIColor(hex: "FF8FAE")
        }
       
        
        // 스크롤링 상태에 따른 표시
        _datePicker.waitTillDoneScrolling(completion: {
            print("completion")
                DispatchQueue.main.async {
                self._button.setTitle("Completion", for: .normal)
                self._button.isEnabled = true
                self._button.backgroundColor = Utils.hexStringToUIColor(hex: "7CB0FF")
            }
        })
        // 스크롤 방향에 따른 표시
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

