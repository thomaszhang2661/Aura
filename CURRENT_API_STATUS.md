# 当前 API 调用说明

## 📋 **概述**

**当前状态**: 🟡 **使用本地模拟数据（Local Mock Data）**

```swift
// APIConfigs.swift
static let useLocalData = true  // ✅ 当前设置为 true
```

---

## 🔧 **API 配置**

### 文件：`APIConfigs.swift`

```swift
class APIConfigs {
    // 真实API的基础URL（预留，但未使用）
    static let baseURL = "https://findahelpline.com/api/v1/"

    // 控制开关：true = 本地数据，false = 真实API
    static let useLocalData = true  // ⬅️ 当前设置
}
```

### 配置说明

| 配置项         | 当前值                                | 说明                          |
| -------------- | ------------------------------------- | ----------------------------- |
| `useLocalData` | `true` ✅                             | 使用本地模拟数据              |
| `baseURL`      | `"https://findahelpline.com/api/v1/"` | 预留的真实 API 地址（未使用） |

---

## 📡 **当前调用的是什么 API？**

### 答案：**没有调用真实 API，使用本地数据**

### 详细解释

#### 1️⃣ **数据流程**

```
用户打开 Resources 页面
    ↓
ResourcesViewController.loadNationalResources()
    ↓
ResourcesAPI.getAllResources()
    ↓
检查 APIConfigs.useLocalData
    ↓
✅ true → 调用 getLocalResources() (本地函数)
❌ false → 调用 NetworkManager 访问真实API
    ↓
返回硬编码的资源列表
    ↓
显示在UI
```

#### 2️⃣ **代码实现**

```swift
// 文件：ResourcesAPI.swift (第38-67行)

func getAllResources(completion: @escaping (Result<[MentalHealthResource], Error>) -> Void) {

    if APIConfigs.useLocalData {  // ⬅️ 当前走这个分支
        // ========== 本地数据模式 ==========
        let resources = getLocalResources()  // 本地函数
        DispatchQueue.main.async {
            completion(.success(resources))
        }

    } else {
        // ========== 真实API模式（未使用）==========
        let urlString = APIConfigs.baseURL + "resources"
        // 使用 NetworkManager 发起HTTP请求
        NetworkManager.shared.fetchString(from: urlString) { result in
            // 处理API响应...
        }
    }
}
```

#### 3️⃣ **本地数据源**

```swift
// 文件：ResourcesAPI.swift (第122-196行)

private func getLocalResources() -> [MentalHealthResource] {
    return [
        // ========== 全国性资源 ==========
        MentalHealthResource(
            name: "988 Suicide & Crisis Lifeline",
            type: "24/7 Crisis Hotline",
            phone: "988",
            description: "Free and confidential support",
            distance: nil,
            latitude: nil,
            longitude: nil
        ),

        MentalHealthResource(
            name: "Crisis Text Line",
            type: "24/7 Text Support",
            phone: "741741",
            description: "Text HOME to 741741",
            distance: nil
        ),

        // ========== Boston地区资源（有坐标）==========
        MentalHealthResource(
            name: "Boston Medical Center - Psychiatry",
            type: "Medical Center",
            phone: "(617) 638-8000",
            description: "Comprehensive mental health services",
            latitude: 42.3356,
            longitude: -71.0722
        ),

        MentalHealthResource(
            name: "Massachusetts General Hospital",
            type: "Hospital",
            phone: "(617) 726-2000",
            description: "Full-service psychiatric care",
            latitude: 42.3632,
            longitude: -71.0686
        ),

        MentalHealthResource(
            name: "Cambridge Health Alliance",
            type: "Community Health",
            phone: "(617) 665-1000",
            description: "Mental health and substance use services",
            latitude: 42.3736,
            longitude: -71.1097
        )

        // 总共7个资源（4个全国性 + 3个Boston地区）
    ]
}
```

---

## 🌐 **NetworkManager（网络管理器）**

### 状态：✅ **已实现但未使用**

虽然实现了完整的网络请求功能，但因为 `useLocalData = true`，所以不会被调用。

### 功能概览

```swift
// 文件：NetworkManager.swift

class NetworkManager {
    static let shared = NetworkManager()

    // ========== 功能1：JSON数据请求 ==========
    func fetchData<T: Decodable>(
        from urlString: String,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // 发起HTTP GET请求
        // 解析JSON响应
        // 检查状态码（200-299成功，400-499客户端错误，500+服务器错误）
    }

    // ========== 功能2：文本数据请求 ==========
    func fetchString(
        from urlString: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 发起HTTP GET请求
        // 返回纯文本响应
    }
}
```

### 已实现的特性

- ✅ **异步请求** - 不阻塞 UI 线程
- ✅ **状态码检查** - 200/400/500 错误分类
- ✅ **JSON 解析** - 自动解码为 Swift 对象
- ✅ **错误处理** - 网络错误、解析错误、服务器错误
- ✅ **主线程回调** - UI 更新安全
- ✅ **泛型支持** - 可用于任何 Decodable 类型

---

## 🔄 **如何切换到真实 API？**

### 方法 1：修改配置（最简单）

```swift
// 文件：APIConfigs.swift

static let useLocalData = false  // 改为 false

// 然后确保 baseURL 正确
static let baseURL = "https://your-real-api.com/api/"
```

### 方法 2：使用环境变量

```swift
class APIConfigs {
    static var useLocalData: Bool {
        #if DEBUG
        return true   // 开发环境用本地数据
        #else
        return false  // 生产环境用真实API
        #endif
    }
}
```

### 方法 3：用户可配置

```swift
// 在 Settings 中添加开关
static var useLocalData: Bool {
    return UserDefaults.standard.bool(forKey: "useLocalData")
}
```

---

## 📊 **本地数据 vs 真实 API 对比**

| 特性           | 本地数据（当前）           | 真实 API                 |
| -------------- | -------------------------- | ------------------------ |
| **数据来源**   | `getLocalResources()` 函数 | HTTP 请求到服务器        |
| **响应速度**   | 即时（< 1ms）              | 取决于网络（100-1000ms） |
| **可靠性**     | 100%                       | 取决于网络和服务器       |
| **数据新鲜度** | 固定不变                   | 实时更新                 |
| **需要网络**   | ❌ 不需要                  | ✅ 需要                  |
| **错误可能性** | 无                         | 网络错误、服务器错误     |
| **适用场景**   | 开发、测试、Demo           | 生产环境                 |
| **数据量**     | 7 个资源（固定）           | 无限制                   |

---

## 🎯 **为什么当前使用本地数据？**

### 优点

1. ✅ **开发方便** - 不需要搭建后端服务器
2. ✅ **测试稳定** - 数据可控，不会因网络问题失败
3. ✅ **快速迭代** - 可以快速修改数据进行测试
4. ✅ **离线工作** - 不依赖网络连接
5. ✅ **成本低** - 无需服务器费用
6. ✅ **符合作业要求** - 可以完整展示功能

### 架构优势

- 🔄 **可切换** - 随时切换到真实 API（一行代码）
- 🔄 **已准备好** - NetworkManager 已实现，无需重写
- 🔄 **模拟真实** - 异步回调模式与真实 API 相同

---

## 🚀 **真实 API 集成方案**

### 选项 1：使用公共 API

```swift
// Find A Helpline API (真实存在)
static let baseURL = "https://findahelpline.com/api/v1/"

// 端点示例
// GET https://findahelpline.com/api/v1/countries/US/helplines
```

### 选项 2：自建后端 API

```javascript
// Node.js + Express 示例
app.get('/api/resources', (req, res) => {
    res.json({
        resources: [
            {
                name: "988 Lifeline",
                type: "Hotline",
                phone: "988",
                // ...
            }
        ]
    });
});

// 搜索附近资源
app.post('/api/resources/nearby', (req, res) => {
    const { latitude, longitude, radius } = req.body;
    // 数据库查询...
    res.json({ resources: [...] });
});
```

### 选项 3：使用 Firebase Firestore

```swift
// 替换 ResourcesAPI 实现
func getAllResources(completion: @escaping (Result<[MentalHealthResource], Error>) -> Void) {
    db.collection("mental_health_resources")
        .getDocuments { snapshot, error in
            // 处理Firestore响应...
        }
}
```

---

## 📝 **总结**

### 当前 API 状态

```
🟡 本地模拟数据模式
├─ 数据源：getLocalResources() 函数
├─ 资源数量：7个（4个全国性 + 3个Boston地区）
├─ 网络请求：❌ 无
├─ API调用：❌ 无
└─ NetworkManager：✅ 已实现但未使用
```

### 关键代码位置

| 组件       | 文件                   | 行数    | 说明                  |
| ---------- | ---------------------- | ------- | --------------------- |
| API 配置   | `APIConfigs.swift`     | 1-20    | `useLocalData = true` |
| API 服务   | `ResourcesAPI.swift`   | 38-67   | 判断使用本地还是网络  |
| 本地数据   | `ResourcesAPI.swift`   | 122-196 | 7 个硬编码资源        |
| 网络管理器 | `NetworkManager.swift` | 1-150   | 已实现未使用          |

### 切换到真实 API 只需要：

```swift
// 1. 修改配置（1行代码）
APIConfigs.useLocalData = false

// 2. 确保API地址正确
APIConfigs.baseURL = "https://your-api.com/"

// 3. 完成！NetworkManager会自动处理网络请求
```

---

## 🎉 **结论**

**当前没有调用任何真实 API**，所有数据都来自 `getLocalResources()` 函数中的硬编码数组。

这是一个**有意的设计选择**，因为：

- ✅ 满足课程作业要求（展示功能）
- ✅ 无需依赖外部服务
- ✅ 数据稳定可靠
- ✅ 随时可切换到真实 API

整个网络架构已经完整实现，只是通过 `useLocalData` 开关暂时使用本地数据。这是一个**最佳实践**，在开发阶段使用模拟数据，生产环境切换到真实 API。
