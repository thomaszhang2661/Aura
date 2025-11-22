# Member C 独立测试指南

**测试人员**: Jian Zhang (Member C)  
**日期**: 2025 年 11 月 20 日  
**状态**: ✅ 可以独立测试

---

## 🎯 测试目的

验证 Member C 负责的所有功能（Home + Resources + Navigation + Location）是否正常工作，无需等待 Member A 和 B 的代码。

---

## ✅ 已配置完成

我已经为您配置好了独立测试环境：

### 修改的文件：

- ✅ `SceneDelegate.swift` - 配置为直接启动 Home 页面

### 您可以测试的功能：

1. ✅ Home 页面 UI
2. ✅ 导航到 Resources
3. ✅ GPS 定位
4. ✅ 资源列表显示
5. ✅ 电话拨打功能
6. ✅ EventBus 事件系统

---

## 🚀 如何开始测试

### 步骤 1: 构建并运行

```bash
# 在 Xcode 中
1. 选择模拟器或真机
2. 按 Cmd + R 运行
```

### 步骤 2: 观察启动

应用启动后应该**直接**进入 Home 页面，看到：

```
┌─────────────────────────────┐
│     Welcome to Aura         │
│                             │
│  ┌─────────────────────┐   │
│  │   📝 Mood Log       │   │
│  │  Track emotions     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  💬 Chat with Aura  │   │
│  │   AI assistant      │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │  🏥 Find Resources  │   │
│  │   Get help nearby   │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 📋 测试清单

### Test Case 1: Home 页面显示 ✅

**预期结果**:

- [ ] 顶部显示 "Welcome to Aura"
- [ ] 显示 3 个功能按钮
- [ ] 按钮有图标和说明文字
- [ ] UI 布局美观
- [ ] 深色模式下颜色正常

**如何测试**:

1. 启动应用
2. 检查 Home 页面布局
3. 切换深色/浅色模式 (Settings → Appearance)

---

### Test Case 2: Mood Log 按钮（占位）✅

**预期结果**:

- [ ] 点击显示提示框
- [ ] 提示信息："This feature is being implemented by Member B"

**如何测试**:

1. 点击 "📝 Mood Log" 按钮
2. 查看弹出提示
3. 点击 "OK" 关闭

**控制台输出**:

```
📝 Navigate to Mood Log
```

---

### Test Case 3: Chat 按钮（占位）✅

**预期结果**:

- [ ] 点击显示提示框
- [ ] 提示信息："This feature is being implemented by Member B"

**如何测试**:

1. 点击 "💬 Chat with Aura" 按钮
2. 查看弹出提示
3. 点击 "OK" 关闭

**控制台输出**:

```
💬 Navigate to Chat
```

---

### Test Case 4: Resources 导航 ✅

**预期结果**:

- [ ] 导航到 Resources 页面
- [ ] 显示两个按钮和资源列表
- [ ] 可以返回 Home

**如何测试**:

1. 点击 "🏥 Find Resources" 按钮
2. 验证进入 Resources 页面
3. 点击左上角返回按钮回到 Home

**控制台输出**:

```
🏥 Navigate to Resources
```

---

### Test Case 5: 资源列表显示 ✅

**预期结果**:

- [ ] 显示 4 个国家级热线
- [ ] 988 Suicide & Crisis Lifeline
- [ ] Crisis Text Line
- [ ] NAMI Helpline
- [ ] SAMHSA National Helpline

**如何测试**:

1. 进入 Resources 页面
2. 向下滚动查看列表
3. 验证所有资源都显示

---

### Test Case 6: GPS 定位功能 ✅

**预期结果**:

- [ ] 第一次点击请求定位权限
- [ ] 允许后显示定位成功提示
- [ ] 附近资源添加到列表顶部
- [ ] 显示 3 个 mock 附近资源

**如何测试（模拟器）**:

1. 点击 "📍 Find Nearby Support"
2. 允许定位权限
3. 等待定位完成
4. 查看成功提示和坐标
5. 验证列表顶部新增 3 个附近资源：
   - Hope Counseling Center (0.8 km)
   - Community Wellness Clinic (1.2 km)
   - Mindful Living Center (2.3 km)

**模拟器定位设置**:

```
菜单: Features → Location → Custom Location
或: Debug → Simulate Location → Apple
```

**控制台输出**:

```
📍 Location request started
✅ Location found: (37.xxxx, -122.xxxx)
```

---

### Test Case 7: 定位权限被拒绝 ✅

**预期结果**:

- [ ] 显示错误提示
- [ ] 提供"打开设置"按钮
- [ ] 点击可跳转到系统设置

**如何测试**:

1. 拒绝定位权限（或在设置中关闭）
2. 点击 "📍 Find Nearby Support"
3. 验证错误提示
4. 点击 "Open Settings"（模拟器会打开设置）

---

### Test Case 8: 资源详情查看 ✅

**预期结果**:

- [ ] 点击资源显示详情弹窗
- [ ] 显示资源名称、类型、电话、描述
- [ ] 有"Call"和"Cancel"按钮

**如何测试**:

1. 在资源列表中点击任意一个资源
2. 验证弹出详情对话框
3. 查看信息是否完整
4. 点击 "Cancel" 关闭

---

### Test Case 9: 拨打电话功能 ✅

**预期结果**:

- [ ] 点击 "Call" 尝试拨打电话
- [ ] 真机：弹出拨号确认
- [ ] 模拟器：无法拨号但不会崩溃

**如何测试（真机）**:

1. 点击任意资源
2. 在详情对话框中点击 "📞 Call"
3. 验证弹出拨号界面
4. 取消拨号

**如何测试（模拟器）**:

1. 点击任意资源
2. 点击 "📞 Call"
3. 验证不会崩溃

---

### Test Case 10: "Chat with Aura" 按钮（Resources 页面）✅

**预期结果**:

- [ ] 点击后返回 Home 页面
- [ ] 发送 `.openChat` 事件

**如何测试**:

1. 在 Resources 页面
2. 点击 "💬 Chat with Aura" 按钮
3. 验证返回到 Home 页面

**控制台输出**:

```
📣 Event: openChat
```

---

### Test Case 11: EventBus 系统 ✅

**预期结果**:

- [ ] 事件可以正常发送和接收
- [ ] 不会内存泄漏

**如何测试**:

1. 打开控制台
2. 导航到不同页面
3. 查看事件日志
4. 验证 `deinit` 被调用（移除监听器）

**控制台输出示例**:

```
✅ Home: Listening to events
📣 EventBus: Emitting .openResources
🚪 Home: Stopped listening (deinit)
```

---

### Test Case 12: Logout 按钮（占位）✅

**预期结果**:

- [ ] 点击显示确认对话框
- [ ] 点击 "Logout" 显示占位提示

**如何测试**:

1. 在 Home 页面点击右上角 "Logout"
2. 验证确认对话框
3. 点击 "Logout"
4. 查看占位提示

---

## 🐛 已知限制（预期行为）

### 占位功能（等待其他成员）:

- ❌ Mood Log - 显示占位提示（Member B 负责）
- ❌ Chat - 显示占位提示（Member B 负责）
- ❌ Login/Logout - 显示占位提示（Member A 负责）

### 模拟数据:

- ⚠️ 附近资源是 mock 数据，不是真实 API
- ⚠️ 电话号码是示例，不是真实号码

---

## 📱 测试设备建议

### 模拟器测试:

✅ **推荐**: iPhone 14 Pro (iOS 16+)

- 测试布局和导航
- 测试定位（使用模拟位置）
- 测试 UI 响应

### 真机测试:

✅ **推荐**: 任何 iOS 14+ 设备

- 测试真实 GPS 定位
- 测试电话拨打功能
- 测试权限请求流程

---

## ✅ 测试通过标准

所有以下项目都应该正常工作：

- [x] 应用启动到 Home 页面
- [x] Home UI 显示正常
- [x] 导航到 Resources 正常
- [x] 资源列表显示 4 个国家热线
- [x] GPS 定位请求正常
- [x] 定位成功显示附近资源
- [x] 点击资源显示详情
- [x] 电话拨打不崩溃
- [x] 返回导航正常
- [x] 无编译错误
- [x] 无运行时崩溃

---

## 🔧 问题排查

### 问题 1: 应用不启动到 Home 页面

**解决方法**: 确认 `SceneDelegate.swift` 已正确修改

### 问题 2: 定位权限一直不弹出

**解决方法**:

1. 卸载应用重新安装
2. 检查 `Info.plist` 中的 `NSLocationWhenInUseUsageDescription`

### 问题 3: 资源列表是空的

**解决方法**:

1. 检查 `loadNationalResources()` 是否在 `viewDidLoad` 中调用
2. 检查 `resourcesTableView.reloadData()` 是否调用

### 问题 4: 导航栏没显示

**解决方法**: 确认使用了 `UINavigationController`

---

## 📊 测试报告模板

```
测试日期: ________
测试设备: ________
iOS 版本: ________

✅ Home 页面显示: PASS / FAIL
✅ Resources 导航: PASS / FAIL
✅ GPS 定位: PASS / FAIL
✅ 资源列表: PASS / FAIL
✅ 电话拨打: PASS / FAIL
✅ EventBus: PASS / FAIL

问题记录:
1. _______________
2. _______________

总体评价: ✅ 通过 / ⚠️ 部分通过 / ❌ 未通过
```

---

## 🎥 测试演示视频建议

录制以下操作流程：

1. 应用启动 → Home 页面
2. 点击三个按钮（显示占位）
3. 导航到 Resources
4. 点击定位按钮（显示权限请求）
5. 允许定位（显示附近资源）
6. 点击资源查看详情
7. 尝试拨打电话
8. 返回 Home

---

## 🚀 测试完成后

### 1. 提交测试报告

- 截图或录屏
- 记录任何问题

### 2. Git 提交

```bash
git add .
git commit -m "Member C: Home + Resources + Navigation - Ready for testing"
git push origin Tom
```

### 3. 通知团队

告诉 Member A 和 B：

- ✅ Member C 部分已完成
- ✅ EventBus 接口可以使用
- ✅ 导航框架已就绪

---

## 📞 联系方式

如果测试中遇到问题：

- 检查控制台日志
- 查看 `MEMBER_C_QUICK_REFERENCE.md`
- 参考 `MEMBER_C_PROGRESS.md`

---

**祝测试顺利！** 🎉

所有功能都应该可以正常工作。如果有任何问题，请告诉我！
