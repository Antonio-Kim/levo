
//  ViewController.swift
//  levo
//
//  Created by Antonio Kim on 2021-06-21.
//
import UIKit

class WorkoutViewController: UIViewController {
    
    var dp = DataProcessing()
    
    // acceleration
    var xAcc: [Float] = [3.0]
    var yAcc: [Float] = [3.0]
    var zAcc: [Float] = [3.0]
    var accAvgs: [Float] = [3.0]
    var accPeaks: [Float] = [3.0]
    
    // velocity
    var xVel: [Float] = [3.0]
    var yVel: [Float] = [3.0]
    var zVel: [Float] = [3.0]
    var up_vel_iso: [Float] = [3.0]
    var velAvgs: [Float] = [3.0]
    var velPeaks: [Float] = [3.0]
    
    // gyro and angle
    var xGyro: [Float] = [3.0]
    var yGyro: [Float] = [3.0]
    var zGyro: [Float] = [3.0]
    var agl2gndX: [Float] = [3.0]
    var agl2gndY: [Float] = [3.0]
    var agl2gndZ: [Float] = [3.0]

    // other data
    var num_reps: Int = 0
    var range_of_reps: [[Int]] = [[3]]
    var sample_period: Float = 3.0
    
    // UI
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var xBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mainLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nc observers
        NotificationCenter.default.addObserver(self, selector: #selector(catchBase(_:)), name: Notification.Name("baseData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchGyro(_:)), name: Notification.Name("gyroData"), object: nil)
        
        // UI
        btn.setTitle("Start", for: .normal)
        btn.layer.cornerRadius = 20
        xBtn.setTitle("View Graphs", for: .normal)
        xBtn.layer.cornerRadius = 20
        xBtn.isHidden = true
        titleLbl.text = UserData.workoutType
        
        mainLbl.attributedText = makeFont("You have selected ", UserData.workoutType, "\n\nTo begin your workout, hit the ", "Start", " button below.")
        mainLbl.textAlignment = .center
        
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange

    }
    
    func makeFont(_ first: String, _ second: String, _ third: String, _ fourth: String, _ fifth: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .regular)]
        let str = NSMutableAttributedString(string: first, attributes: regular)
        let secondStr = NSMutableAttributedString(string: second, attributes: bold)
        let thirdStr = NSMutableAttributedString(string: third, attributes: regular)
        let fourthStr = NSMutableAttributedString(string: fourth, attributes: bold)
        let fifthStr = NSMutableAttributedString(string: fifth, attributes: regular)
        str.append(secondStr)
        str.append(thirdStr)
        str.append(fourthStr)
        str.append(fifthStr)
        return str
    }
    
    func makeFont1(_ first: String, _ second: String, _ third: String, _ fourth: String, _ fifth: String, _ sixth: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .regular)]
        let str = NSMutableAttributedString(string: first, attributes: bold)
        let secondStr = NSMutableAttributedString(string: second, attributes: regular)
        let thirdStr = NSMutableAttributedString(string: third, attributes: bold)
        let fourthStr = NSMutableAttributedString(string: fourth, attributes: regular)
        let fifthStr = NSMutableAttributedString(string: fifth, attributes: bold)
        let sixthStr = NSMutableAttributedString(string: sixth, attributes: regular)
        str.append(secondStr)
        str.append(thirdStr)
        str.append(fourthStr)
        str.append(fifthStr)
        str.append(sixthStr)
        return str
    }
    
    @objc func catchBase(_ noti: Notification) {
        if let (arrx, arry, arrz, aglx, agly, aglz, tsp) = noti.object as! ([Float], [Float], [Float], [Float], [Float], [Float], Float)? {
            xAcc = arrx
            yAcc = arry
            zAcc = arrz
            agl2gndX = aglx
            agl2gndY = agly
            agl2gndZ = aglz
            sample_period = tsp
            if xAcc.count > 1 {
                (num_reps, velAvgs, velPeaks, accAvgs, accPeaks, range_of_reps) = process_data()
            }
            xBtn.isHidden = false
            
            mainLbl.attributedText = makeFont1("Reps: ", "\(num_reps)", "\n\nAverage Velocity per Rep: ", "\(velAvgs)", "\n\nPeak Velocity per Rep: ", "\(velPeaks)")
            mainLbl.textAlignment = .left
            
        } else {print("******ERROR******")}
    }
    
    @objc func catchGyro(_ noti: Notification) {
        if let (arrx, arry, arrz) = noti.object as! ([Float], [Float], [Float])? {
            xGyro = arrx
            yGyro = arry
            zGyro = arrz
        } else {print("******ERROR******")}
    }
    
    @IBAction func didtap() {
        let vc = storyboard?.instantiateViewController(identifier: "BLE") as! BLEViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func displayXData() {
        let vc1 = storyboard?.instantiateViewController(identifier: "GraphVC") as! GraphViewController
        vc1.modalPresentationStyle = .fullScreen
        UserData.tempUpVel = up_vel_iso
        present(vc1, animated: true)
    }
    
    @IBAction func didTapBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    func process_data() -> (Int, [Float], [Float], [Float], [Float], [[Int]]) {
        
        // get velocity in each axis
        xVel = dp.noise_comp(dp.trap_rule(xAcc, sample_period), xAcc.count)
        //yVel = noise_comp(trap_rule(yAcc), yAcc.count)
        zVel = dp.noise_comp(dp.trap_rule(zAcc, sample_period), zAcc.count)
        
        // get upward acc and vel
        let up_acc = dp.orientation_correction([xAcc],[zAcc],[agl2gndX],[agl2gndZ])
        let up_vel = dp.orientation_correction([xVel],[zVel],[agl2gndX],[agl2gndZ])
        
        // get and return rest of data
        var lwr: Int = 0
        var upr: Int = 0
        var up_acc_iso: [Float] = [0.0]
        (lwr, upr) = dp.set_range(up_acc)
        (up_vel_iso, up_acc_iso) = dp.in_rep_slope(lwr, upr, up_vel, up_acc)
            
        return dp.rep_count(up_vel_iso, up_acc_iso)
    }
}
