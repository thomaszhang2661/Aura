# 🚀 Xcode 重构操作清单

**状态**: ✅ 代码已更新，现在需要在 Xcode 中重组文件

---

## ✅ **已完成（自动）**

1. ✅ 类名已更新：`ViewController` → `HomeViewController`
2. ✅ SceneDelegate 引用已更新
3. ✅ 代码编译无错误

---

## 📋 **需要在 Xcode 中手动操作**

### 步骤 1: 创建新的文件夹结构 (5 分钟)

#### 1.1 创建 App 文件夹

```
1. 在 Xcode Project Navigator 中，右键点击 "Aura" 项目根目录
2. 选择 "New Group"
3. 命名为 "App"
```

#### 1.2 创建 Modules 文件夹

```
1. 右键点击 "Aura" 根目录
2. 选择 "New Group"
3. 命名为 "Modules"
```

#### 1.3 创建 Modules/Home

```
1. 右键点击 "Modules" 文件夹
2. 选择 "New Group"
3. 命名为 "Home"
```

#### 1.4 创建 Modules/Resources

```
1. 右键点击 "Modules" 文件夹
2. 选择 "New Group"
3. 命名为 "Resources"
```

#### 1.5 创建 Data 文件夹

```
1. 右键点击 "Aura" 根目录
2. 选择 "New Group"
3. 命名为 "Data"
```

#### 1.6 创建 Data/Location

```
1. 右键点击 "Data" 文件夹
2. 选择 "New Group"
3. 命名为 "Location"
```

---

### 步骤 2: 移动文件 (10 分钟)

#### 2.1 移动应用启动文件到 App/

```
拖拽以下文件到 "App/" 文件夹：
□ AppDelegate.swift
□ SceneDelegate.swift
```

#### 2.2 移动 Home 相关文件到 Modules/Home/

```
从 "Home Screen/" 拖拽到 "Modules/Home/"：
□ HomeView.swift
□ ViewController.swift
```

#### 2.3 重命名 ViewController.swift

```
1. 在 "Modules/Home/" 中选中 "ViewController.swift"
2. 右键选择 "Rename..." 或按 Enter
3. 重命名为 "HomeViewController.swift"
4. 点击 "Rename" 确认
   ✅ Xcode 会自动更新所有引用
```

#### 2.4 移动 Resources 文件到 Modules/Resources/

```
从 "Resources Screen/" 拖拽到 "Modules/Resources/"：
□ ResourcesView.swift
□ ResourcesViewController.swift
```

#### 2.5 移动 LocationService 到 Data/Location/

```
从 "Services/" 拖拽到 "Data/Location/"：
□ LocationService.swift
```

---

### 步骤 3: 删除旧的空文件夹 (2 分钟)

```
右键删除以下空文件夹：
□ Home Screen/ (如果为空)
□ Resources Screen/ (如果为空)
```

---

### 步骤 4: 验证 (5 分钟)

#### 4.1 清理构建

```
菜单: Product → Clean Build Folder
或快捷键: Cmd + Shift + K
```

#### 4.2 构建项目

```
菜单: Product → Build
或快捷键: Cmd + B

预期结果: ✅ Build Succeeded (无错误)
```

#### 4.3 运行项目

```
菜单: Product → Run
或快捷键: Cmd + R

预期结果:
✅ 应用启动到 Home 页面
✅ 显示 "Welcome to Aura"
✅ 三个功能按钮正常显示
```

#### 4.4 测试功能

```
□ 点击 "Mood Log" - 显示占位提示 ✅
□ 点击 "Chat" - 显示占位提示 ✅
□ 点击 "Find Resources" - 导航到资源页面 ✅
□ 在资源页面点击 "Find Nearby Support" - 请求定位 ✅
□ 返回 Home - 导航正常 ✅
```

---

## 🎯 **最终目标结构**

完成后，您的项目结构应该是：

```
Aura/
├─ App/
│  ├─ AppDelegate.swift          ✅
│  └─ SceneDelegate.swift         ✅
│
├─ Modules/
│  ├─ Home/
│  │  ├─ HomeView.swift          ✅
│  │  └─ HomeViewController.swift ✅
│  │
│  ├─ Resources/
│  │  ├─ ResourcesView.swift     ✅
│  │  └─ ResourcesViewController.swift ✅
│  │
│  ├─ Auth/                       (Member A)
│  ├─ MoodLog/                    (Member B)
│  └─ Chat/                       (Member B)
│
├─ Data/
│  ├─ Location/
│  │  └─ LocationService.swift   ✅
│  ├─ Models/
│  ├─ Auth/                       (Member A)
│  ├─ Mood/                       (Member B)
│  └─ Chat/                       (Member B)
│
├─ Shared/
│  └─ IntegrationContracts.swift ✅
│
└─ Config/
   └─ Info.plist                  ✅
```

---

## 🎨 **可视化对比**

### 重构前:

```
❌ 混乱
Aura/
├─ AppDelegate.swift
├─ SceneDelegate.swift
├─ Home Screen/
├─ Resources Screen/
├─ Login Screen/
├─ Chat Screen/
└─ Services/
```

### 重构后:

```
✅ 清晰有序
Aura/
├─ App/              // 应用层
├─ Modules/          // 功能模块
├─ Data/             // 数据层
└─ Shared/           // 共享资源
```

---

## ⏰ **预计时间**

- 创建文件夹: 5 分钟
- 移动文件: 10 分钟
- 重命名: 2 分钟
- 测试验证: 5 分钟

**总计**: 约 22 分钟

---

## 🐛 **常见问题**

### Q: 移动文件后出现红色感叹号？

**A**:

1. 选中文件
2. 在 File Inspector 中点击文件夹图标
3. 重新定位文件

### Q: 编译错误："Cannot find type 'HomeViewController'"？

**A**:

1. Clean Build Folder (Cmd + Shift + K)
2. 重新构建 (Cmd + B)

### Q: 运行时崩溃？

**A**:

1. 检查 Main.storyboard 中的 ViewController Class
2. 确保改为 "HomeViewController"

---

## ✅ **完成检查清单**

重构完成后，确认以下项目：

- [ ] 所有文件在正确的文件夹中
- [ ] 没有重复的文件
- [ ] 旧的空文件夹已删除
- [ ] 项目可以编译（无错误）
- [ ] 应用可以运行
- [ ] Home 页面正常显示
- [ ] 导航功能正常
- [ ] 定位功能正常

---

## 🎉 **重构完成！**

完成所有步骤后：

1. **测试所有功能**
2. **提交到 Git**:

   ```bash
   git add .
   git commit -m "Refactor: Reorganize project structure to Modules pattern"
   git push origin Tom
   ```

3. **更新文档**:

   - TEAM_ROLES.md ✅ (已符合)
   - IMPLEMENTATION_COMPARISON.md ✅ (已更新)

4. **通知团队**:
   ```
   ✅ Project structure refactored to Modules pattern
   - All Member C files moved to new structure
   - Member A/B files unchanged
   - All tests passing
   ```

---

**现在打开 Xcode，按照这个清单操作吧！** 🚀

需要帮助的话随时告诉我！
