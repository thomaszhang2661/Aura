# TEAM ROLES & PROJECT STRUCTURE（Final Version）

下面是我们团队对项目结构、模块划分和每个人的责任分工说明。

---

# 🗂 1. Project Structure（目录结构）

```
Aura
├─ App/
│  ├─ AppDelegate.swift                // Firebase 初始化
│  ├─ SceneDelegate.swift
│  └─ RootCoordinator.swift (可选)     // Home / Login 路由切换（如果我们需要）
│
├─ Modules/
│  ├─ Auth/                            // A
│  │  ├─ Login/
│  │  │  ├─ LoginView.swift
│  │  │  └─ LoginViewController.swift
│  │  └─ SignUp/
│  │     ├─ SignUpView.swift
│  │     └─ SignUpViewController.swift
│  │
│  ├─ Home/                            // C
│  │  ├─ HomeView.swift
│  │  └─ HomeViewController.swift
│  │
│  ├─ MoodLog/                         // B
│  │  ├─ MoodLogView.swift
│  │  └─ MoodLogViewController.swift
│  │
│  ├─ Chat/                            // B
│  │  ├─ ChatView.swift
│  │  └─ ChatViewController.swift
│  │
│  └─ Resources/                       // C
│     ├─ ResourcesView.swift
│     └─ ResourcesViewController.swift
│
├─ Data/
│  ├─ Models/
│  │  ├─ User.swift                    // A 负责定义
│  │  ├─ MoodEntry.swift               // B
│  │  └─ ChatMessage.swift             // B
│  │
│  ├─ Auth/                            // A
│  │  └─ AuthService.swift
│  │
│  ├─ Mood/                            // B
│  │  └─ MoodRepository.swift
│  │
│  ├─ Chat/                            // B
│  │  └─ ChatRepository.swift
│  │
│  └─ Location/                        // C
│     └─ LocationService.swift
│
├─ Shared/
│  ├─ Components/
│  │  └─ LoadingIndicator.swift        // 全项目可使用
│  └─ Contracts/
│     └─ IntegrationContracts.swift    // 模块间事件 / DeepLink
│
└─ Config/
   └─ FirestoreCollections.swift       // Firestore 集合名常量
```

**规则：**

- 每一个界面 = 一个 Group
- Group 下 **必须有**：`XxxView.swift`（UI） + `XxxViewController.swift`（逻辑）
- UI 全部用代码布局，`loadView()` 里设置：

  ```swift
  override func loadView() { view = XxxView() }
  ```

- Storyboard 只负责放 UIViewController，不放 UI 控件。

---

# 👤 2. Member A — Auth + Firebase Init（账号相关全部负责）

成员 A 负责所有「账号」相关的功能，包括 UI、交互、错误提示，以及 FirebaseAuth 集成、Firebase 初始化。

## 📁 负责文件 / 目录

- `App/AppDelegate.swift`（配置 FirebaseApp）
- `Modules/Auth/Login/`

  - `LoginView.swift`
  - `LoginViewController.swift`

- `Modules/Auth/SignUp/`

  - `SignUpView.swift`
  - `SignUpViewController.swift`

- `Modules/Home/`（仅引用，不属于 A 的主模块）
- `Data/Models/User.swift`
- `Data/Auth/AuthService.swift`
- `Config/FirestoreCollections.swift`（基础集合名可由 A 定义）
- 参与 `Shared/Contracts/IntegrationContracts.swift`（登录事件）

## 🖼️ UI（View）职责

- 设计 Login / SignUp 页面的 UI：文本框、按钮、错误 label、布局。
- 保持 Auth 页的风格统一。

## 🔐 逻辑 / Firebase 交互职责

- 在 `AppDelegate` 完成 `FirebaseApp.configure()`。
- 在 `AuthService` 中封装：

  - `signIn(email, password)`
  - `signUp(email, password)`
  - `signOut()`
  - `currentUserUID`

- Login / SignUp 的 VC 通过 AuthService 进行交互，不直接写 Firebase 代码。
- 登录成功时发送 `.didLogin(uid:)` 事件，供 C 切到 Home。

## 🎯 A 的目标（DoD）

- App 启动时进入 Login，登录后进入 Home。
- Auth 的所有 Firebase 操作稳定（注册、登录、登出）。
- 所有页面需要 uid 时，都能从 `AuthService` 拿到。

---

# 👤 3. Member B — MoodLog + Chat（UI + VC + 模型 + Firestore 读写）

成员 B 负责「情绪记录」与「聊天」完整功能链，包括 UI、控制器逻辑、模型结构，以及 Firestore 交互（写 mood_log + 写 chat_history）。

## 📁 负责文件 / 目录

### MoodLog

- `MoodLogView.swift`
- `MoodLogViewController.swift`
- `MoodEntry.swift`
- `MoodRepository.swift`

### Chat

- `ChatView.swift`
- `ChatViewController.swift`
- `ChatMessage.swift`
- `ChatRepository.swift`
- `ChatServiceMock.swift`（AI 演示版固定回复）

## 🖼️ UI（View）职责

- MoodLogView：情绪选择控件、note 输入框、历史列表区。
- ChatView：聊天气泡区域、底部输入栏（已有基础可继续完善）。

## 🧠 逻辑职责（Firestore）

### MoodLog

- 使用 `AuthService` 获取当前 uid。
- 使用 `MoodRepository` 写入到：

  ```
  /users/{uid}/mood_logs/{moodId}
  ```

- 读取 mood 列表，按时间倒序展示。

### Chat

- 用户输入一条消息 → 显示“我”的气泡。
- 调 `ChatServiceMock` 返回一条固定 AI 回复 → 显示 AI 气泡。
- 使用 `ChatRepository` 写入到：

  ```
  /users/{uid}/chat_history/{messageId}
  ```

## 🎯 B 的目标（DoD）

- Mood 页面能写入 + 读取 Firestore mood_logs。
- Chat 页面能发送消息、显示 AI mock 回复、写入 chat_history。
- Firestore 调用集中在 Repository，VC 干净整洁。

---

# 👤 4. Member C — Home + Resources + Navigation + Location

成员 C 负责 App 的外部框架：导航、Home 页、Resources 页，以及定位功能。

## 📁 负责文件 / 目录

### Home

- `HomeView.swift`
- `HomeViewController.swift`

### Resources

- `ResourcesView.swift`
- `ResourcesViewController.swift`

### Services

- `LocationService.swift`

### Integration

- `Shared/Contracts/IntegrationContracts.swift`（C 维护 deep link & event 系统）

## 🖼️ UI（View）职责

- Home：Mood / Chat / Resources 的入口按钮。
- Resources：两张卡片（Find Nearby Support / Chat with Aura）+ 列表容器。

## 🧭 逻辑职责

### Home

- 负责整个 App 的导航壳。
- Home → MoodLog, Chat, Resources 的跳转。
- 监听 `.didLogin(uid:)` 来切换首页（如果使用 RootCoordinator）。

### Resources

- 请求定位权限，读取位置信息（CLLocation）。
- 展示 mock 或真实的附近资源列表。

### Integration & Routing

- 维护 `IntegrationContracts` 中的 AppEvent/DeepLink。
- 如果 Chat 想触发“跳到资源”，用 deep link 实现（未来可选）。

## 🎯 C 的目标（DoD）

- Home 页面正常显示三个功能入口。
- 点按按钮可以跳到对应模块（导航作业阶段实现）。
- Resources 页面能请求定位并展示至少一条资源。
- deep link & event 系统能正常通知各模块（如需要）。

---

# 🌐 5. Shared Components（公用模块）

| 公用内容             | 文件                                       | 主要负责人                     |
| -------------------- | ------------------------------------------ | ------------------------------ |
| Loading HUD          | `Shared/Components/LoadingIndicator.swift` | B（或谁先写谁负责）            |
| 模块事件 / 深链      | `IntegrationContracts.swift`               | C                              |
| Firestore 集合名常量 | `FirestoreCollections.swift`               | A（定义基础），B/C 使用        |
| User 模型            | `User.swift`                               | A 主导，B/C 扩展字段需同步讨论 |

---

# 🚀 总结：三人分工一览

Member A — Authentication + Firebase Initialization and authentication
Member B — MoodLog + Chat + Firestore(chatlog and moodlog)
Member C — Home / Resources / Navigation / Location

我负责 C 部分
