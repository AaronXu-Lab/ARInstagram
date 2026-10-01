# ARInstagram

无需账号的本地作品集，支持 AR 创作、照片导入、作品浏览、收藏与删除。

## 构建

- iOS 26 及以上，Swift 5；已用 Xcode 27 beta / iOS 27 模拟器验证。原工程的 iOS 11 与 iOS 8 Pods 目标无法在当前工具链构建，因此提高系统版本。
- 直接打开 `Instagram.xcodeproj`，选择 `Instagram` scheme。首次打开让 Xcode 解析 Swift Package 依赖。
- 无需 CocoaPods、LeanCloud 配置或登录账号。真机运行需选择自己的签名团队。

## 存储与依赖

RealmSwift 20.0.6 通过官方远程 SPM 包引入，仅保存本机数据；无云端同步。数据位于应用沙盒的 Realm 文件，卸载应用会删除。旧 LeanCloud 服务器数据不会自动恢复或迁移。

保留的第三方库：EFColorPicker 1.0.0、SVProgressHUD 2.2.2、Lottie 2.1.4。这些旧版源码位于 `Packages/LegacyDependencies`，以本地 Swift Package 接入，保留许可证并修正 Swift 5 / 当前 SDK 的编译兼容性；不是改成系统原生替代，也不是上游远程 SPM 版本。`Package.resolved` 锁定 Realm 依赖。

## 本次调整

移除 LeanCloud、注册/登录、用户关系、社交动态及相关控制器。保留 AR 编辑器、颜色选择器、Popover 和 Lottie 收藏动画；修正动画的绝对路径引用。

统一移除旧 Pods、Podfile、Podfile.lock、外层 CocoaPods workspace，以及个人 Xcode 状态文件；保留 `.xcodeproj` 内供 SPM 使用的 workspace 元数据。

## 测试

Debug 构建：首页“测试样例”添加一张原项目内置图片，记录标记为测试数据。可以浏览、收藏、重启验证和左滑删除。AR 创作须在支持 ARKit 的真机上测试，模拟器会显示提示。

在 Xcode 使用 Product → Test，运行 `InstagramTests`。存储测试使用临时独立 Realm 文件，不修改实际应用数据。

网络内容依赖原外部服务；构建成功不代表外部数据源可用。真机传感器行为与签名安装需在设备上复核。

## 验证记录（2026-10-01）

- Xcode 27 beta / iOS 27 模拟器构建与启动通过。
- 通用 iOS 真机目标无签名编译通过；尚未在真机执行传感器功能。
- 本地存储回归测试通过：2 项。
