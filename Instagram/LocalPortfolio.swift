import UIKit
import RealmSwift
import ARKit
import Lottie

final class LocalArtwork: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var caption = ""
    @Persisted var imageData = Data()
    @Persisted var createdAt = Date()
    @Persisted var favorite = false
}
extension UIViewController {
    func showStorageError(_ error: Error) {
        let alert = UIAlertController(title: "操作失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel)); present(alert, animated: true)
    }
}
final class PortfolioVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var artworks: [LocalArtwork] = []
    override func viewDidLoad() {
        super.viewDidLoad(); title = "本地作品集"
        tableView.rowHeight = 100
        #if DEBUG
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "测试样例", style: .plain, target: self, action: #selector(addDemo))
        #endif
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "AR 创作", style: .plain, target: self, action: #selector(createAR)),
            UIBarButtonItem(title: "导入", style: .plain, target: self, action: #selector(importPhoto))
        ]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated); navigationController?.setNavigationBarHidden(false, animated: animated); reload()
    }
    func reload() {
        do {
            let realm = try Realm()
            artworks = Array(realm.objects(LocalArtwork.self).sorted(byKeyPath: "createdAt", ascending: false))
            let empty = UILabel(); empty.text = "还没有作品\n可进行 AR 创作，或导入照片测试\n作品仅保存在本机"; empty.numberOfLines = 0; empty.textAlignment = .center; empty.textColor = .secondaryLabel
            tableView.backgroundView = artworks.isEmpty ? empty : nil
            tableView.reloadData()
        } catch { showStorageError(error) }
    }
    #if DEBUG
    @objc private func addDemo() {
        do {
            guard let image = UIImage(named: "pp"), let data = image.jpegData(compressionQuality: 0.85) else { return }
            let realm = try Realm()
            guard realm.object(ofType: LocalArtwork.self, forPrimaryKey: "local-test-artwork") == nil else { return }
            let item = LocalArtwork(); item.id = "local-test-artwork"; item.caption = "【测试】本地作品"; item.imageData = data
            try realm.write { realm.add(item) }; reload()
        } catch { showStorageError(error) }
    }
    #endif
    @objc func createAR() {
        guard ARWorldTrackingConfiguration.isSupported else {
            let alert = UIAlertController(title: "此设备不支持 AR 创作", message: "请在支持 ARKit 的真机上测试。当前可导入照片，测试本地保存、收藏和删除。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .cancel)); present(alert, animated: true); return
        }
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARImage")
        controller.modalPresentationStyle = .fullScreen; present(controller, animated: true)
    }
    @objc func importPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController(); picker.delegate = self; picker.sourceType = .photoLibrary; present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let data = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 0.85)
        picker.dismiss(animated: true) {
            guard let data = data else { return }
            let alert = UIAlertController(title: "保存到本机", message: "给作品添加说明（可留空）", preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "作品说明" }
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
                do {
                    let realm = try Realm(); let artwork = LocalArtwork()
                    artwork.caption = alert.textFields?.first?.text ?? ""; artwork.imageData = data
                    try realm.write { realm.add(artwork) }; self.reload()
                } catch { self.showStorageError(error) }
            })
            self.present(alert, animated: true)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { artworks.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil); let item = artworks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.caption.isEmpty ? "未命名作品" : item.caption
        content.secondaryText = item.createdAt.formatted(date: .abbreviated, time: .shortened)
        content.image = UIImage(data: item.imageData); content.imageProperties.maximumSize = CGSize(width: 80, height: 80)
        cell.contentConfiguration = content; cell.accessoryType = .disclosureIndicator; cell.isAccessibilityElement = true; cell.accessibilityLabel = content.text; cell.accessibilityTraits = .button; return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = ArtworkVC(); detail.artworkID = artworks[indexPath.row].id; navigationController?.pushViewController(detail, animated: true)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        do { let realm = try Realm(); try realm.write { realm.delete(artworks[indexPath.row]) }; reload() } catch { showStorageError(error) }
    }
}
final class ArtworkVC: UIViewController {
    var artworkID = ""
    private let picture = UIImageView()
    private let favorite = UIButton(type: .system)
    override func viewDidLoad() {
        super.viewDidLoad(); view.backgroundColor = .systemBackground
        do {
            let realm = try Realm(); guard let item = realm.object(ofType: LocalArtwork.self, forPrimaryKey: artworkID) else { return }
            title = item.caption.isEmpty ? "作品" : item.caption; picture.image = UIImage(data: item.imageData)
            favorite.setTitle(item.favorite ? "取消收藏" : "收藏", for: .normal)
        } catch { showStorageError(error) }
        picture.contentMode = .scaleAspectFit; picture.translatesAutoresizingMaskIntoConstraints = false
        favorite.translatesAutoresizingMaskIntoConstraints = false; favorite.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        view.addSubview(picture); view.addSubview(favorite)
        NSLayoutConstraint.activate([
            picture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), picture.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor), picture.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor), picture.bottomAnchor.constraint(equalTo: favorite.topAnchor, constant: -16),
            favorite.centerXAnchor.constraint(equalTo: view.centerXAnchor), favorite.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16), favorite.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    @objc func toggleFavorite() {
        do {
            let realm = try Realm(); guard let item = realm.object(ofType: LocalArtwork.self, forPrimaryKey: artworkID) else { return }
            try realm.write { item.favorite.toggle() }
            favorite.setTitle(item.favorite ? "取消收藏" : "收藏", for: .normal)
            if item.favorite {
                let animation = LOTAnimationView(name: "likeTapAni1")
                animation.frame = CGRect(x: view.bounds.midX - 60, y: view.bounds.midY - 60, width: 120, height: 120)
                animation.isUserInteractionEnabled = false; view.addSubview(animation)
                animation.play { _ in animation.removeFromSuperview() }
            }
        } catch { showStorageError(error) }
    }
}
