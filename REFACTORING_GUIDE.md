# 项目重构指南 - 新结构迁移

**日期**: 2025 年 11 月 20 日  
**负责人**: Member C (Jian Zhang)  
**目标**: 将项目重构为 Modules 结构

---

## ⚠️ **重要提醒**

### 在 Xcode 中操作，不要直接移动文件！

文件移动必须在 Xcode 中进行，否则会破坏项目引用。

---

## 📋 **重构步骤**

### 阶段 1: 创建新的文件夹结构（Member C 部分）

#### 步骤 1.1: 创建 App 文件夹

```
在 Xcode Project Navigator 中：
1. 右键点击 "Aura" 根目录
2. 选择 "New Group"
3. 命名为 "App"
```

#### 步骤 1.2: 移动应用启动文件到 App/

```
将以下文件拖拽到 "App/" 文件夹：
- AppDelegate.swift
- SceneDelegate.swift
```

#### 步骤 1.3: 创建 Modules 文件夹

```
1. 右键点击 "Aura" 根目录
2. New Group → "Modules"
```

#### 步骤 1.4: 创建 Modules/Home/

```
1. 右键点击 "Modules"
2. New Group → "Home"
3. 将以下文件从 "Home Screen/" 移动到 "Modules/Home/":
   - HomeView.swift
   - ViewController.swift (重命名为 HomeViewController.swift)
```

#### 步骤 1.5: 创建 Modules/Resources/

```
1. 右键点击 "Modules"
2. New Group → "Resources"
3. 将以下文件从 "Resources Screen/" 移动到 "Modules/Resources/":
   - ResourcesView.swift
   - ResourcesViewController.swift
```

#### 步骤 1.6: 创建 Data/Location/

```
1. 右键点击 "Aura" 根目录
2. New Group → "Data"
3. 右键点击 "Data"
4. New Group → "Location"
5. 将 "Services/LocationService.swift" 移动到 "Data/Location/"
```

#### 步骤 1.7: 重命名 ViewController.swift

```
在 Xcode 中：
1. 选中 "Modules/Home/ViewController.swift"
2. 按 Enter 键
3. 重命名为 "HomeViewController.swift"
4. 确认重命名（Xcode 会自动更新引用）
```

---

## 📝 **详细操作步骤**

### Step 1: 在 Xcode 中创建文件夹

打开 Xcode，在 Project Navigator 中：

```
Aura/
├─ App/ (新建)
│  ├─ AppDelegate.swift (移动)
│  └─ SceneDelegate.swift (移动)
│
├─ Modules/ (新建)
│  ├─ Home/ (新建)
│  │  ├─ HomeView.swift (从 Home Screen/ 移动)
│  │  └─ HomeViewController.swift (从 Home Screen/ViewController.swift 移动并重命名)
│  │
│  └─ Resources/ (新建)
│     ├─ ResourcesView.swift (从 Resources Screen/ 移动)
│     └─ ResourcesViewController.swift (从 Resources Screen/ 移动)
│
├─ Data/ (新建)
│  └─ Location/ (新建)
│     └─ LocationService.swift (从 Services/ 移动)
│
└─ Shared/ (已存在)
   └─ IntegrationContracts.swift (已存在，无需移动)
```

---

## 🔧 **代码更新**

### 1. 更新 HomeViewController 类名

**文件**: `Modules/Home/HomeViewController.swift`

**原来**:

```swift
class ViewController: UIViewController {
```

**改为**:

```swift
class HomeViewController: UIViewController {
```

### 2. 更新 SceneDelegate 中的引用

**文件**: `App/SceneDelegate.swift`

**原来**:

```swift
let homeVC = ViewController()
```

**改为**:

```swift
let homeVC = HomeViewController()
```

---

## ✅ **验证清单**

完成重构后，验证以下项目：

- [ ] 项目可以编译（Cmd + B）
- [ ] 没有编译错误
- [ ] 应用可以运行（Cmd + R）
- [ ] Home 页面正常显示
- [ ] 导航到 Resources 正常
- [ ] 定位功能正常
- [ ] 所有功能可用

---

## 🚨 **如果遇到问题**

### 问题 1: 找不到类或文件

**解决**:

1. Clean Build Folder (Cmd + Shift + K)
2. 重新编译 (Cmd + B)

### 问题 2: "No such module" 错误

**解决**:

1. 检查 Target Membership
2. 确保文件在正确的 Target 中

### 问题 3: Storyboard 找不到 ViewController

**解决**:

1. 打开 Main.storyboard
2. 选择 ViewController
3. 在 Identity Inspector 中更新 Class 为 "HomeViewController"

---

## 📊 **重构前后对比**

### 重构前（当前）:

```
Aura/
├─ AppDelegate.swift
├─ SceneDelegate.swift
├─ Home Screen/
│  ├─ HomeView.swift
│  └─ ViewController.swift
├─ Resources Screen/
│  ├─ ResourcesView.swift
│  └─ ResourcesViewController.swift
├─ Services/
│  └─ LocationService.swift
└─ Shared/
   └─ IntegrationContracts.swift
```

### 重构后（目标）:

```
Aura/
├─ App/
│  ├─ AppDelegate.swift
│  └─ SceneDelegate.swift
├─ Modules/
│  ├─ Home/
│  │  ├─ HomeView.swift
│  │  └─ HomeViewController.swift
│  └─ Resources/
│     ├─ ResourcesView.swift
│     └─ ResourcesViewController.swift
├─ Data/
│  └─ Location/
│     └─ LocationService.swift
└─ Shared/
   └─ IntegrationContracts.swift
```

---

## ⏰ **预计时间**

- 创建文件夹结构: 5 分钟
- 移动文件: 10 分钟
- 更新代码引用: 5 分钟
- 测试验证: 10 分钟

**总计**: 约 30 分钟

---

## 🎯 **重构后的好处**

1. ✅ 更清晰的模块划分
2. ✅ 更容易扩展
3. ✅ 符合标准 iOS 架构
4. ✅ 更容易被团队理解
5. ✅ 与 TEAM_ROLES.md 完全一致

---

## 📢 **通知团队**

重构完成后，在团队 Chat 中通知：

```
✅ Member C 已完成项目重构
- 采用新的 Modules 结构
- 所有功能正常运行
- 与 TEAM_ROLES.md 完全一致
- Member A/B 的代码未受影响

新的文件位置：
- Home: Modules/Home/
- Resources: Modules/Resources/
- LocationService: Data/Location/
```

---

**准备好了吗？让我们开始重构！** 🚀
