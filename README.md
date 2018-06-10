# DatePickerView

`DatePickerView` 는 다양한 분야에서 사용되는 기능입니다. DatePickerView 스크롤 시 다른 기능을 방지하는 것을 소개하려고 합니다.

DatePicker Scrolling 상태에서 DatePicker의 값을 가져오려고 시도 시 Scrolling 되어 있는 값이 아니라 초기값 또는 Scolling 이 완료되었을 때는 값을 가져오게 됩니다. 사용자 입장에서는 오류로 보일 수도 있기에 위의 동영상과 같이 스크롤 되고 있을 경우 버튼 클릭 방지 등 다른 작업을 할 수 없도록 방지하였습니다.

여기서 사용한 기능은 **Guesture** 기능과 UIScrollView의 **Dragging Check Function** 입니다.

- 소개할 예제는 DatePicker 가 Scrolling 시 "버튼" 동작 정지하고, Scrolling이 멈추게 되면 "동작" 할 수 있도록 구현한 소스 입니다.

<br/>

[![Demo CountPages alpha](https://camo.githubusercontent.com/315419115966342f83616e55e9e4b63bccc8757c/68747470733a2f2f6a2e676966732e636f6d2f56507651566f2e676966)](https://www.youtube.com/watch?v=YHncDpIb_B0)

<br/>

## **1. Gesture 등록 및 delegate 연결**

**DatePicker**가 스와이프 시점을 알기 위해서 **Gesture**을 동록해야합니다. 

여기서 가장 중요한 부분은 delegate 연결입니다.  

Gesture 마다 delegate을 연결하여 PickerView의 움직임에 따른 Gesture 감지 할 수 있도록 합니다.

```swift
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
```

<br/>

## **2. View extent 선언**

실질적으로 Scrolling 을 체크하는 부분 입니다. 

DatePicker 뷰는 UIScrollView 을 상속 받고 있기에 ScrollView의 함수인 "isDragging"을 사용할 수 있는 것으로 보입니다.

UIScrollView의 **isDragging**  또는 **isDeceleration**으로 스크롤링을 체크합니다.

```swift
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
```

<br/>

## **3. 제스터 입력 시 마다 호출 하는 함수**

Gesture 입력 시 마다 "버튼" 동작을 disable 상태로 변경하고, **extent**로 선언하였던 **waitTillDoneScrolling()**을 호출합니다.

**waitTillDoneScrolling()**의 Closer로 선언한 Completion()이 호출되면 "버튼" 동작을 enable로 변경하여 동작할 수 있도록 합니다.

```swift
// Guesture 동작 있을 때 마다 호출 합니다.
@objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    // 스크롤 시작 시 Scrolling...으로 버튼을 변경합니다.
    self._button.setTitle("Scrolling...", for: .normal)
    self._button.isEnabled = false
    self._button.backgroundColor = Utils.hexStringToUIColor(hex: "FF8FAE")
        
    // 스크롤링 상태에 따른 표시
    _datePicker.waitTillDoneScrolling(completion: {
        print("completion")
        self._button.setTitle("Completion", for: .normal)
        self._button.isEnabled = true
        self._button.backgroundColor = Utils.hexStringToUIColor(hex: "7CB0FF")
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
```

<br/>

## 4. 다른 방식인 DatePickerView Action

**DatePickerView**의 **ValueChangedTimePicker(_)** 라는 **IBAction**이 있습니다. **extension**에서 스크롤링이 종료됬을 경우 event처리하는 것을 IBAction에서 처리해주면 됩니다. 

1. **Gesture** 체크를 통한 상,하 이동 시 **Button disable** 처리

1. **PickerView**의 **ValueChangedTimePicker()** 된 시점에 **Button enable** 처리

```swift
@IBAction func ValueChangedTimePicker(_ sender: Any) {     self._button.setTitle("Completion", for: .normal)     self._button.isEnabled = true     self._button.backgroundColor = Utils.hexStringToUIColor(hex: "7CB0FF") }
```

<br/>

# **정리**

DataPickerView의 특정상 스크롤링 되고 있는 상태에서는 값 변경 인식을 안하게 됩니다. 그렇기에 스크롤링 상태에서 다른 기능 방지하는 방어코드가 있으면 앱의 완성도를 높일 수 있습니다.

