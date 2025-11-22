# Apple Maps 集成功能说明

## 🗺️ **如何获取周围资源的详细流程**

### 完整流程图

```
1. 用户点击 "Find Nearby Support"
    ↓
2. 请求定位权限
    ↓
3. LocationService 获取用户位置
    CLLocation(latitude: 42.3601, longitude: -71.0589)
    ↓
4. 调用 ResourcesAPI.getNearbyResources(location:)
    ↓
5. 获取所有资源数据
    allResources = [
        Resource(有坐标),
        Resource(无坐标-全国性),
        Resource(有坐标),
        ...
    ]
    ↓
6. 过滤并计算距离
    for resource in allResources:
        if resource有坐标:
            计算 distance = userLocation.distance(from: resourceLocation)
            if distance <= 10km:
                resource.distance = "2.3 km"
                保留此资源
    ↓
7. 排序（按距离从近到远）
    nearbyResources.sort { $0.distance < $1.distance }
    ↓
8. 插入列表顶部
    resources.insert(contentsOf: nearbyResources, at: 0)
    ↓
9. 刷新 UI
    tableView.reloadData()
```

---

## 📍 **距离计算原理**

### CLLocation.distance() 方法

```swift
let userLocation = CLLocation(latitude: 42.3601, longitude: -71.0589)
let resourceLocation = CLLocation(latitude: 42.3356, longitude: -71.0722)

// 计算两点之间的直线距离（单位：米）
let distanceInMeters = userLocation.distance(from: resourceLocation)
// 结果：约 2864 米

// 转换为公里
let distanceInKm = distanceInMeters / 1000
// 结果：2.864 km

// 格式化显示
let formattedDistance = String(format: "%.1f km", distanceInKm)
// 结果："2.9 km"
```

### 过滤半径

```swift
// 默认搜索半径：10 公里
radiusKm: Double = 10

// 只保留在半径内的资源
if distance <= radiusKm {
    // 保留此资源
}
```

---

## 🗺️ **Apple Maps 显示功能**

### 新增组件

#### 1. **ResourceMapView.swift**

- MKMapView 显示地图
- 显示用户当前位置（蓝点）
- Close 按钮关闭地图

#### 2. **ResourceAnnotation.swift**

- 自定义地图标记（Pin）
- 每个标记代表一个资源
- 显示资源名称和类型

#### 3. **ResourceMapViewController.swift**

- 管理地图视图
- 添加资源标记
- 处理标记点击事件
- 提供导航功能

---

## 🎨 **地图功能特性**

### 1. **智能地图中心**

```swift
if 有用户位置:
    以用户位置为中心，显示 5km 范围
else:
    以第一个资源为中心，显示 10km 范围
```

### 2. **彩色标记（根据距离）**

```swift
if distance < 2km:
    标记颜色 = 绿色 🟢  // 非常近
else if distance < 5km:
    标记颜色 = 蓝色 🔵  // 较近
else:
    标记颜色 = 橙色 🟠  // 较远
```

### 3. **标记点击功能**

- 点击标记 → 显示 Callout（信息气泡）
- 气泡内容：资源名称 + 类型 + 距离
- 点击 (i) 按钮 → 显示详细信息

### 4. **详细信息弹窗**

```
📞 Call - 直接拨打电话
🗺️ Directions - 在 Apple Maps 中查看路线
Cancel - 关闭
```

### 5. **Apple Maps 导航**

```swift
// 点击 Directions 后：
- 打开 Apple Maps App
- 自动设置目的地
- 默认使用步行模式导航
```

---

## 🎯 **用户体验流程**

### 场景 1：查看附近资源地图

```
1. 用户打开 Resources 页面
   ↓
2. 点击 "Find Nearby Support"
   ↓
3. 授权定位权限
   ↓
4. 看到列表更新（附近资源在顶部）
   ↓
5. 点击 "🗺️ View on Map"
   ↓
6. 地图全屏显示
   - 用户位置：蓝色圆点
   - 附近资源：彩色标记
   - 距离越近，标记越绿
   ↓
7. 点击任意标记
   ↓
8. 显示资源基本信息
   ↓
9. 点击 (i) 按钮
   ↓
10. 显示详细信息对话框
    ↓
11a. 选择 "📞 Call" → 拨打电话
11b. 选择 "🗺️ Directions" → 打开 Apple Maps 导航
11c. 选择 "Cancel" → 关闭对话框
```

### 场景 2：直接打开地图（无定位）

```
1. 用户打开 Resources 页面（看到全国性资源）
   ↓
2. 直接点击 "🗺️ View on Map"
   ↓
3. 提示："没有可显示位置的资源，请先使用 Find Nearby Support"
```

---

## 🔧 **技术实现细节**

### MapKit 框架使用

```swift
import MapKit

// 1. 创建地图视图
let mapView = MKMapView()
mapView.showsUserLocation = true  // 显示用户位置

// 2. 创建标记
let annotation = ResourceAnnotation(resource: resource)
mapView.addAnnotation(annotation)

// 3. 设置地图区域
let region = MKCoordinateRegion(
    center: coordinate,
    latitudinalMeters: 5000,  // 垂直范围
    longitudinalMeters: 5000   // 水平范围
)
mapView.setRegion(region, animated: true)

// 4. 自定义标记外观
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let pinView = MKMarkerAnnotationView(...)
    pinView.markerTintColor = .systemGreen  // 设置颜色
    pinView.canShowCallout = true           // 允许显示气泡
    return pinView
}

// 5. 打开 Apple Maps 导航
let mapItem = MKMapItem(placemark: placemark)
mapItem.openInMaps(launchOptions: [
    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
])
```

---

## 📊 **数据流示例**

### 输入数据

```swift
resources = [
    // 全国性资源（无坐标）
    MentalHealthResource(
        name: "988 Lifeline",
        latitude: nil,
        longitude: nil
    ),

    // Boston 附近资源
    MentalHealthResource(
        name: "Boston Medical Center",
        latitude: 42.3356,
        longitude: -71.0722,
        distance: "2.9 km"
    ),

    MentalHealthResource(
        name: "Mass General Hospital",
        latitude: 42.3632,
        longitude: -71.0686,
        distance: "0.8 km"
    )
]
```

### 地图显示

```
🗺️ 地图视图
    📍 蓝点 (用户位置: 42.3601, -71.0589)
    🟢 Mass General Hospital (0.8 km - 最近)
    🔵 Boston Medical Center (2.9 km - 较近)

    (988 Lifeline 不显示，因为没有坐标)
```

---

## ✨ **功能亮点**

### 1. **可视化距离**

- 列表显示：文字 "2.9 km"
- 地图显示：彩色标记 + 实际地理位置

### 2. **多种交互方式**

- 查看列表
- 查看地图
- 直接拨打电话
- Apple Maps 导航

### 3. **智能过滤**

- 只在地图上显示有坐标的资源
- 自动排除全国性热线（它们没有具体位置）

### 4. **用户友好**

- 距离用颜色编码（绿-蓝-橙）
- 一键导航
- 清晰的错误提示

---

## 🎯 **使用场景**

### 适合地图显示的资源

✅ 医院、诊所
✅ 心理健康中心
✅ 社区支持组织
✅ 咨询服务机构

### 不适合地图显示的资源

❌ 全国性热线（988）
❌ 短信服务（Crisis Text Line）
❌ 在线服务
❌ 虚拟咨询

---

## 🚀 **测试步骤**

### 测试 1：基本地图显示

1. 运行 App
2. 点击 "Find Nearby Support"
3. 授权定位
4. 点击 "🗺️ View on Map"
5. 验证：
   - ✅ 地图全屏显示
   - ✅ 看到用户位置（蓝点）
   - ✅ 看到资源标记

### 测试 2：标记交互

1. 点击任意标记
2. 验证：
   - ✅ 显示资源名称
   - ✅ 显示资源类型和距离
   - ✅ 有 (i) 按钮

### 测试 3：详细信息

1. 点击标记的 (i) 按钮
2. 验证：
   - ✅ 显示完整信息
   - ✅ 有 Call 按钮
   - ✅ 有 Directions 按钮

### 测试 4：导航功能

1. 点击 "🗺️ Directions"
2. 验证：
   - ✅ 打开 Apple Maps
   - ✅ 目的地已设置
   - ✅ 显示步行路线

---

## 📝 **总结**

### 获取周围资源的方法

1. **定位** - CLLocationManager 获取用户坐标
2. **距离计算** - CLLocation.distance() 计算米数
3. **过滤** - 只保留 10km 以内的资源
4. **排序** - 按距离从近到远

### 地图显示的方法

1. **MapKit** - 使用 Apple 原生地图框架
2. **Annotations** - 自定义标记显示资源
3. **Callouts** - 信息气泡显示详情
4. **导航** - 一键跳转到 Apple Maps

### 优势

✅ 可视化显示
✅ 直观的距离感知
✅ 一站式导航
✅ 原生体验

🎉 **完整的地理位置功能实现！**
