
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
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var graphBtn: UIButton!
    @IBOutlet weak var endWorkoutBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mainLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nc observers
        NotificationCenter.default.addObserver(self, selector: #selector(catchBase(_:)), name: Notification.Name("baseData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(catchGyro(_:)), name: Notification.Name("gyroData"), object: nil)
        
        // UI
        startBtn.setTitle("Start", for: .normal)
        startBtn.layer.cornerRadius = 20
        graphBtn.setTitle("View Graphs", for: .normal)
        graphBtn.layer.cornerRadius = 20
        graphBtn.isHidden = true
        endWorkoutBtn.setTitle("End Workout", for: .normal)
        endWorkoutBtn.layer.cornerRadius = 20
        endWorkoutBtn.isHidden = true
        titleLbl.text = UserData.workoutType
        
        mainLbl.attributedText = makeFont("You have selected ", UserData.workoutType, "\n\nTo begin your workout, hit the ", "Start", " button below.")
        mainLbl.textAlignment = .center
        
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange
        
        // data management
        UserData.exer.type = UserData.workoutType
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        UserData.exer.date = formatter.string(from: now)

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
    
    func makeFont1(_ first: String, _ second: String, _ third: String, _ fourth: String, _ fifth: String, _ sixth: String, _ seventh: String, _ eigth: String) -> NSMutableAttributedString {
        let bold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .bold)]
        let regular = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .regular)]
        let firstStr = NSMutableAttributedString(string: first, attributes: bold)
        let secondStr = NSMutableAttributedString(string: second, attributes: regular)
        let thirdStr = NSMutableAttributedString(string: third, attributes: bold)
        let fourthStr = NSMutableAttributedString(string: fourth, attributes: regular)
        let fifthStr = NSMutableAttributedString(string: fifth, attributes: bold)
        let sixthStr = NSMutableAttributedString(string: sixth, attributes: regular)
        let seventhStr = NSMutableAttributedString(string: seventh, attributes: bold)
        let eigthStr = NSMutableAttributedString(string: eigth, attributes: regular)
        seventhStr.append(eigthStr)
        seventhStr.append(firstStr)
        seventhStr.append(secondStr)
        seventhStr.append(thirdStr)
        seventhStr.append(fourthStr)
        seventhStr.append(fifthStr)
        seventhStr.append(sixthStr)
        return seventhStr
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
            
            // update buttons
            graphBtn.isHidden = false
            endWorkoutBtn.isHidden = false
            startBtn.setTitle("Start Another Set", for: .normal)
            
            // update label
            mainLbl.attributedText = makeFont1("\n\nReps: ", "\(num_reps)", "\n\nAverage Velocity per Rep: ", "\(velAvgs)", "\n\nPeak Velocity per Rep: ", "\(velPeaks)", "Set: ", "\(UserData.exer.num_sets)")
            mainLbl.textAlignment = .left
            
            // data management
            UserData.exer.sets.append(set(reps: num_reps, avgVel: velAvgs, peakVel: velPeaks))
            
        } else {print("******ERROR******")}
    }
    
    @objc func catchGyro(_ noti: Notification) {
        if let (arrx, arry, arrz) = noti.object as! ([Float], [Float], [Float])? {
            xGyro = arrx
            yGyro = arry
            zGyro = arrz
        } else {print("******ERROR******")}
    }
    
    @IBAction func displayBLE() {
        let vc = storyboard?.instantiateViewController(identifier: "BLE") as! BLEViewController
        vc.modalPresentationStyle = .fullScreen
        // increment number of sets
        UserData.exer.num_sets += 1
        present(vc, animated: true)
    }
    
    @IBAction func endWorkout() {
        let vc2 = storyboard?.instantiateViewController(identifier: "Landing") as! LandingViewController
        vc2.modalPresentationStyle = .fullScreen
        UserData.past_exer.append(UserData.exer)
        UserData.exer = exercise(type: "null", num_sets: 0, date: "", sets: [])
        present(vc2, animated: true)
    }
    
    @IBAction func displayGraph() {
        let vc1 = storyboard?.instantiateViewController(identifier: "GraphVC") as! GraphViewController
        vc1.modalPresentationStyle = .fullScreen
        UserData.tempUpVel = up_vel_iso
        present(vc1, animated: true)
    }
    
    @IBAction func didTapBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    func process_data() -> (Int, [Float], [Float], [Float], [Float], [[Int]]) {
            
        //let angularDispXZPlane: [Float] = dp.noise_comp(dp.trap_rule(dp.gyro_smooth(yGyro), sample_period), yGyro.count)
                
        let angularDispXZPlane: [Float] = dp.trap_rule(dp.gyro_smooth(yGyro), sample_period)
                
        //agldisp = angularDispXZPlane
        _ = dp.gyro_crush_acc(yGyro, accAx1: zAcc, accAx2: xAcc)
                
        let agl_adjZ = dp.gyro_comb_angle(gyro: angularDispXZPlane, agl2gnd: agl2gndZ)
        let agl_adjX = dp.gyro_comb_angle(gyro: angularDispXZPlane, agl2gnd: agl2gndX)
        
        // get velocity in each axis
        xVel = dp.noise_comp(dp.trap_rule(xAcc, sample_period), xAcc.count)
        //yVel = noise_comp(trap_rule(yAcc), yAcc.count)
        zVel = dp.noise_comp(dp.trap_rule(zAcc, sample_period), zAcc.count)
        
        // get upward acc and vel
        let up_acc = dp.orientation_correction([xAcc],[zAcc],[agl_adjX],[agl_adjZ])
        let up_vel = dp.orientation_correction([xVel],[zVel],[agl_adjX],[agl_adjZ])
        
        // get and return rest of data
        var lwr: Int = 0
        var upr: Int = 0
        var up_acc_iso: [Float] = [0.0]
        (lwr, upr) = dp.set_range(up_acc)
        (up_vel_iso, up_acc_iso) = dp.in_rep_slope(lwr, upr, up_vel, up_acc)
            
        return dp.rep_count(up_vel_iso, up_acc_iso)
    }
}