# JieLiSdkRecorder 中文使用指南

[English Documentation](../README.md)

JieLiSdkRecorder 是面向录音类蓝牙设备的 Swift SDK，统一封装了杰理等平台设备的扫描、连接、录音、文件与 OTA 操作。

## 1. 支持能力

- 蓝牙设备扫描、连接与断开
- 设备时间同步
- 开始录音、停止录音与录音状态查询
- 实时音频 PCM 数据回调
- 存储空间查询
- 录音文件数量和文件列表查询
- 录音文件删除、下载与 Ogg Opus 封装
- 按键与触摸行为配置
- 按键与触摸行为查询
- 软件模拟按键与触摸事件
- OTA 升级与取消

## 2. 环境要求

- iOS 16.0 或更高版本
- Swift 6.2 或更高版本
- 当前二进制依赖不包含模拟器架构，请使用真机运行

在应用的 `Info.plist` 中添加蓝牙权限说明：

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>应用需要使用蓝牙扫描并连接录音设备。</string>
```

部分厂商库使用了 Objective-C Category。请在应用 Target 的
`Build Settings > Other Linker Flags` 中添加：

```text
-ObjC
```

## 3. 通过 Swift Package Manager 集成

在 Xcode 中选择 `File > Add Package Dependencies`，添加：

```text
https://github.com/caitunai/JieLi-Recorder-iOS-Sdk.git
```

选择 `JieLiSdkRecorder` Product 并添加到应用 Target。

`JieLiSdkRecorder.xcframework` 是动态 Framework。

在需要使用 SDK 的 Swift 文件中导入：

```swift
import JieLiSdkRecorder
```

## 4. 创建 BLEManager

建议在业务层长期持有一个 `BLEManager` 实例，覆盖完整的蓝牙会话生命周期：

```swift
import JieLiSdkRecorder

final class RecorderService {
    let manager = BLEManager(configuration: .init())
}
```

## 5. 注册事件回调

实现 `BLECallback` 以接收扫描、连接、录音、文件、OTA 和错误事件。协议中的方法
均提供默认空实现，只需实现业务需要的回调。

```swift
final class RecorderCallbackProxy: BLECallback {
    func onDiscovery(_ device: BLEDevice) {
        print("发现设备：", device.name)
    }

    func onConnectionChange(_ device: BLEDevice, status: ConnectionCode) {
        print("连接状态：", device.name, status.getMessage())
    }

    func onError(_ device: BLEDevice, errorCode: BLEErrorCode) {
        print("SDK 错误：", device.name, errorCode.getMessage())
    }
}

let manager = BLEManager()
let callback = RecorderCallbackProxy()
manager.addCallback(callback)
```

不再需要回调对象时，应注销回调：

```swift
manager.removeCallback(callback)
```

## 6. 扫描和连接设备

开始扫描：

```swift
manager.startScan()
```

继续扫描或停止扫描：

```swift
manager.continueScan()
manager.stopScan()
```

连接与断开设备：

```swift
manager.connect(device)
manager.disconnect(device)
```

`BLEDevice.source` 表示设备所属协议栈，可能为 `.jieLi`、`.pnote` 或
`.huanGe`。应用应使用 JieLiSdkRecorder 的统一公开接口，不应直接调用内部厂商库。

## 7. 当前设备调用模式

SDK 推荐每次调用时直接传入 `BLEDevice`：

```swift
manager.startCustomRecord(device)
manager.queryStorageSize(device)
```

为兼容已有业务，也可以先选择当前设备，再调用无参数接口：

```swift
manager.selectConnectedDevice(at: 0)
manager.startCustomRecord()
manager.queryStorageSize()
```

多设备场景优先使用带 `BLEDevice` 参数的接口，避免操作到错误设备。

## 8. 时间同步

```swift
manager.syncTime(device)
```

通过回调接收同步结果：

```swift
func onTimeSynced(_ device: BLEDevice, success: Bool) {
    print("时间同步结果：", success)
}
```

## 9. 录音控制

开始、停止和查询录音状态：

```swift
manager.startCustomRecord(device)
manager.stopCustomRecord(device)
manager.queryRecordState(device)
```

处理录音状态：

```swift
func onRecordStart(_ device: BLEDevice, started: Bool) {
    print("开始录音：", started)
}

func onRecordStop(_ device: BLEDevice, stopped: Bool) {
    print("停止录音：", stopped)
}

func onRecordStateUpdate(_ device: BLEDevice, state: BLERecordState) {
    print("录音状态：", state.message)
}
```

## 10. 实时音频

实时音频回调输出 PCM 数据：

```swift
func onRealtimeAudioStarted() {
    // 初始化或清空本地 PCM 缓冲区。
}

func onRealtimeAudioReceived(audio: Data) {
    // 追加 PCM 数据。
}

func onRealtimeAudioStopped() {
    // 停止播放或完成本地音频文件。
}
```

PCM 格式：

- 采样率：`16 kHz`
- 采样格式：`Int16`
- 声道数：单声道

## 11. 查询存储空间

推荐传入目标设备：

```swift
manager.queryStorageSize(device)
```

已经选择当前设备时，也可以使用无参数接口：

```swift
manager.queryStorageSize()
```

查询结果通过 `BLECallback` 返回：

```swift
func onStorageSizeUpdate(
    _ device: BLEDevice,
    available: UInt64,
    total: UInt64
) {
    print("剩余字节数：", available)
    print("总字节数：", total)
}
```

- `available`：剩余存储空间，单位为字节
- `total`：总存储空间，单位为字节
- 两个容量值均为 `UInt64`，避免以字节表示大容量存储时发生整数溢出

展示容量时，可以在应用层转换单位：

```swift
let formatter = ByteCountFormatter()
formatter.countStyle = .file
let availableText = formatter.string(fromByteCount: Int64(available))
```

## 12. 查询录音文件

查询录音文件数量：

```swift
manager.queryRecordFiles(device)
```

```swift
func onRecordFilesCountUpdate(_ device: BLEDevice, fileCount: Int) {
    print("录音文件数量：", fileCount)
}
```

刷新文件列表和加载更多文件：

```swift
manager.retrieveFilesFromStart(device)
manager.retrieveFiles(device)
```

通过回调接收文件列表：

```swift
func onFilesRetrieved(_ files: [BLEFile]) {
    print(files.map(\.name))
}
```

## 13. 删除和下载文件

删除文件：

```swift
manager.deleteFiles(device, filenames: ["REC0001.OPUS", "REC0002.OPUS"])
```

下载文件：

```swift
manager.downloadFile(device, filename: "REC0001.OPUS")
```

文件操作进度和结果通过以下回调返回：

```swift
func onFileDeleteUpdate(_ device: BLEDevice, event: BLEFileDeleteEvent) {
    print("删除事件：", event)
}

@available(iOS 16.0, *)
func onFileDownloadUpdate(_ device: BLEDevice, event: BLEFileDownloadEvent) {
    print("下载事件：", event)
}
```

下载完成事件仅在原始 Opus 数据完成 Ogg 封装并写入磁盘后触发。

## 14. OTA 升级

读取固件数据并开始升级：

```swift
let firmwareData = try Data(contentsOf: firmwareURL)
manager.startOTA(device, firmwareData: firmwareData)
```

取消升级：

```swift
manager.cancelOTAUpgrade(device)
```

处理 OTA 事件：

```swift
func onOTAUpdate(_ device: BLEDevice, event: BLEOTAEvent) {
    print("OTA 事件：", event)
}

func onUpgradeUnfinished(_ device: BLEDevice) {
    print("检测到未完成升级：", device.name)
}
```

## 15. 按键与触控设置

SDK 使用 `BLEKeyTouchBehavior` 统一描述设备上的按键或触控行为。

```swift
let behavior = BLEKeyTouchBehavior(
    key: "key1",
    event: BLEKeyTouchBehavior.click,
    behavior: BLEKeyTouchBehavior.play
)
```

常用字段：

- `key`：按键或触控位置，例如 `key0`、`key1`、`key2`、`touch0`、`touch1`、`touch2`
- `event`：触发动作，例如 `click`、`db_click`、`long_press`
- `behavior`：设备功能，例如 `play`、`pause`、`record`、`stop_record`

### 15.1 设置按键与触控行为

```swift
manager.setKeyTouchBehaviorEvent(device, keyTouchBehavior: behavior)
```

设置结果通过以下回调返回：

```swift
func onKeyTouchBehaviorUpdate(
    _ device: BLEDevice,
    isSuccess: Bool,
    errorMessage: String
) {
    print("按键/触控设置结果：", isSuccess, errorMessage)
}
```

### 15.2 查询按键与触控行为

连接设备后，可以调用 `queryKeyTouchBehavior(_:)` 查询设备当前的按键或触控设置状态：

```swift
manager.queryKeyTouchBehavior(device)
```

如果已经通过 `selectConnectedDevice(at:)` 选择了当前设备，也可以调用无参数接口：

```swift
manager.queryKeyTouchBehavior()
```

查询结果通过 `BLECallback` 的 `onKeyTouchReceived(_:keyTouchBehavior:)` 返回：

```swift
func onKeyTouchReceived(_ device: BLEDevice, keyTouchBehavior: BLEKeyTouchBehavior) {
    let key = BLEKeyTouchBehavior.displayNameForKey(keyTouchBehavior.key)
    let event = BLEKeyTouchBehavior.displayNameForEvent(keyTouchBehavior.event)
    let behavior = BLEKeyTouchBehavior.displayNameForBehavior(keyTouchBehavior.behavior)
    print("当前按键/触控设置：", key, event, behavior)
}
```

一次查询可能返回多条配置，SDK 会逐条触发 `onKeyTouchReceived`。

对于 HuanGe 设备，SDK 会调用 HuanGeSdk 的 `getButtonConfiguration()`，并映射为两条逻辑配置：

- `record`：开始录音对应的手势
- `pause`：暂停录音对应的手势

HuanGe 设备按逻辑功能配置手势，不按物理 `key0` / `key1` 位置配置。回调中的 `key` 字段仅用于兼容统一的 `BLEKeyTouchBehavior` 数据模型。

### 15.3 软件模拟触发

```swift
manager.emitKeyTouchBehaviorEvent(device, keyTouchBehavior: behavior)
```

模拟触发结果通过以下回调返回：

```swift
func onKeyTouchEmitted(_ device: BLEDevice, isSuccess: Bool) {
    print("模拟触发结果：", isSuccess)
}
```

### 15.4 UI 展示辅助方法

如果需要在界面中展示中文名称，可以使用：

- `BLEKeyTouchBehavior.displayNameForKey(_:)`
- `BLEKeyTouchBehavior.displayNameForEvent(_:)`
- `BLEKeyTouchBehavior.displayNameForBehavior(_:)`

## 16. 错误处理

统一通过 `onError(_:errorCode:)` 接收 SDK 错误：

```swift
func onError(_ device: BLEDevice, errorCode: BLEErrorCode) {
    print("错误码：", errorCode.code)
    print("错误信息：", errorCode.getMessage())
}
```

查询存储空间失败时，错误码为：

```swift
BLEErrorCode.queryStorageSizeFailed
```

## 17. 推荐接入流程

1. 创建并长期持有 `BLEManager`。
2. 创建 `BLECallback` 实现并注册到 Manager。
3. 开始扫描，在 `onDiscovery(_:)` 中展示设备。
4. 连接用户选择的设备，并等待连接成功回调。
5. 按业务需要同步时间、控制录音、查询存储和管理文件。
6. 在页面或业务对象销毁时注销回调。
7. 不再使用设备时主动断开连接。

## 18. 常见问题

### 为什么模拟器无法运行？

当前发布包中的一个或多个二进制依赖不包含模拟器 Slice，请使用 iOS 真机测试。
