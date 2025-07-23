# Discourse 签到插件 (Discourse Check-in Plugin)

一个Discourse签到插件，支持积分系统、连续签到奖励和补签功能。

## 修复说明

已修复以下问题：
- ✅ Rails版本兼容性 (改为Rails 6.0)
- ✅ 数据库迁移文件格式 (使用时间戳命名)
- ✅ 移除重复索引问题
- ✅ 修复外键约束问题
- ✅ 简化模型关联
- ✅ 修复控制器中的作用域问题
- ✅ 简化前端实现

## 核心功能

### 🎯 后端API
- **每日签到**: `/checkin-plugin/checkin` (POST)
- **补签**: `/checkin-plugin/checkin/makeup` (POST)
- **积分查询**: `/checkin-plugin/points` (GET)
- **签到历史**: `/checkin-plugin/points/history` (GET)
- **排行榜**: `/checkin-plugin/points/leaderboard` (GET)

### 🗄️ 数据库表
- **checkin_user_points**: 用户积分表
- **checkin_records**: 签到记录表

### ⚙️ 管理配置
- `checkin_plugin_enabled`: 启用插件
- `checkin_base_points`: 基础积分 (默认: 10)
- `checkin_makeup_cost`: 补签消耗 (默认: 10)
- `checkin_max_makeup_days`: 最大补签天数 (默认: 7)
- 连续签到奖励倍数配置

## 安装方法

1. 将插件放置到Discourse的plugins目录
2. 重启Discourse
3. 在管理后台启用插件

## API使用示例

```bash
# 今日签到
curl -X POST /checkin-plugin/checkin

# 补签
curl -X POST /checkin-plugin/checkin/makeup -d "date=2023-12-01"

# 查看积分
curl /checkin-plugin/points
```
