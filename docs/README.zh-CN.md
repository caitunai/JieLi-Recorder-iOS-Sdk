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
- 录音文件删除、Opus 转 Ogg 下载和原始文件下载
- 原始文件断点续传
- 按键与触摸行为配置
- 按键与触摸行为查询
- 软件模拟按键与触摸事件
- OTA 升级与取消
- 设备绑定、身份验证与解除绑定（仅 HuanGe）

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

    func onDeviceBindingStateChanged(_ device: BLEDevice, state: BLEDeviceBindingState) {
        print("设备绑定状态变化：", device.name, state.rawValue)
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

### 查询 BLE 外设电量

请使用包含此新增接口的 JieLiSdkRecorder 发布包。先连接设备；HuanGe 设备应先完成 `bindOrVerifyDevice(_:using:)`，再发起普通控制查询。

```swift
public func queryBattery(_ device: BLEDevice) async throws -> BLEBatteryState
```

```swift
do {
    switch try await manager.queryBattery(device) {
    case .percentage(let value):
        print("剩余电量：\(value)%")
    case .charging:
        print("正在充电，本次应答未提供百分比")
    }
} catch let error as BLEBatteryQueryError {
    print("电量查询失败：", error.localizedDescription)
}
```

| 设备通道 | 主动查询支持情况 |
| --- | --- |
| `.huanGe`，包括通过 HuanGe 通道连接的 PNote 产品 | 支持，调用底层 `getBatteryState()` |
| 原生 `.pnote` | 支持，调用底层 `getCBC()`；等待应答超过 10 秒报超时 |
| `.jieLi` | 暂不支持，抛出 `.unsupportedDeviceSource(.jieLi)` |

返回值来自设备应答，不是缓存的 `device.batteryPower`。`BLEBatteryState.percentage(UInt8)` 表示 0–100 的百分比；`.charging` 仅表示正在充电，不包含百分比。不要将充电解释为满电，也不要把旧缓存百分比当作本次测量结果。已有 `onBatteryChange(_:)` 回调继续通知电量变化并更新已发现设备快照；回调和异步返回的到达时间可能不同，更新 UI 时请切换到 `MainActor`。

失败时抛出 `BLEBatteryQueryError`，同时通过 `onError(_:errorCode:)` 通知：

- `.unsupportedDeviceSource(source)`：不支持此通道；回调 `.batteryQueryUnsupported`（1016）。
- `.notConnected`：当前与指定设备没有有效连接，旧设备快照中的“已连接”状态不能替代实际连接。
- `.disconnected`：查询完成前连接断开。
- `.requestFailed(message)`：超时、无效应答或其它请求错误；原生 PNote 查询进行中时拒绝第二次查询。

后三种错误使用回调 `.queryBatteryFailed`（1017），并附带详情。失败时不会伪造 0% 返回。Demo 已提供“查询设备电量”按钮，分别展示百分比、仅充电状态或错误信息；在 JieLi 设备上调用可验证不支持错误。

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

SDK 提供两种相互独立的下载模式，JieLi、PNote 和 HuanGe 设备使用相同的公开接口：

- `downloadFile`：接收设备的 raw Opus 数据并封装为 Ogg 文件，不支持断点续传。
- `downloadRawFile`：不进行 Opus 解码或 Ogg 转换，直接把接收到的源文件字节写入磁盘，支持断点续传，也可用于普通非音频文件。

### 13.1 下载 Opus 并转为 Ogg

建议为输出文件使用 `.ogg` 扩展名：

```swift
let outputURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("record_001.ogg")

manager.downloadFile(
    device,
    filename: "REC0001.OPUS",
    outputURL: outputURL
)
```

`downloadFile` 的最终文件内容是 Ogg 封装的 Opus。此模式必须从偏移量 `0` 开始，传入非零
`resumeFromOffset` 会返回下载错误。使用默认缓存路径时可调用：

```swift
manager.downloadFile(device, filename: "REC0001.OPUS")
```

默认缓存目录为 `Caches/jieli_sdk_download/<filename>`。

#### HuanGe 的 Opus → Ogg 下载

使用 HuanGe SDK 1.0.7 或更高版本时，`.huanGe` 设备的 `downloadFile` 自动以零偏移调用 `importFileAllowingPacketLoss(_:resumeFromOffset:)`，不受 `integrityMode` 参数影响，应用侧无需修改调用方式。该模式从零开始，仅在设备报告成功完成后接受实际接收字节数不足。封装层等待实际 `completion.byteCount` 全部写入后再关闭 Ogg 转换器，不再等待原文件大小。仅因字节数不足不会触发下载错误；SDK 日志记录预期、接收和缺失字节数。

底层 chunk 的 offset 表示紧凑接收数据中的连续位置，封装层仍检查本地数据流是否缺段。此模式不跳过 CRC、不补齐缺失数据、不修复 Opus 帧，也不自动重传。音频可能不完整或无法转换。空音频、超量数据、设备拒绝、取消、断连、超时、本地流/写盘错误及转换失败仍按原有逻辑处理。`.finish` 表示设备完成容错传输且 Ogg 写入器正常关闭，不代表源音频完整；进度可能在低于 100% 时直接进入 `.finish` 的 100%。`bytesCount` 表示实际收到的 Opus 字节数，不是原文件大小或 Ogg 输出大小。

`downloadRawFile` 和原始文件断点续传默认使用严格的 `importFile(_:resumeFromOffset:)`；HuanGe 可显式选择下述容错续传模式。Demo 对 HuanGe Ogg 下载明确显示“容忍丢包模式”，并禁用该设备通道的通用校验模式选择器。请在目标硬件上验证丢包音频的转换和播放效果。

### 13.2 下载原始文件

#### HuanGe 原始文件可选容错续传（SDK 1.0.7）

新增 `downloadRawFile` 重载可显式传入 `integrityMode`；旧方法签名保留，继续使用 `.strict`。已有与设备文件匹配的原始 Opus 前缀时，可按如下方式容错续传：

```swift
manager.downloadRawFile(
    device,
    filename: "REC0001.OPUS",
    outputURL: rawOutputURL,
    integrityMode: .allowPacketLossForOpusStream,
    resumeFromOffset: verifiedDeviceOffset
)
```

`rawOutputURL` 为本地原始文件 URL，`verifiedDeviceOffset` 为已独立确认与本地前缀匹配的 `UInt32` 设备文件字节偏移。仅 `.huanGe` 支持此模式；其它通道会报告下载错误。本地文件必须至少包含指定前缀，写入器先截断到该偏移，再追加本次数据；偏移为零会覆盖目标文件。

首个新数据块从请求偏移开始。`completion.byteCount` 和下载回调 `bytesCount` 均包含已有前缀加本次接收量。收到设备成功应答后，封装层等待这个累计字节数，不再要求达到原文件大小；若设备成功结束但本次没有新数据，可以仅保留已验证的非空前缀作为结果。超时、断连、设备拒绝、写盘错误和超量数据仍会失败。

**不能用之前已丢包文件的本地长度推导设备 offset。** SDK 不知道丢失位置，也不会验证前缀。Demo 对非零容错续传要求手动输入 offset 并确认前缀一致，容错结果使用独立 `.lossy` 后缀保存；仅默认严格原始下载继续按文件长度自动续传。Opus → Ogg 仍从零开始，不支持按 Opus 字节偏移追加已有 Ogg 文件。


需要保存设备返回的原始文件字节时，使用 `downloadRawFile`：

```swift
let rawOutputURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("REC0001.OPUS")

manager.downloadRawFile(
    device,
    filename: "REC0001.OPUS",
    outputURL: rawOutputURL
)
```

该模式不会解码 Opus，也不会创建 Ogg 容器，输出内容与接收到的源文件流一致。

### 13.3 原始文件断点续传

`resumeFromOffset` 表示源文件的绝对字节偏移量。本地目标文件必须至少包含该偏移量指定的
字节数。通常可读取本地部分文件的大小作为续传偏移量：

```swift
let existingBytes: UInt64
if FileManager.default.fileExists(atPath: rawOutputURL.path) {
    let attributes = try FileManager.default.attributesOfItem(atPath: rawOutputURL.path)
    existingBytes = (attributes[.size] as? NSNumber)?.uint64Value ?? 0
} else {
    existingBytes = 0
}

guard existingBytes <= UInt64(UInt32.max) else {
    throw CocoaError(.fileReadTooLarge)
}
let resumeOffset = UInt32(existingBytes)

manager.downloadRawFile(
    device,
    filename: "REC0001.OPUS",
    outputURL: rawOutputURL,
    resumeFromOffset: resumeOffset
)
```

断点续传规则：

- 传入 `0` 会覆盖现有目标文件并从头下载。
- SDK 保留 `resumeFromOffset` 之前的文件内容，并截断其后的旧数据，再追加新接收的数据。
- 偏移量超过本地文件大小或设备端源文件大小时，会返回 `.error` 事件。
- 本地文件已经完整时，SDK 会直接在本地完成，不会再次启动 BLE 文件传输。
- 原始文件下载被取消或因传输错误中断时，会保留部分文件；再次调用时可使用其文件大小续传。

不指定 `outputURL` 时，文件写入默认缓存目录：

```swift
manager.downloadRawFile(
    device,
    filename: "REC0001.OPUS",
    resumeFromOffset: resumeOffset
)
```

使用默认路径重载进行续传时，应从该缓存目录中的目标文件计算 `resumeOffset`，而不是使用
`rawOutputURL` 的文件大小。

如果业务已经通过兼容模式选择了当前设备，也可以使用不带 `device` 参数的重载：

```swift
manager.downloadRawFile("REC0001.OPUS", outputURL: rawOutputURL, resumeFromOffset: resumeOffset)
manager.downloadRawFile("REC0001.OPUS", resumeFromOffset: resumeOffset)
```

### 13.4 下载进度与结果

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

`BLEFileDownloadEvent` 中常用字段：

- `progress`：下载进度百分比。
- `bytesCount`：已经写入的源文件总字节数；断点续传时包含本地已保留的前缀。
- `packages`：本次会话接收的数据包数量。
- `duration`：本次下载经过的时间。
- `path`：最终文件、下载中的文件或可续传部分文件的路径。
- `errorCode`、`errorMsg`：下载失败信息。

对于 `downloadFile`，`.finish` 仅在 raw Opus 数据完成 Ogg 封装并写入磁盘后触发；对于
`downloadRawFile`，`.finish` 仅在原始文件刷新并关闭后触发。

### 13.5 取消下载

以下方法可取消 JieLi、PNote 或 HuanGe 设备当前正在进行的文件下载：

```swift
manager.cancelDownloadFile(device)
```

原始文件模式取消后会关闭并保留部分文件，可根据回调中的 `event.path` 和本地文件大小继续
断点续传。Opus 转 Ogg 模式取消后会移除未完成的转换结果。

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

## 16. 设备绑定、身份验证与解除绑定（仅 HuanGe）

SDK 支持 HuanGe 设备的绑定和身份验证功能。通过此功能，可以使用 16 字节密钥将设备与应用绑定，后续通过同一密钥验证设备身份。

**重要说明**：这些接口支持 `BLEDeviceSource.huanGe`，包括通过 HuanGe 通道连接的 PNote 产品。`.jieLi` 和原生 `.pnote` 通道的设备不支持，会抛出 `BLEDeviceBindingError.unsupportedDeviceSource`。支持范围以 `device.source` 为准，不按设备广播名称判断。

每次 HuanGe 设备连接就绪后，应先使用已保存的 Key 调用 `bindOrVerifyDevice(_:using:)`，再发送普通控制请求。SDK 的自动电量、固件查询已移到绑定或验证成功后执行，避免普通查询排在身份验证之前。

若重开 App 后验证失败，请区分 `.notConnected`（当前未连接）、`.disconnected`（操作期间断连）和 `.bindingVerificationFailed`（身份验证被拒绝）。连接错误本身不能证明 Key 错误。Demo 会显示设备 ID、Key 的 SHA-256 指纹及失败耗时，可对比重启前后的 ID 和指纹，无需提供 Key 原文。已绑定设备缺少本地 Key 时，Demo 会拒绝生成替代 Key；长度异常的 Key 文件也会保留并报错。为兼容已有测试 Key，Demo 仍沿用原缓存路径；正式应用应使用 Keychain 持久、安全地保存 Key。

### 16.1 生成绑定密钥

绑定密钥必须为 16 字节。使用 `SecRandomCopyBytes` 生成安全的随机密钥：

```swift
import Security

func generateBindingKey() -> Data? {
    var key = Data(count: 16)
    let result = key.withUnsafeMutableBytes { bytes in
        SecRandomCopyBytes(kSecRandomDefault, 16, bytes.bindMemory(to: UInt8.self).baseAddress!)
    }
    return result == errSecSuccess ? key : nil
}
```

### 16.2 查询设备绑定状态

检查设备是否已绑定：

```swift
let state = try await manager.getDeviceBindingState(device)
// 返回值: .unbound（未绑定）或 .bound（已绑定）
```

`BLEDeviceBindingState` 的可能值：

- `.unbound`：设备未绑定
- `.bound`：设备已绑定

回调方法：

```swift
func onDeviceBindingStateChanged(_ device: BLEDevice, state: BLEDeviceBindingState)
```

### 16.3 绑定或验证设备

首次绑定设备，或验证已绑定设备：

```swift
let result = try await manager.bindOrVerifyDevice(device, using: key)
// 返回值: .bound（首次绑定成功）或 .verified（身份验证成功）
```

`BLEDeviceBindingResult` 的可能值：

- `.bound`：设备首次绑定成功
- `.verified`：设备身份验证成功

### 16.4 仅验证设备绑定

仅验证已绑定设备，不尝试绑定：

```swift
try await manager.verifyDeviceBinding(device, using: key)
```

如果设备未绑定或密钥不正确，会抛出错误。

### 16.5 密钥存储最佳实践

绑定密钥必须由应用安全存储。推荐存储位置：

- **Keychain**：生产环境最安全的选择
- **应用沙盒目录**：适合开发/Demo 环境（如 `NSTemporaryDirectory` 或 `FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)`）

**重要提示**：永远不要硬编码密钥或存储在 UserDefaults 中。如果密钥丢失，将无法验证设备身份。

### 16.6 错误处理

设备绑定错误通过 `BLEDeviceBindingError` 返回：

- `.unsupportedDeviceSource(BLEDeviceSource)`：设备通道不支持（`.jieLi` 或原生 `.pnote`）
- `.invalidBindingKeyLength`：提供的密钥不是 16 字节
- `.deviceNotBound`：尝试验证未绑定的设备
- `.bindingKeyRejected`：设备拒绝绑定密钥
- `.bindingVerificationFailed`：设备绑定身份验证失败
- `.deviceUnbindingFailed`：设备明确拒绝解除绑定
- `.notConnected`：当前与指定设备没有有效连接
- `.disconnected`：绑定操作完成前连接断开
- `.systemError(String)`：其他系统级错误

### 16.7 完整绑定流程示例

```swift
import Foundation
import JieLiSdkRecorder
import Security

final class DeviceBindingManager {
    private let manager = BLEManager()
    private var bindingKeys: [String: Data] = [:]

    /// 生成安全的 16 字节绑定密钥
    func generateBindingKey() -> Data? {
        var key = Data(count: 16)
        let result = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 16, bytes.bindMemory(to: UInt8.self).baseAddress!)
        }
        return result == errSecSuccess ? key : nil
    }

    /// 检查设备是否已绑定
    func checkBindingState(for device: BLEDevice) async throws -> BLEDeviceBindingState {
        return try await manager.getDeviceBindingState(device)
    }

    /// 绑定或验证设备
    func bindOrVerify(_ device: BLEDevice) async throws -> BLEDeviceBindingResult {
        // 获取或生成绑定密钥
        let key: Data
        if let existingKey = bindingKeys[device.id] {
            key = existingKey
        } else {
            guard let newKey = generateBindingKey() else {
                throw BLEDeviceBindingError.systemError("Failed to generate binding key")
            }
            bindingKeys[device.id] = newKey
            key = newKey
        }

        let result = try await manager.bindOrVerifyDevice(device, using: key)

        // 绑定成功后持久化存储密钥（如 Keychain）
        if result == .bound {
            saveBindingKey(key, for: device.id)
        }

        return result
    }

    /// 使用已有密钥验证设备
    func verifyDevice(_ device: BLEDevice) async throws {
        guard let key = bindingKeys[device.id] else {
            throw BLEDeviceBindingError.systemError("No binding key found for device")
        }
        try await manager.verifyDeviceBinding(device, using: key)
    }

    private func saveBindingKey(_ key: Data, for deviceId: String) {
        // 生产环境实现 Keychain 存储
        // 此处为简化示例
    }
}
```

### 16.8 解除 BLE 外设绑定

**接口可用性**：这是新增的待发布接口。需要使用已公开 `unbindDevice(_:)` 且集成 HuanGe SDK 1.0.4 或更高版本的 JieLiSdkRecorder 二进制发布包；更新文档不会让旧版二进制自动获得此方法。最低 JieLiSdkRecorder 发布版本号将在发布时补充。设备固件须支持 HuanGe 解除绑定指令 20/21。

```swift
public func unbindDevice(_ device: BLEDevice) async throws
```

- **参数**：当前已连接且 `source == .huanGe` 的 `BLEDevice`，包括通过该通道连接的 PNote 产品。旧设备快照中的“已连接”状态不能替代与该设备的实际连接。
- **返回值**：`Void`，仅在收到外设明确的解绑成功应答后正常返回。应用无需传入 Key、NONCE、HMAC 或自行组包。
- **错误**：抛出 `BLEDeviceBindingError`，同时通过 `onError(_:errorCode:)` 报告错误。

连接就绪并由用户确认操作后，在异步上下文中调用：

```swift
do {
    try await manager.unbindDevice(device)
    print("设备解除绑定成功")
    // 仅在此时按应用策略保留或删除本地保存的 Key。
} catch BLEDeviceBindingError.unsupportedDeviceSource(let source) {
    print("当前通道不支持解除绑定：", source.rawValue)
} catch BLEDeviceBindingError.deviceUnbindingFailed {
    print("设备拒绝解除绑定，请保留已保存的 Key")
} catch BLEDeviceBindingError.notConnected {
    print("设备当前未连接，请保留 Key")
} catch BLEDeviceBindingError.disconnected {
    print("确认前连接断开，请保留 Key")
} catch {
    print("尚未确认解除绑定成功：", error.localizedDescription)
    // 保留 Key；连接就绪后重新查询绑定状态。
}
```

成功时还会通过已有的 `BLECallback` 通知绑定状态：

```swift
func onDeviceBindingStateChanged(_ device: BLEDevice, state: BLEDeviceBindingState) {
    if state == .unbound {
        print("设备当前未绑定：", device.name)
    }
}
```

更新 UI 时请切换到 `MainActor`。异步返回和状态回调可能报告同一次成功操作，业务侧应避免重复执行删除 Key 等操作。

| 场景 | 抛出的错误 | `onError` 错误码 |
| --- | --- | --- |
| `.jieLi` 或原生 `.pnote` 通道 | `.unsupportedDeviceSource(source)` | `.deviceBindingUnsupported`（1010） |
| 设备拒绝解绑请求 | `.deviceUnbindingFailed` | `.deviceUnbindingFailed`（1015） |
| 与指定设备无有效连接 | `.notConnected` | `.systemError`（1），附带详情 |
| 成功确认前断连 | `.disconnected` | `.systemError`（1），附带详情 |
| 超时、无效应答或其它底层错误 | `.systemError(message)` | `.systemError`（1），附带详情 |

发送请求不代表解绑成功。失败或结果未知时，应保留已保存的 Key，在连接就绪后调用 `getDeviceBindingState(_:)` 核对状态。此接口不会自动执行身份验证、重新绑定、主动断开连接或删除应用保存的 Key。确认成功后，由应用决定是否保留 Key；需要再次绑定时，显式调用 `bindOrVerifyDevice(_:using:)`。

Demo 的设备绑定区域提供解绑按钮和确认弹窗，解绑过程中禁止重复请求，并保留缓存的测试 Key 供再次绑定使用。按钮仅对已连接的 `.huanGe` 设备开放。请在目标硬件上验证成功、设备拒绝、超时/断连和再次绑定场景。

## 17. 错误处理

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

## 18. 推荐接入流程

1. 创建并长期持有 `BLEManager`。
2. 创建 `BLECallback` 实现并注册到 Manager。
3. 开始扫描，在 `onDiscovery(_:)` 中展示设备。
4. 连接用户选择的设备，并等待连接成功回调。
5. 按业务需要同步时间、控制录音、查询存储和管理文件。
6. 在页面或业务对象销毁时注销回调。
7. 不再使用设备时主动断开连接。

## 19. 常见问题

### 为什么模拟器无法运行？

当前发布包中的一个或多个二进制依赖不包含模拟器 Slice，请使用 iOS 真机测试。
