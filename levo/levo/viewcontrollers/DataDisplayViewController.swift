//
//  DataDisplayViewController.swift
//  levo
//
//  Created by Matthew Chute on 2021-07-28.
//

import UIKit

class DataDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UserData.past_exer[UserData.whichCell].num_sets
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = "Set: \(indexPath.row+1)"
        
        cell.detailTextLabel?.text = "Reps: \(UserData.past_exer[UserData.whichCell].sets[indexPath.row].reps.description)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        UserData.whichCell = indexPath.row
//        let vc = storyboard?.instantiateViewController(identifier: "Data") as! DataDisplayViewController
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = UserData.past_exer[UserData.whichCell].type

        // Do any additional setup after loading the view.
        backBtn.frame = CGRect(x: 25, y: 25, width: 25, height: 25)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        backBtn.tintColor = .systemOrange

    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBAction func goBack() {
        dismiss(animated: true, completion: nil)
    }

}
