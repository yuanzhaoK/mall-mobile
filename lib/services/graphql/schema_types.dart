/// GraphQL Schema类型定义
///
/// 包含会员模块相关的所有输入输出类型定义
/// 基于会员模块设计文档的完整类型系统

/// =================================
/// 基础类型定义
/// =================================

/// 分页输入参数
class PaginationInput {
  static const String schema = '''
    input PaginationInput {
      page: Int = 1
      limit: Int = 20
      sort_by: String
      sort_order: SortOrder = ASC
    }
    
    enum SortOrder {
      ASC
      DESC
    }
  ''';
}

/// 通用查询输入
class QueryInput {
  static const String schema = '''
    input QueryInput {
      filters: JSON
      search: String
      pagination: PaginationInput
    }
  ''';
}

/// =================================
/// 会员相关类型定义
/// =================================

/// 会员类型
class MemberType {
  static const String schema = '''
    type Member {
      id: ID!
      username: String!
      email: String!
      phone: String
      password_hash: String
      avatar: String
      real_name: String
      gender: Gender
      birthday: Date
      level: MemberLevel
      points: Int!
      balance: Float!
      total_orders: Int!
      total_amount: Float!
      status: MemberStatus!
      register_time: DateTime!
      last_login_time: DateTime
      wechat_openid: String
      wechat_unionid: String
      is_verified: Boolean!
      created: DateTime!
      updated: DateTime!
      addresses: [Address!]!
      favorites: [Product!]!
      cart_items: [CartItem!]!
      orders: [Order!]!
      points_records: [PointsRecord!]!
    }
    
    enum Gender {
      MALE
      FEMALE
      UNKNOWN
    }
    
    enum MemberStatus {
      ACTIVE
      INACTIVE
      BANNED
    }
  ''';
}

/// 会员等级类型
class MemberLevelType {
  static const String schema = '''
    type MemberLevel {
      id: ID!
      name: String!
      description: String
      discount_rate: Float!
      points_required: Int!
      benefits: JSON
      icon: String
      color: String
      sort_order: Int!
      is_active: Boolean!
      created: DateTime!
      updated: DateTime!
      members_count: Int!
    }
  ''';
}

/// 积分记录类型
class PointsRecordType {
  static const String schema = '''
    type PointsRecord {
      id: ID!
      user_id: ID!
      username: String!
      type: PointsType!
      points: Int!
      balance: Int!
      reason: String!
      order_id: ID
      related_id: ID
      expire_time: DateTime
      created: DateTime!
    }
    
    enum PointsType {
      EARNED_REGISTRATION
      EARNED_LOGIN
      EARNED_ORDER
      EARNED_REVIEW
      EARNED_REFERRAL
      EARNED_ACTIVITY
      EARNED_ADMIN
      SPENT_EXCHANGE
      SPENT_ORDER
      EXPIRED
      ADMIN_ADJUST
    }
  ''';
}

/// 积分规则类型
class PointsRuleType {
  static const String schema = '''
    type PointsRule {
      id: ID!
      name: String!
      description: String
      type: PointsType!
      points: Int!
      conditions: JSON
      is_active: Boolean!
      start_time: DateTime
      end_time: DateTime
      daily_limit: Int
      total_limit: Int
      sort_order: Int!
      created: DateTime!
      updated: DateTime!
    }
  ''';
}

/// 积分兑换商品类型
class PointsExchangeType {
  static const String schema = '''
    type PointsExchange {
      id: ID!
      name: String!
      description: String
      image: String
      points_required: Int!
      exchange_type: ExchangeType!
      reward_value: Float
      reward_product_id: ID
      reward_coupon_id: ID
      stock: Int
      used_count: Int!
      status: ExchangeStatus!
      sort_order: Int!
      created: DateTime!
      updated: DateTime!
    }
    
    enum ExchangeType {
      BALANCE
      COUPON
      PRODUCT
      PRIVILEGE
    }
    
    enum ExchangeStatus {
      ACTIVE
      INACTIVE
      OUT_OF_STOCK
    }
  ''';
}

/// 积分兑换记录类型
class PointsExchangeRecordType {
  static const String schema = '''
    type PointsExchangeRecord {
      id: ID!
      user_id: ID!
      username: String!
      exchange: PointsExchange!
      points_cost: Int!
      reward_type: ExchangeType!
      reward_value: Float
      status: ExchangeRecordStatus!
      created: DateTime!
      processed_time: DateTime
    }
    
    enum ExchangeRecordStatus {
      PENDING
      COMPLETED
      CANCELLED
      FAILED
    }
  ''';
}

/// 地址类型
class AddressType {
  static const String schema = '''
    type Address {
      id: ID!
      user_id: ID!
      name: String!
      phone: String!
      province: String!
      city: String!
      district: String!
      address: String!
      postal_code: String
      is_default: Boolean!
      tag: String
      created: DateTime!
      updated: DateTime!
    }
  ''';
}

/// 购物车项类型
class CartItemType {
  static const String schema = '''
    type CartItem {
      id: ID!
      user_id: ID!
      product: Product!
      quantity: Int!
      price: Float!
      selected: Boolean!
      created: DateTime!
      updated: DateTime!
    }
  ''';
}

/// 购物车信息类型
class CartInfoType {
  static const String schema = '''
    type CartInfo {
      items: [CartItem!]!
      total_items: Int!
      total_amount: Float!
      selected_amount: Float!
      selected_items: Int!
    }
  ''';
}

/// 收藏类型
class FavoriteType {
  static const String schema = '''
    type Favorite {
      id: ID!
      user_id: ID!
      product: Product!
      created: DateTime!
    }
  ''';
}

/// 会员标签类型
class MemberTagType {
  static const String schema = '''
    type MemberTag {
      id: ID!
      name: String!
      description: String
      color: String
      is_system: Boolean!
      created: DateTime!
      members_count: Int!
    }
  ''';
}

/// 通知类型
class NotificationType {
  static const String schema = '''
    type Notification {
      id: ID!
      user_id: ID!
      title: String!
      content: String!
      type: NotificationType!
      data: JSON
      is_read: Boolean!
      created: DateTime!
    }
    
    enum NotificationType {
      SYSTEM
      ORDER
      MARKETING
      CUSTOMER_SERVICE
    }
  ''';
}

/// =================================
/// 输入类型定义
/// =================================

/// 注册输入
class RegisterInput {
  static const String schema = '''
    input RegisterInput {
      username: String!
      email: String!
      password: String!
      phone: String
      wechat_code: String
      referral_code: String
    }
  ''';
}

/// 登录输入
class LoginInput {
  static const String schema = '''
    input LoginInput {
      identity: String!
      password: String!
      remember_me: Boolean = false
    }
  ''';
}

/// 微信登录输入
class WechatLoginInput {
  static const String schema = '''
    input WechatLoginInput {
      code: String!
      user_info: JSON
      iv: String
      encrypted_data: String
    }
  ''';
}

/// 个人资料更新输入
class ProfileUpdateInput {
  static const String schema = '''
    input ProfileUpdateInput {
      real_name: String
      gender: Gender
      birthday: Date
      avatar: String
      phone: String
    }
  ''';
}

/// 密码修改输入
class ChangePasswordInput {
  static const String schema = '''
    input ChangePasswordInput {
      old_password: String!
      new_password: String!
      confirm_password: String!
    }
  ''';
}

/// 地址输入
class AddressInput {
  static const String schema = '''
    input AddressInput {
      name: String!
      phone: String!
      province: String!
      city: String!
      district: String!
      address: String!
      postal_code: String
      is_default: Boolean = false
      tag: String
    }
  ''';
}

/// 购物车添加输入
class AddToCartInput {
  static const String schema = '''
    input AddToCartInput {
      product_id: ID!
      quantity: Int! = 1
      selected: Boolean = true
    }
  ''';
}

/// 积分查询输入
class PointsRecordQueryInput {
  static const String schema = '''
    input PointsRecordQueryInput {
      user_id: ID
      type: PointsType
      date_from: Date
      date_to: Date
      pagination: PaginationInput
    }
  ''';
}

/// 积分规则查询输入
class PointsRuleQueryInput {
  static const String schema = '''
    input PointsRuleQueryInput {
      type: PointsType
      is_active: Boolean
      pagination: PaginationInput
    }
  ''';
}

/// 积分兑换查询输入
class PointsExchangeQueryInput {
  static const String schema = '''
    input PointsExchangeQueryInput {
      exchange_type: ExchangeType
      status: ExchangeStatus
      points_range: IntRange
      pagination: PaginationInput
    }
    
    input IntRange {
      min: Int
      max: Int
    }
  ''';
}

/// =================================
/// 响应类型定义
/// =================================

/// 认证响应
class AuthResponse {
  static const String schema = '''
    type AuthResponse {
      success: Boolean!
      token: String
      refresh_token: String
      user: Member
      message: String
      expires_in: Int
    }
  ''';
}

/// 分页信息
class PaginationInfo {
  static const String schema = '''
    type PaginationInfo {
      current_page: Int!
      total_pages: Int!
      total_items: Int!
      has_more: Boolean!
      per_page: Int!
    }
  ''';
}

/// 积分记录列表响应
class PointsRecordsResponse {
  static const String schema = '''
    type PointsRecordsResponse {
      records: [PointsRecord!]!
      pagination: PaginationInfo!
      total: Int!
    }
  ''';
}

/// 积分规则列表响应
class PointsRulesResponse {
  static const String schema = '''
    type PointsRulesResponse {
      rules: [PointsRule!]!
      pagination: PaginationInfo!
      total: Int!
    }
  ''';
}

/// 积分兑换商品列表响应
class PointsExchangesResponse {
  static const String schema = '''
    type PointsExchangesResponse {
      exchanges: [PointsExchange!]!
      pagination: PaginationInfo!
      total: Int!
    }
  ''';
}

/// 收藏列表响应
class FavoritesResponse {
  static const String schema = '''
    type FavoritesResponse {
      favorites: [Favorite!]!
      pagination: PaginationInfo!
      total: Int!
    }
  ''';
}

/// 地址列表响应
class AddressList {
  static const String schema = '''
    type AddressList {
      addresses: [Address!]!
      default_address: Address
      total: Int!
    }
  ''';
}

/// =================================
/// 标量类型定义
/// =================================

class ScalarTypes {
  static const String schema = '''
    scalar Date
    scalar DateTime
    scalar JSON
    scalar Upload
  ''';
}

/// =================================
/// 完整Schema定义
/// =================================

class MemberModuleSchema {
  static String get fullSchema =>
      '''
    ${ScalarTypes.schema}
    
    ${PaginationInput.schema}
    ${QueryInput.schema}
    
    ${MemberType.schema}
    ${MemberLevelType.schema}
    ${PointsRecordType.schema}
    ${PointsRuleType.schema}
    ${PointsExchangeType.schema}
    ${PointsExchangeRecordType.schema}
    ${AddressType.schema}
    ${CartItemType.schema}
    ${CartInfoType.schema}
    ${FavoriteType.schema}
    ${MemberTagType.schema}
    ${NotificationType.schema}
    
    ${RegisterInput.schema}
    ${LoginInput.schema}
    ${WechatLoginInput.schema}
    ${ProfileUpdateInput.schema}
    ${ChangePasswordInput.schema}
    ${AddressInput.schema}
    ${AddToCartInput.schema}
    ${PointsRecordQueryInput.schema}
    ${PointsRuleQueryInput.schema}
    ${PointsExchangeQueryInput.schema}
    
    ${AuthResponse.schema}
    ${PaginationInfo.schema}
    ${PointsRecordsResponse.schema}
    ${PointsRulesResponse.schema}
    ${PointsExchangesResponse.schema}
    ${FavoritesResponse.schema}
    ${AddressList.schema}
  ''';
}
