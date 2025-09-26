## 用户信息接口

**接口地址** `/api/user/info`

**请求方式** `GET`

**consumes** `["application/json"]`

**produces** `["application/json"]`

**接口描述** 获取用户基本信息

**请求参数**

| 参数名称 | 参数说明 | 请求类型 | 是否必须 | 数据类型 | schema |
|---------|---------|---------|---------|---------|--------|
| userId  | 用户ID   | query   | true    | integer |        |

**响应状态**

| 状态码 | 说明 | schema |
|--------|------|--------|
| 200    | OK   | UserInfo |

**响应参数**

| 参数名称 | 参数说明 | 类型 | schema |
|---------|---------|------|--------|
| id      | 用户ID   | integer |        |
| name    | 用户名   | string  |        |
| email   | 邮箱地址 | string  |        |
| age     | 年龄     | integer |        |
| avatar  | 头像URL  | string  |        |
| isActive| 是否激活 | boolean |        |
| tags    | 标签列表 | array   | string  |
| profile | 用户资料 | object  | UserProfile |

**schema属性说明**

**UserProfile**

| 参数名称 | 参数说明 | 类型 | schema |
|---------|---------|------|--------|
| bio     | 个人简介 | string |        |
| location| 所在地   | string |        |
| website | 个人网站 | string |        |
| phone   | 电话号码 | string |        |

**响应示例**

```json
{
  "id": 12345,
  "name": "张三",
  "email": "zhangsan@example.com",
  "age": 25,
  "avatar": "https://example.com/avatar.jpg",
  "isActive": true,
  "tags": ["开发者", "设计师", "产品经理"],
  "profile": {
    "bio": "热爱编程的开发者",
    "location": "北京",
    "website": "https://zhangsan.dev",
    "phone": "13800138000"
  }
}
```
