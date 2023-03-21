/**
 View controller for the Level Select screen.
 */

import UIKit

class IndependentLevelSelectViewController: UITableViewController {

    var levelNames: [String]!
    var selectedLevelName: String?

    weak var loadLevelDelegate: LoadLevelDelegate?

    // Used to save and load from persistent storage
    let levelDataManager = LevelDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // create alert saying cannot fetch data
        do {
            let levelDatas = try levelDataManager.fetchAllLevelData()
            levelNames = levelDatas.compactMap({ $0.name })
        } catch {
            presentAlert(message: "Unexpected error \(error.localizedDescription).")
        }
    }

    @IBAction func quitButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        levelNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let labelRect = CGRect(x: 10, y: 0, width: 200, height: 50)
        let label = UILabel(frame: labelRect)
        label.text = levelNames[indexPath.row]
        cell.addSubview(label)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PeggleGameViewController {
            destination.levelDataSource = self
        }
    }

    private func presentAlert(title: String = "Error", message: String) {
        let alertMessage = message
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLevelName = levelNames[indexPath.row]
    }
}

extension IndependentLevelSelectViewController: LevelDataSource {
    func getLevelName() -> String? {
        selectedLevelName
    }

    func update() {
        return
    }
}
