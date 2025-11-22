# GPS 定位 + API 搜索 + 数据库访问完整指南

## 📍 **完整流程图**

```
用户点击 "Find Nearby Support"
    ↓
① GPS定位 (LocationService)
    ↓
② 获取用户坐标 CLLocation(lat: 42.3601, lng: -71.0589)
    ↓
③ 调用 ResourcesAPI.getNearbyResources(location, radius: 10km)
    ↓
④ API调用 getAllResources() 获取所有资源
    ↓
⑤ 数据库/本地数据返回资源列表
    ↓
⑥ 距离计算与过滤
    for each resource with coordinates:
        distance = userLocation.distance(from: resourceLocation)
        if distance <= 10km: keep it
    ↓
⑦ 排序（按距离从近到远）
    ↓
⑧ 返回结果给UI
    ↓
⑨ 插入列表顶部并刷新
```

---

## 🔍 **核心代码详解**

### 1️⃣ **GPS 定位 - LocationService**

```swift
// 文件：ResourcesViewController.swift (第12-87行)

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    private var completion: ((Result<CLLocation, Error>) -> Void)?

    // 请求定位
    func requestLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        self.completion = completion

        // 检查权限状态
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied, .restricted:
            // 权限被拒绝
            completion(.failure(LocationError.denied))
        case .notDetermined:
            // 首次请求权限
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        default:
            // 已授权，直接定位
            manager.requestLocation()
        }
    }

    // 定位成功回调
    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        // 返回坐标：CLLocation(latitude: 42.3601, longitude: -71.0589)
        completion?(.success(loc))
    }

    // 定位失败回调
    func locationManager(_ manager: CLLocationManager,
                        didFailWithError error: Error) {
        completion?(.failure(error))
    }
}
```

**关键点：**

- ✅ 使用单例模式 `shared`
- ✅ 异步回调模式（像教材的网络请求）
- ✅ 错误处理（权限拒绝、定位失败）
- ✅ 精度设置：`kCLLocationAccuracyNearestTenMeters`（10 米精度）

---

### 2️⃣ **点击按钮触发定位**

```swift
// 文件：ResourcesViewController.swift (第211-224行)

@objc private func findNearbyTapped() {
    // ① 先请求权限（如果需要）
    locationService.requestAuthorizationIfNeeded()

    // ② 显示加载状态
    showLoading(true)

    // ③ 请求定位
    locationService.requestLocation { [weak self] result in
        guard let self = self else { return }
        self.showLoading(false)

        switch result {
        case .success(let location):
            // ④ 定位成功，存储用户位置
            self.currentUserLocation = location

            // ⑤ 调用API搜索附近资源
            self.loadNearbyResources(for: location)

        case .failure(let error):
            // ⑥ 定位失败，显示错误
            self.handleLocationError(error)
        }
    }
}
```

**关键点：**

- ✅ `[weak self]` 防止循环引用
- ✅ 存储 `currentUserLocation` 供地图使用
- ✅ 连接定位和 API 搜索

---

### 3️⃣ **API 搜索附近资源**

```swift
// 文件：ResourcesViewController.swift (第248-281行)

private func loadNearbyResources(for location: CLLocation) {
    // ① 获取用户坐标
    let lat = location.coordinate.latitude   // 42.3601
    let lng = location.coordinate.longitude  // -71.0589

    showLoading(true)

    // ② 调用API（传入位置和半径）
    ResourcesAPI.shared.getNearbyResources(
        location: location,
        radiusKm: 10  // 搜索半径10公里
    ) { [weak self] result in
        guard let self = self else { return }
        self.showLoading(false)

        switch result {
        case .success(let nearbyResources):
            // ③ 成功：插入列表顶部
            self.resources.insert(contentsOf: nearbyResources, at: 0)
            self.resourcesView.resourcesTableView.reloadData()

            // ④ 显示成功提示
            let alert = UIAlertController(
                title: "📍 Location Found",
                message: "Found \(nearbyResources.count) resources near:\n(\(lat), \(lng))",
                preferredStyle: .alert
            )
            self.present(alert, animated: true)

        case .failure(let error):
            // ⑤ 失败：显示错误
            self.showErrorAlert(message: "Could not load nearby resources.")
        }
    }
}
```

**关键点：**

- ✅ 异步 API 调用（在后台线程）
- ✅ UI 更新在主线程
- ✅ 结果插入列表顶部（最相关）

---

### 4️⃣ **ResourcesAPI - 数据获取与距离计算**

```swift
// 文件：ResourcesAPI.swift (第71-119行)

class ResourcesAPI {
    static let shared = ResourcesAPI()

    // 获取附近资源
    func getNearbyResources(
        location: CLLocation,       // 用户位置
        radiusKm: Double = 10,      // 搜索半径（默认10km）
        completion: @escaping (Result<[MentalHealthResource], Error>) -> Void
    ) {
        // ① 先获取所有资源
        getAllResources { result in
            switch result {
            case .success(let allResources):

                // ② 过滤和计算距离
                let nearbyResources = allResources.compactMap { resource -> MentalHealthResource? in

                    // ③ 只处理有坐标的资源
                    guard let lat = resource.latitude,
                          let lng = resource.longitude else {
                        return nil  // 跳过全国性资源（无坐标）
                    }

                    // ④ 创建资源位置对象
                    let resourceLocation = CLLocation(latitude: lat, longitude: lng)

                    // ⑤ 计算距离（单位：公里）
                    let distanceMeters = location.distance(from: resourceLocation)
                    let distanceKm = distanceMeters / 1000

                    // ⑥ 过滤：只保留半径内的资源
                    guard distanceKm <= radiusKm else { return nil }

                    // ⑦ 创建带距离的新资源对象
                    return MentalHealthResource(
                        name: resource.name,
                        type: resource.type,
                        phone: resource.phone,
                        description: resource.description,
                        distance: String(format: "%.1f km", distanceKm),  // "2.3 km"
                        latitude: lat,
                        longitude: lng
                    )
                }

                // ⑧ 排序：按距离从近到远
                .sorted { r1, r2 in
                    let d1 = Double(r1.distance?.replacingOccurrences(of: " km", with: "") ?? "999") ?? 999
                    let d2 = Double(r2.distance?.replacingOccurrences(of: " km", with: "") ?? "999") ?? 999
                    return d1 < d2
                }

                // ⑨ 返回结果
                completion(.success(nearbyResources))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
```

**关键算法：**

```swift
// CoreLocation 的距离计算
let userLocation = CLLocation(latitude: 42.3601, longitude: -71.0589)
let resourceLocation = CLLocation(latitude: 42.3356, longitude: -71.0722)

// 计算直线距离（米）
let meters = userLocation.distance(from: resourceLocation)  // 2864 米

// 转换为公里
let km = meters / 1000  // 2.864 公里

// 格式化
let formatted = String(format: "%.1f km", km)  // "2.9 km"
```

---

### 5️⃣ **数据库/数据源 - getAllResources()**

```swift
// 文件：ResourcesAPI.swift (第38-68行)

func getAllResources(completion: @escaping (Result<[MentalHealthResource], Error>) -> Void) {

    // 判断数据源
    if APIConfigs.useLocalData {
        // ========== 本地数据模式 ==========
        // 从本地函数获取模拟数据
        let resources = getLocalResources()
        DispatchQueue.main.async {
            completion(.success(resources))
        }

    } else {
        // ========== 真实API模式 ==========
        let urlString = APIConfigs.baseURL + "resources"

        // 使用 NetworkManager 发起请求
        NetworkManager.shared.fetchString(from: urlString) { result in
            switch result {
            case .success(let data):
                // 解析JSON响应
                let resources = self.parseResourcesFromJSON(data)
                completion(.success(resources))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
```

---

### 6️⃣ **数据源配置**

```swift
// 文件：APIConfigs.swift

struct APIConfigs {
    // 切换开关
    static let useLocalData = true  // true=本地数据, false=真实API

    // 真实API基础URL（当useLocalData=false时使用）
    static let baseURL = "https://your-backend-api.com/api/"
}
```

**数据模式对比：**

| 特性       | 本地数据 (useLocalData=true) | 真实 API (useLocalData=false) |
| ---------- | ---------------------------- | ----------------------------- |
| 数据来源   | `getLocalResources()` 函数   | 后端数据库（通过 HTTP 请求）  |
| 速度       | 即时返回                     | 取决于网络                    |
| 可靠性     | 100%                         | 取决于服务器状态              |
| 数据新鲜度 | 固定数据                     | 实时更新                      |
| 适用场景   | 开发测试、Demo               | 生产环境                      |

---

### 7️⃣ **本地数据源（模拟数据库）**

```swift
// 文件：ResourcesAPI.swift (第122-196行)

private func getLocalResources() -> [MentalHealthResource] {
    return [
        // ========== 全国性资源（无坐标）==========
        MentalHealthResource(
            name: "988 Suicide & Crisis Lifeline",
            type: "24/7 Crisis Hotline",
            phone: "988",
            description: "Free and confidential support",
            distance: nil,
            latitude: nil,  // 无坐标，不会在地图上显示
            longitude: nil
        ),

        // ========== Boston地区资源（有坐标）==========
        MentalHealthResource(
            name: "Boston Medical Center - Psychiatry",
            type: "Medical Center",
            phone: "(617) 638-8000",
            description: "Comprehensive mental health services",
            distance: nil,
            latitude: 42.3356,  // 有坐标，可在地图上显示
            longitude: -71.0722
        ),

        MentalHealthResource(
            name: "Massachusetts General Hospital",
            type: "Hospital",
            phone: "(617) 726-2000",
            description: "Full-service psychiatric care",
            distance: nil,
            latitude: 42.3632,
            longitude: -71.0686
        ),

        MentalHealthResource(
            name: "Cambridge Health Alliance",
            type: "Community Health",
            phone: "(617) 665-1000",
            description: "Mental health and substance use services",
            distance: nil,
            latitude: 42.3736,
            longitude: -71.1097
        )
    ]
}
```

**数据结构：**

```swift
struct MentalHealthResource {
    let name: String           // 资源名称
    let type: String           // 资源类型
    let phone: String          // 电话号码
    let description: String    // 描述
    var distance: String?      // 距离（动态计算）
    let latitude: Double?      // 纬度（可选）
    let longitude: Double?     // 经度（可选）
}
```

---

## 🔗 **真实 API 集成方案**

### 方案 1：使用现有后端 API

```swift
// 修改 APIConfigs.swift
static let useLocalData = false  // 切换到API模式
static let baseURL = "https://api.example.com/v1/"

// ResourcesAPI 调用示例
func getAllResources(completion: @escaping (Result<[MentalHealthResource], Error>) -> Void) {
    let url = APIConfigs.baseURL + "mental-health/resources"

    NetworkManager.shared.fetchData(from: url, responseType: ResourcesResponse.self) { result in
        switch result {
        case .success(let response):
            // 转换API模型为本地模型
            let resources = response.resources.map { apiResource in
                MentalHealthResource(
                    name: apiResource.name,
                    type: apiResource.type,
                    phone: apiResource.phone,
                    description: apiResource.description,
                    distance: nil,
                    latitude: apiResource.latitude,
                    longitude: apiResource.longitude
                )
            }
            completion(.success(resources))

        case .failure(let error):
            completion(.failure(error))
        }
    }
}
```

**API 响应格式示例：**

```json
{
  "resources": [
    {
      "id": "res_001",
      "name": "Boston Medical Center",
      "type": "Medical Center",
      "phone": "(617) 638-8000",
      "description": "Comprehensive mental health services",
      "latitude": 42.3356,
      "longitude": -71.0722,
      "address": "1 Boston Medical Center Pl, Boston, MA 02118",
      "website": "https://www.bmc.org/psychiatry",
      "hours": "24/7"
    }
  ]
}
```

---

### 方案 2：Firebase Firestore 数据库

```swift
// 文件：ResourcesService.swift

import FirebaseFirestore

class ResourcesService {
    private let db = Firestore.firestore()

    // 从 Firestore 获取所有资源
    func fetchAllResources(completion: @escaping ([MentalHealthResource]) -> Void) {
        db.collection("mental_health_resources")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }

                let resources = documents.compactMap { doc -> MentalHealthResource? in
                    let data = doc.data()
                    return MentalHealthResource(
                        name: data["name"] as? String ?? "",
                        type: data["type"] as? String ?? "",
                        phone: data["phone"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        distance: nil,
                        latitude: data["latitude"] as? Double,
                        longitude: data["longitude"] as? Double
                    )
                }

                completion(resources)
            }
    }

    // 地理查询：查找附近资源
    func fetchNearbyResources(
        center: GeoPoint,
        radiusKm: Double,
        completion: @escaping ([MentalHealthResource]) -> Void
    ) {
        // Firestore 地理查询
        db.collection("mental_health_resources")
            .whereField("location", isNear: center, withinKm: radiusKm)
            .getDocuments { snapshot, error in
                // 处理结果...
            }
    }
}
```

**Firestore 数据结构：**

```
mental_health_resources/
  ├─ res_001/
  │   ├─ name: "Boston Medical Center"
  │   ├─ type: "Medical Center"
  │   ├─ phone: "(617) 638-8000"
  │   ├─ description: "..."
  │   ├─ latitude: 42.3356
  │   ├─ longitude: -71.0722
  │   └─ location: GeoPoint(42.3356, -71.0722)
  │
  ├─ res_002/
  │   └─ ...
```

---

### 方案 3：使用地理 API 服务

**Google Places API:**

```swift
func searchNearbyMentalHealthCenters(location: CLLocation) {
    let lat = location.coordinate.latitude
    let lng = location.coordinate.longitude

    let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
                    "location=\(lat),\(lng)" +
                    "&radius=10000" +  // 10km
                    "&type=health" +
                    "&keyword=mental+health" +
                    "&key=YOUR_API_KEY"

    NetworkManager.shared.fetchData(from: urlString, responseType: PlacesResponse.self) { result in
        // 处理 Google Places API 响应
    }
}
```

---

## 📊 **完整数据流示例**

### 场景：用户在 Boston 使用定位搜索

#### 输入：

```swift
用户位置：CLLocation(latitude: 42.3601, longitude: -71.0589)
搜索半径：10 km
```

#### 数据库中的资源：

```swift
[
    // 全国性资源（无坐标）
    Resource(name: "988 Lifeline", lat: nil, lng: nil),

    // Boston附近资源（有坐标）
    Resource(name: "Mass General", lat: 42.3632, lng: -71.0686),
    Resource(name: "BMC", lat: 42.3356, lng: -71.0722),
    Resource(name: "Cambridge Health", lat: 42.3736, lng: -71.1097),

    // New York资源（太远）
    Resource(name: "NYU Langone", lat: 40.7128, lng: -74.0060)
]
```

#### 处理流程：

```
① 遍历所有资源
② 跳过 "988 Lifeline" (无坐标)
③ 计算 "Mass General" 距离：
   distance = CLLocation(42.3601, -71.0589).distance(from: CLLocation(42.3632, -71.0686))
   = 427 米 = 0.4 km ✅ 在10km内
④ 计算 "BMC" 距离：
   = 2864 米 = 2.9 km ✅ 在10km内
⑤ 计算 "Cambridge Health" 距离：
   = 3215 米 = 3.2 km ✅ 在10km内
⑥ 计算 "NYU Langone" 距离：
   = 306,000 米 = 306 km ❌ 超出10km，过滤掉
⑦ 排序结果：[Mass General(0.4km), BMC(2.9km), Cambridge(3.2km)]
```

#### 输出（UI 显示）：

```
📍 附近资源 (3个)
┌───────────────────────────────────┐
│ 🟢 Mass General Hospital          │
│    Hospital · 0.4 km              │
│    (617) 726-2000                 │
├───────────────────────────────────┤
│ 🟢 Boston Medical Center          │
│    Medical Center · 2.9 km        │
│    (617) 638-8000                 │
├───────────────────────────────────┤
│ 🔵 Cambridge Health Alliance      │
│    Community Health · 3.2 km      │
│    (617) 665-1000                 │
└───────────────────────────────────┘

🌐 全国性资源
┌───────────────────────────────────┐
│ 988 Suicide & Crisis Lifeline     │
│    24/7 Crisis Hotline            │
│    988                            │
└───────────────────────────────────┘
```

---

## 🎯 **关键技术点总结**

### GPS 定位

- ✅ **框架**: CoreLocation
- ✅ **权限**: Info.plist 添加 `NSLocationWhenInUseUsageDescription`
- ✅ **精度**: `kCLLocationAccuracyNearestTenMeters` (10 米)
- ✅ **模式**: 单次定位（不连续跟踪）

### 距离计算

- ✅ **方法**: `CLLocation.distance(from:)` - Apple 原生方法
- ✅ **算法**: 大圆距离（Great Circle Distance）- 考虑地球曲率
- ✅ **单位**: 返回米（meters），需除以 1000 转换为公里

### API 设计

- ✅ **异步模式**: `completion handler`（像教材 App10）
- ✅ **错误处理**: `Result<Success, Error>` 枚举
- ✅ **线程安全**: 主线程更新 UI
- ✅ **内存管理**: `[weak self]` 防止循环引用

### 数据库访问

- ✅ **当前**: 本地模拟数据（`getLocalResources()`）
- ✅ **切换开关**: `APIConfigs.useLocalData`
- ✅ **扩展性**: 预留真实 API 接口
- ✅ **备选方案**: Firebase Firestore / REST API / Google Places API

---

## 🚀 **升级到真实数据库的步骤**

### 步骤 1：准备后端 API

```bash
# 示例：Node.js + Express + MongoDB
POST /api/resources/search
{
  "latitude": 42.3601,
  "longitude": -71.0589,
  "radius": 10  # km
}

# 响应
{
  "count": 3,
  "resources": [...]
}
```

### 步骤 2：修改 APIConfigs

```swift
static let useLocalData = false
static let baseURL = "https://your-api.com/api/"
```

### 步骤 3：更新 ResourcesAPI

```swift
func getNearbyResources(location: CLLocation, radiusKm: Double, completion: ...) {
    // 不再本地过滤，直接调用后端API
    let url = APIConfigs.baseURL + "resources/search"
    let body: [String: Any] = [
        "latitude": location.coordinate.latitude,
        "longitude": location.coordinate.longitude,
        "radius": radiusKm
    ]

    NetworkManager.shared.postData(to: url, body: body, responseType: ResourcesResponse.self) { result in
        // 处理响应
    }
}
```

### 步骤 4：测试

```swift
// 单元测试
func testNearbyResourcesAPI() {
    let expectation = XCTestExpectation(description: "API returns nearby resources")

    let testLocation = CLLocation(latitude: 42.3601, longitude: -71.0589)
    ResourcesAPI.shared.getNearbyResources(location: testLocation) { result in
        XCTAssertNotNil(result)
        expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
}
```

---

## ✨ **优势分析**

### 当前实现的优点

1. ✅ **可靠性高** - 本地数据不依赖网络
2. ✅ **速度快** - 即时响应
3. ✅ **易于测试** - 数据可控
4. ✅ **架构清晰** - API 层已抽象
5. ✅ **易于切换** - 一个开关即可切换数据源

### 扩展性

- 🔄 随时切换到真实 API
- 🔄 支持多种数据源（Firebase/REST/GraphQL）
- 🔄 可添加缓存层
- 🔄 可添加离线模式

---

## 📖 **与课程教材的对应关系**

| 课程内容 (App10)               | Aura 实现                      |
| ------------------------------ | ------------------------------ |
| `getAllContacts()`             | `getAllResources()`            |
| `ContactsAPI`                  | `ResourcesAPI`                 |
| `NetworkManager.fetchString()` | `NetworkManager.fetchString()` |
| 异步回调模式                   | ✅ 完全相同                    |
| 状态码检查 (200/400/500)       | ✅ 完全相同                    |
| 主线程更新 UI                  | ✅ 完全相同                    |
| `[weak self]`                  | ✅ 完全相同                    |

**额外增强：**

- ➕ 集成 GPS 定位
- ➕ 距离计算算法
- ➕ 地理过滤功能
- ➕ 地图可视化

---

## 🎉 **总结**

### 核心流程

```
GPS定位 → API调用 → 数据库查询 → 距离计算 → 过滤排序 → UI显示
```

### 关键代码

1. **LocationService** - GPS 定位
2. **ResourcesAPI.getNearbyResources()** - 搜索附近资源
3. **CLLocation.distance()** - 距离计算
4. **getLocalResources()** - 数据源（可切换到真实 API）

### 技术栈

- 定位：CoreLocation
- 网络：URLSession + NetworkManager
- 数据：本地模拟 / 可扩展到真实 API
- 地图：MapKit
- 架构：MVC + API 服务层

🎯 **完整的位置感知功能，随时可升级到生产环境！**
