# JieLiSdkRecorder User Guide

[中文文档](docs/README.zh-CN.md)

- Bluetooth scanning
- Device connection and disconnection
- Time synchronization
- Recording start, stop, and status query
- Realtime audio stream callback with PCM output
- Storage capacity query
- Recording file count query
- Recording file list retrieval
- Recording file deletion
- Recording file download and conversion to an Ogg-wrapped Opus file
- Key / touch behavior configuration
- Software-triggered key / touch event simulation
- OTA upgrade and cancellation

## 1. Important Xcode Setup

Before using any `JL****.xcframework` in your app, make sure the following Xcode integration steps are completed.

### 1.1 Add the Swift Package

Add the following package URL in Xcode and select the `JieLiSdkRecorder`
product:

```text
https://github.com/caitunai/JieLi-Recorder-iOS-Sdk.git
```

The distributed `JieLiSdkRecorder.xcframework` is a dynamic framework.
The package provides and embeds the required dynamic JieLi and JLAudioUnitKit frameworks.

### 1.2 Framework Embedding

Swift Package Manager configures the required dynamic frameworks for the
application target. Do not manually add duplicate copies of any framework
already provided by the package.

### 1.3 Configure `Other Linker Flags`

This SDK depends on Objective-C categories / extension-based members inside bundled libraries. Because of that, you must add the following linker flag in your app target:

- Open `Build Settings`
- Find `Other Linker Flags`
- Add `-ObjC`

If `-ObjC` is missing, category-based methods or properties from bundled Objective-C libraries may not be linked correctly at runtime.

## 2. Integration Requirements

- Swift 6.2 or later. The package manifest currently uses Swift tools 6.3.
- Import the SDK module in files that use it:

```swift
import JieLiSdkRecorder
```

- Declare Bluetooth permission in `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>The app needs Bluetooth to scan and connect JieLi devices.</string>
```

## 3. Notes Before Use

- `BLEManager.startScan()` clears the current discovered device list and starts a new scan.
- The SDK includes an internal auto-stop scan policy. If you need to keep scanning, call `continueScan()`.
- The downloaded file content is `Ogg-wrapped Opus data`, not the original raw stream stored on the device.
- `onFileDownloadUpdate(_:event:)` is available only on iOS 16.0 and later.
- Business events are mainly delivered through `BLECallback`.
- The SDK supports two calling styles:
  - Recommended: pass a `BLEDevice` directly each time
  - Compatibility mode: select the current device first, then call the parameterless APIs
- `BLEDevice.source` identifies the owning BLE stack: `.jieLi`, `.pnote`, or `.huanGe`.
- HuanGe devices use the same public scan, connection, recording, storage, file, and OTA APIs.

## 4. Core Types

### 4.1 `BLEManager`

`BLEManager` is the main entry point of the SDK and is responsible for:

- Bluetooth scanning
- Connection management
- Business command dispatch
- File operations
- OTA control
- Event callback dispatching

### 4.2 `BLEDevice`

`BLEDevice` represents a discovered device. Common fields include:

- `id`: unique device identifier
- `name`: device name
- `mac`: device MAC address
- `batteryPower`: current battery percentage
- `charging`: whether the device is charging
- `isChargedFull`: whether the battery is fully charged
- `version`: firmware version code
- `versionName`: firmware version name
- `connectionStatus`: current connection status
- `isConnected`: whether the device is currently connected

### 4.3 `BLECallback`

Implement `BLECallback` to receive scan, connection, recording, file, OTA, and error callbacks. The protocol provides default empty implementations for all methods, so you only need to implement the callbacks your app actually uses.

Common callbacks include:

- `onDiscovery(_:)`
- `onScanStopped()`
- `onConnectionChange(_:status:)`
- `onBatteryChange(_:)`
- `onTimeSynced(_:success:)`
- `onFilesRetrieved(_:)`
- `onFileDeleteUpdate(_:event:)`
- `onFileDownloadUpdate(_:event:)`
- `onRecordStart(_:started:)`
- `onRecordStop(_:stopped:)`
- `onRecordStateUpdate(_:state:)`
- `onRealtimeAudioStarted()`
- `onRealtimeAudioReceived(audio:)`
- `onRealtimeAudioStopped()`
- `onStorageSizeUpdate(_:available:total:)`
- `onRecordFilesCountUpdate(_:fileCount:)`
- `onKeyTouchBehaviorUpdate(_:isSuccess:errorMessage:)`
- `onKeyTouchEmitted(_:isSuccess:)`
- `onOTAUpdate(_:event:)`
- `onUpgradeUnfinished(_:)`
- `onError(_:errorCode:)`

## 5. Initialize `BLEManager`

It is recommended to create and retain a long-lived `BLEManager` instance in your business layer throughout the entire Bluetooth session lifecycle.

```swift
import JieLiSdkRecorder

final class RecorderService {
    let manager = BLEManager(
        configuration: .init()
    )
}
```

## 6. Register Callbacks

The SDK provides the following way to receive scan discovery events:

- Register a `BLECallback`

For complete business scenarios, it is recommended to standardize on `BLECallback`.

```swift
import JieLiSdkRecorder

final class RecorderCallbackProxy: BLECallback {
    var onDevice: ((BLEDevice) -> Void)?
    var onConnection: ((BLEDevice, ConnectionCode) -> Void)?

    func onDiscovery(_ device: BLEDevice) {
        onDevice?(device)
    }

    func onConnectionChange(_ device: BLEDevice, status: ConnectionCode) {
        onConnection?(device, status)
    }

    func onError(_ device: BLEDevice, errorCode: BLEErrorCode) {
        print("SDK error:", device.name, errorCode.getMessage())
    }
}

let manager = BLEManager()
let callback = RecorderCallbackProxy()
manager.addCallback(callback)
```

Remove the callback when it is no longer needed:

```swift
manager.removeCallback(callback)
```

## 7. Scan Devices

### 7.1 Start Scanning

```swift
manager.startScan()
```

When a device is discovered, the SDK returns it through:

```swift
func onDiscovery(_ device: BLEDevice)
```

Recommended app-layer handling:

- Clear the current device list before starting a new scan
- De-duplicate or update devices by `device.id`
- Display `name`, `mac`, `batteryPower`, `versionName`, and `connectionStatus` in the UI

### 7.2 Continue Scanning

If scanning was automatically stopped by the SDK, or manually stopped by the app and needs to continue:

```swift
manager.continueScan()
```

### 7.3 Stop Scanning

```swift
manager.stopScan()
```

When scanning ends, the SDK calls:

```swift
func onScanStopped()
```

## 8. Connect and Disconnect

### 8.1 Connect to a Device

It is recommended to pass a `BLEDevice` directly:

```swift
manager.connect(device) { status in
    print("Connection status:", status.getMessage())
}
```

Connection state changes are also returned through:

```swift
func onConnectionChange(_ device: BLEDevice, status: ConnectionCode)
```

Possible values for `ConnectionCode`:

- `.disconnected`
- `.connected`
- `.failed`
- `.connecting`
- `.systemError`

### 8.2 Disconnect a Device

```swift
manager.disconnect(device) { status in
    print("Disconnection status:", status.getMessage())
}
```

## 9. Current Device Mode

Most SDK capabilities provide two API styles:

- A version that accepts `BLEDevice` directly
- A version that operates on the "current device" without passing a device parameter

For example:

- `syncTime(_ device: BLEDevice, ...)`
- `syncTime(entity: JL_EntityM?, ...)`
- `startCustomRecord(_ device: BLEDevice)`
- `startCustomRecord()`

For app-layer integration, it is recommended to always use the `BLEDevice` overloads because they are the most direct and least error-prone.

If you do want to switch to "current device mode", a safer approach is:

```swift
manager.selectConnectedDevice(at: 0)
manager.startCustomRecord()
manager.queryRecordState()
```

This mode is suitable for scenarios such as:

- The current page operates on only one connected device
- The order of the connected device list is already known
- You want to make multiple subsequent calls through the parameterless APIs

Related helper APIs:

- `selectConnectedDevice(at:)`
- `clearCurrentDevice()`
- `currentBLEUUID`
- `currentEntity`
- `currentCommandManager`

## 10. Time Synchronization

Use the current system time to synchronize the device:

```swift
manager.syncTime(device) { success in
    print("Time sync result:", success)
}
```

You can also pass a specific time:

```swift
manager.syncTime(device, date: customDate) { success in
    print(success)
}
```

Callback:

```swift
func onTimeSynced(_ device: BLEDevice, success: Bool)
```

## 11. Recording Features

### 11.1 Start Recording

```swift
manager.startCustomRecord(device)
```

Callback:

```swift
func onRecordStart(_ device: BLEDevice, started: Bool)
```

### 11.2 Stop Recording

```swift
manager.stopCustomRecord(device)
```

Callback:

```swift
func onRecordStop(_ device: BLEDevice, stopped: Bool)
```

### 11.3 Query Recording Status

```swift
manager.queryRecordState(device)
```

Callback:

```swift
func onRecordStateUpdate(_ device: BLEDevice, state: BLERecordState)
```

`BLERecordState` includes:

- `.idle`
- `.recording`

### 11.4 Realtime Audio Stream

The device can also report a realtime audio stream while recording. The SDK converts the incoming non-standard Opus stream into PCM data and returns it through `BLECallback`.

Realtime audio callbacks:

```swift
/// Called when the SDK starts converting the realtime non-std Opus stream into an PCM stream.
func onRealtimeAudioStarted()

/// Called when one chunk of realtime audio is available.
/// The returned data is PCM audio generated from the incoming non std-Opus stream.
/// PCM sampleRate: 16Khz, int16, Mono
func onRealtimeAudioReceived(audio: Data)

/// Called when the realtime audio stream stops.
func onRealtimeAudioStopped()
```

PCM format details:

- Sample rate: `16 kHz`
- Sample format: `Int16`
- Channel count: `Mono`

Recommended app-layer handling:

- Start or reset your local PCM buffer in `onRealtimeAudioStarted()`
- Append each incoming PCM chunk in `onRealtimeAudioReceived(audio:)`
- Stop playback, finalize the local file, or trigger sharing in `onRealtimeAudioStopped()`
- If you need file playback outside the app, save the stream using a PCM-compatible container such as `.wav`

### 11.5 Query Storage Capacity

Recommended device-based API:

```swift
manager.queryStorageSize(device)
```

When the app has already selected a current device, the compatibility API is
also available:

```swift
manager.queryStorageSize()
```

Callback:

```swift
func onStorageSizeUpdate(_ device: BLEDevice, available: UInt64, total: UInt64)
```

Where:

- `available`: remaining capacity in bytes, represented as `UInt64`
- `total`: total capacity in bytes, represented as `UInt64`

Storage values use `UInt64` because device capacities expressed in bytes may
exceed the range of a 32-bit integer. Convert the values only when required by
the app's presentation layer.

### 11.6 Query Recording File Count

```swift
manager.queryRecordFiles(device)
```

Callback:

```swift
func onRecordFilesCountUpdate(_ device: BLEDevice, fileCount: Int)
```

## 12. Retrieve File List

The current SDK retrieves recording files from the device recording directory `OPUS_REC`.

### 12.1 Set the Maximum Retrieval Count

If needed, you can set the maximum number of files before retrieval:

```swift
manager.setMaxRetrieveFilesCount(100)
```

The SDK uses internal pagination. Each "load more" call retrieves the next page.

### 12.2 Refresh the File List from the Beginning

Use this when entering the file page for the first time or when performing pull-to-refresh:

```swift
manager.retrieveFilesFromStart(device)
```

### 12.3 Load More Files

```swift
manager.retrieveFiles(device)
```

### 12.4 File List Callback

```swift
func onFilesRetrieved(_ files: [BLEFile])
```

Current primary field in `BLEFile`:

- `name`

Recommended UI-layer handling:

- Reset the list when calling `retrieveFilesFromStart`
- Replace the local file list after the callback returns
- Call `retrieveFiles` to continue pagination
- Use `BLEFile.name` as the unique key for file selection state

## 13. Delete Files

Delete one or more recording files by name:

```swift
manager.deleteFiles(device, filenames: ["REC0001.OPUS", "REC0002.OPUS"])
```

Callback:

```swift
func onFileDeleteUpdate(_ device: BLEDevice, event: BLEFileDeleteEvent)
```

Possible values for `BLEFileDeleteEvent.Event`:

- `.success`
- `.error`
- `.finish`

Recommended handling:

- On `.success`, remove the file from both the selected list and the local file list
- On `.error`, display the failure reason for that specific file
- On `.finish`, end the deleting UI state and summarize the success and failure counts

## 14. Download Files

The SDK downloads recording files from the device and writes them locally as `Ogg-wrapped Opus files`.

### 14.1 Download to a Custom Path

It is recommended that the app layer explicitly provides the output path:

```swift
let outputURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("record_001.opus")

manager.downloadFile(device, filename: "REC0001.OPUS", outputURL: outputURL)
```

Notes:

- The final saved content is Ogg-wrapped Opus
- The file extension can still be `.opus`
- In the Demo, the output file is shared directly after a successful download

### 14.2 Download to the Default Cache Path

```swift
manager.downloadFile(device, filename: "REC0001.OPUS")
```

Default cache directory:

- `Caches/jieli_sdk_download/<filename>`

### 14.3 Download Callback

```swift
@available(iOS 16.0, *)
func onFileDownloadUpdate(_ device: BLEDevice, event: BLEFileDownloadEvent)
```

Possible values for `BLEFileDownloadEvent.Event`:

- `.begin`
- `.progress`
- `.finish`
- `.cancel`
- `.error`

Common fields in `BLEFileDownloadEvent`:

- `file`: file name on the device
- `progress`: download progress percentage
- `packages`: number of received data packets
- `duration`: elapsed time
- `bytesCount`: number of received raw Opus bytes
- `path`: output file path
- `errorCode`
- `errorMsg`

Recommended handling:

- `.begin`: reset the download progress and statistics
- `.progress`: update the progress bar, byte count, packet count, and duration
- `.finish`: use `event.path` for playback, sharing, or export
- `.error`: prioritize displaying `event.errorMsg`

## 15. Key / Touch Configuration

The SDK supports configuring key / touch behavior on the device and also supports software-triggering the corresponding event.

### 15.1 Build the Behavior Model

```swift
let behavior = BLEKeyTouchBehavior(
    key: "key1",
    event: BLEKeyTouchBehavior.click,
    behavior: BLEKeyTouchBehavior.play
)
```

Supported key / touch values:

- `key0`
- `key1`
- `key2`
- `touch0`
- `touch1`
- `touch2`

Supported event values:

- `click`
- `db_click`
- `long_press`
- `swipe_left`
- `swipe_right`
- `swipe_up`
- `swipe_down`

Supported behavior values include:

- `no_action`
- `open`
- `close`
- `previous`
- `next`
- `play`
- `pause`
- `answer_call`
- `hang_up_call`
- `call_back`
- `volume_up`
- `volume_down`
- `take_photo`
- `record`
- `stop_record`
- `anc_change_list`

### 15.2 Set Key / Touch Behavior

```swift
manager.setKeyTouchBehaviorEvent(device, keyTouchBehavior: behavior)
```

Callback:

```swift
func onKeyTouchBehaviorUpdate(_ device: BLEDevice, isSuccess: Bool, errorMessage: String)
```

### 15.3 Simulate a Key / Touch Trigger

```swift
manager.emitKeyTouchBehaviorEvent(device, keyTouchBehavior: behavior)
```

Callback:

```swift
func onKeyTouchEmitted(_ device: BLEDevice, isSuccess: Bool)
```

### 15.4 Display Text Helper Methods

If you need Chinese display names in the UI, you can directly use:

- `BLEKeyTouchBehavior.displayNameForKey(_:)`
- `BLEKeyTouchBehavior.displayNameForEvent(_:)`
- `BLEKeyTouchBehavior.displayNameForBehavior(_:)`

## 16. OTA Upgrade

The OTA API requires the app layer to provide the firmware data.

### 16.1 Read the Firmware File

```swift
let firmwareURL: URL = ...
let firmwareData = try Data(contentsOf: firmwareURL)
```

### 16.2 Start OTA

```swift
manager.startOTA(device, firmwareData: firmwareData)
```

### 16.4 OTA Callbacks

```swift
func onOTAUpdate(_ device: BLEDevice, event: BLEOTAEvent)
func onUpgradeUnfinished(_ device: BLEDevice)
```

Possible values for `BLEOTAEvent.Event`:

- `.start`
- `.preparing`
- `.prepared`
- `.progress`
- `.reconnect`
- `.reboot`
- `.finish`
- `.cancel`
- `.error`

Common fields in `BLEOTAEvent`:

- `progress`
- `resultCode`
- `errorCode`
- `errorMsg`

It is recommended that the OTA UI covers at least these states:

- Upgrade file selected
- File verification in progress
- Upgrade in progress
- Device reconnecting
- Device rebooting
- Upgrade successful
- Upgrade canceled
- Upgrade failed

If `onUpgradeUnfinished(_:)` is received, it means the device reports an unfinished upgrade task. The app layer can notify the user and continue the OTA flow again if needed.

## 17. Error Handling

General business errors are returned through:

```swift
func onError(_ device: BLEDevice, errorCode: BLEErrorCode)
```

Common error constants:

- `BLEErrorCode.success`
- `BLEErrorCode.systemError`
- `BLEErrorCode.recordStartError`
- `BLEErrorCode.recordStopError`
- `BLEErrorCode.queryRecordStateError`
- `BLEErrorCode.queryStorageSizeFailed`
- `BLEErrorCode.countRecorderFilesFailed`
- `BLEErrorCode.emitSoftDeviceEventFailed`
- `BLEErrorCode.opusToOggFailed`
- `BLEErrorCode.keyTouchBehaviorUpdateFailed`
- `BLEErrorCode.fileDownloadFailed`

Common methods:

- `errorCode.getCode()`
- `errorCode.getMessage()`
- `BLEErrorCode.getByCode(_:)`

## 18. Recommended Integration Flow

A complete business flow usually looks like this:

1. Create `BLEManager`
2. Register `BLECallback`
3. Call `startScan()`
4. Receive devices in `onDiscovery(_:)`
5. Let the user choose a target `BLEDevice`
6. Call `connect(_:)`
7. Wait until `onConnectionChange(_:status:)` becomes `.connected`
8. Execute business capabilities such as time sync, recording control, file operations, and OTA
9. Call `disconnect(_:)` when done

## 19. Minimal Integration Example

```swift
import Foundation
import JieLiSdkRecorder

final class DemoRecorderService: BLECallback {
    private let manager = BLEManager()
    private(set) var devices: [BLEDevice] = []

    init() {
        manager.addCallback(self)
    }

    func startScan() {
        devices.removeAll()
        manager.startScan()
    }

    func connectFirstDevice() {
        guard let device = devices.first else { return }
        manager.connect(device)
    }

    func syncTime(for device: BLEDevice) {
        manager.syncTime(device)
    }

    func refreshFiles(for device: BLEDevice) {
        manager.retrieveFilesFromStart(device)
    }

    func startRecord(for device: BLEDevice) {
        manager.startCustomRecord(device)
    }

    func stopRecord(for device: BLEDevice) {
        manager.stopCustomRecord(device)
    }

    func onRealtimeAudioStarted() {
        print("Realtime audio started")
    }

    func onRealtimeAudioReceived(audio: Data) {
        print("Realtime PCM bytes:", audio.count)
    }

    func onRealtimeAudioStopped() {
        print("Realtime audio stopped")
    }

    func onDiscovery(_ device: BLEDevice) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
    }

    func onConnectionChange(_ device: BLEDevice, status: ConnectionCode) {
        print("Connection status:", device.name, status.getMessage())
    }

    func onFilesRetrieved(_ files: [BLEFile]) {
        print("File list:", files.map(\.name))
    }

    func onError(_ device: BLEDevice, errorCode: BLEErrorCode) {
        print("Error:", device.name, errorCode.getMessage())
    }
}
```

## 20. SDK Capabilities Already Covered

The SDK currently demonstrates the following capabilities:

- BLE scanning
- Device connection and disconnection
- Time synchronization
- Custom recording start and stop
- Recording status query
- Realtime audio PCM callback
- Storage capacity query
- Recording file count query
- File list refresh
- File pagination loading
- File deletion
- File download and sharing
- Key / touch behavior configuration
- Software-triggered key / touch events
- OTA file selection
- OTA start
- OTA cancel
