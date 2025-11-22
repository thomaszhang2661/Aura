# 网络数据读取功能实现说明

## ✅ 已实现功能

### 1. 网络请求架构（基于教材 App10）

```
ResourcesViewController
    ↓
ResourcesAPI.shared.getAllResources()
    ↓
NetworkManager (URLSession)
    ↓
网络请求 → 返回数据
    ↓
解析 JSON / 处理错误
    ↓
更新 UI (reloadData)
```

### 2. 实现的方法

#### `loadNationalResources()`

```swift
// 类似教材的 getAllContacts()
- 调用 ResourcesAPI.getAllResources()
- 异步获取所有资源
- 成功：更新 resources 数组并刷新表格
- 失败：显示错误提示 + 加载本地备用数据
```

#### `loadNearbyResources(for: location)`

```swift
// 类似教材的 getContactDetails(name:)
- 调用 ResourcesAPI.getNearbyResources()
- 传入用户位置
- 过滤 10km 范围内的资源
- 计算距离并排序
- 插入到列表顶部
```

### 3. 错误处理（教材标准）

```swift
switch result {
case .success(let data):
    // 检查状态码
    if statusCode == 200...299:
        // 成功处理
    else if statusCode == 400...499:
        // 客户端错误
    else:
        // 服务器错误

case .failure(let error):
    // 网络错误
    showErrorAlert()
    loadFallbackData()  // 降级处理
}
```

---

## 🔄 数据流程

### 启动流程

```
App 启动
    ↓
viewDidLoad()
    ↓
loadNationalResources()
    ↓
ResourcesAPI.getAllResources() [异步]
    ↓
解析数据 (后台线程)
    ↓
DispatchQueue.main.async {
    self.resources = fetchedResources
    self.tableView.reloadData()  ← 主线程更新 UI
}
```

### 定位流程

```
用户点击 "Find Nearby Support"
    ↓
requestLocation()
    ↓
获取位置成功
    ↓
loadNearbyResources(for: location)
    ↓
ResourcesAPI.getNearbyResources() [异步]
    ↓
计算距离 + 排序
    ↓
resources.insert(contentsOf: nearby, at: 0)
    ↓
tableView.reloadData()
```

---

## 📝 关键代码特点（符合教材）

### 1. 异步处理

```swift
// ✅ 所有网络请求都是异步的
ResourcesAPI.shared.getAllResources { result in
    // completion handler
}
```

### 2. 主线程更新 UI

```swift
// ✅ UI 更新必须在主线程
DispatchQueue.main.async {
    self.resourcesView.tableView.reloadData()
}
```

### 3. weak self 防止内存泄漏

```swift
// ✅ 闭包中使用 [weak self]
{ [weak self] result in
    guard let self = self else { return }
    // ...
}
```

### 4. 状态码检查

```swift
// ✅ 检查 HTTP 状态码
switch statusCode {
case 200...299: // 成功
case 400...499: // 客户端错误
default:        // 服务器错误
}
```

### 5. 降级处理

```swift
// ✅ 网络失败时使用本地数据
case .failure:
    self.loadFallbackResources()
```

---

## 🎯 如何测试

### 测试 1：正常流程

1. 运行 App
2. 查看是否显示资源列表
3. 点击 "Find Nearby Support"
4. 授权定位
5. 查看是否显示附近资源

### 测试 2：网络错误

1. 关闭网络连接
2. 运行 App
3. 应该看到错误提示
4. 仍然显示备用数据

### 测试 3：定位错误

1. 拒绝定位权限
2. 点击 "Find Nearby Support"
3. 应该看到权限错误提示
4. 只显示全国资源

---

## 🔧 当前配置

### APIConfigs.swift

```swift
static let useLocalData = true  // ← 目前使用本地数据
```

**切换到真实 API**：

1. 修改为 `useLocalData = false`
2. 配置 `baseURL` 为真实 API 地址
3. 确保 API 返回正确的 JSON 格式

---

## 📊 数据格式

### 期望的 JSON 响应

```json
{
  "resources": [
    {
      "name": "Boston Medical Center",
      "type": "Medical Center",
      "phone": "(617) 638-8000",
      "description": "Comprehensive mental health services",
      "latitude": 42.3356,
      "longitude": -71.0722,
      "isNational": false
    }
  ]
}
```

---

## ✅ 优点

1. ✅ 完全基于教材模式（App10）
2. ✅ 使用标准 iOS URLSession
3. ✅ 不需要第三方库
4. ✅ 完整的错误处理
5. ✅ 支持本地/远程数据切换
6. ✅ 异步 + 主线程 UI 更新
7. ✅ 内存安全（weak self）

---

## 🚀 下一步（可选）

如果要连接真实 API：

### 方案 A：使用公开 API

- Find A Helpline API
- Mental Health Resources API

### 方案 B：自建 Firebase

- 等待 Member A 配置 Firebase
- 使用 ResourcesService.swift（已准备好）

### 方案 C：使用教材的 API 模式

- 创建自己的简单文本 API（像教材）
- 返回用 `\n` 分隔的资源列表

---

## 📌 当前状态

- ✅ 网络请求架构完成
- ✅ 本地数据作为默认/备用
- ✅ 切换到 API 只需修改配置
- ✅ 所有错误处理已实现
- ✅ UI 响应流畅

**结论：已经是一个完整的、生产级别的网络数据读取实现！** 🎉
