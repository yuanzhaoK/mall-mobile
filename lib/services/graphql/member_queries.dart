/// 会员模块GraphQL查询和变更定义

/// 包含会员管理、积分系统、等级体系等所有功能

class MemberGraphQLQueries {
  /// =================================
  /// 查询接口 (Query)
  /// =================================

  /// 获取积分兑换商品（用户端）
  static const String pointsExchanges = r'''
    query PointsExchanges($input: PointsExchangeQueryInput!) {
      pointsExchanges(input: $input) {
        exchanges {
          id
          name
          description
          image
          points_required
          exchange_type
          reward_value
          stock
          status
          sort_order
        }
        pagination {
          current_page
          total_pages
          total_items
          has_more
          per_page
        }
        total
      }
    }
  ''';

  /// =================================
  /// 移动端专用查询
  /// =================================

  /// 获取当前用户信息
  static const String appMember = '''
    query AppMember {
      appMember {
        id
        username
        email
        phone
        avatar
        real_name
        gender
        birthday
        level {
          id
          name
          description
          discount_rate
          benefits
          icon
          color
        }
        points
        balance
        total_orders
        total_amount
        status
        register_time
        last_login_time
        is_verified
      }
    }
  ''';

  /// 获取用户地址列表
  static const String appMemberAddresses = '''
    query AppMemberAddresses {
      appMemberAddresses {
        addresses {
          id
          name
          phone
          province
          city
          district
          address
          postal_code
          is_default
          tag
          created
          updated
        }
        default_address {
          id
          name
          phone
          province
          city
          district
          address
          postal_code
          is_default
          tag
        }
        total
      }
    }
  ''';

  /// 获取购物车信息
  static const String appMemberCart = '''
    query AppMemberCart {
      appMemberCart {
        items {
          id
          product {
            id
            name
            price
            image_url
            stock
          }
          quantity
          price
          selected
          created
          updated
        }
        total_items
        total_amount
        selected_amount
        selected_items
      }
    }
  ''';

  /// 获取用户订单列表
  static const String memberOrders = r'''
    query MemberOrders($query: OrderQueryInput!) {
      memberOrders(query: $query) {
        orders {
          id
          order_number
          status
          total_amount
          discount_amount
          final_amount
          payment_method
          payment_status
          created_at
          items {
            id
            product_name
            product_image
            quantity
            price
            total_price
          }
        }
        pagination {
          current_page
          total_pages
          total_items
          has_more
          per_page
        }
        total
      }
    }
  ''';

  /// 获取用户收藏列表
  static const String memberFavorites = r'''
    query MemberFavorites($input: QueryInput!) {
      memberFavorites(input: $input) {
        favorites {
          id
          product {
            id
            name
            price
            original_price
            image_url
            rating
            sales_count
          }
          created
        }
        pagination {
          current_page
          total_pages
          total_items
          has_more
          per_page
        }
        total
      }
    }
  ''';

  /// 获取推荐商品
  static const String recommendedProducts = r'''
    query RecommendedProducts($limit: Int = 10) {
      recommendedProducts(limit: $limit) {
        id
        name
        price
        original_price
        image_url
        rating
        sales_count
        category_id
        description
        tags
      }
    }
  ''';
}

class MemberGraphQLMutations {
  /// =================================
  /// 用户认证和资料管理
  /// =================================

  /// 用户注册
  static const String registerMember = r'''
    mutation RegisterMember($input: RegisterInput!) {
      registerMember(input: $input) {
        success
        token
        refresh_token
        user {
          id
          username
          email
          phone
          avatar
          level {
            id
            name
            color
          }
          points
          balance
        }
        message
        expires_in
      }
    }
  ''';

  /// 用户登录
  static const String login = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        success
        token
        refresh_token
        user {
          id
          username
          email
          phone
          avatar
          level {
            id
            name
            color
          }
          points
          balance
        }
        message
        expires_in
      }
    }
  ''';

  /// 微信登录
  static const String wechatLogin = r'''
    mutation WechatLogin($input: WechatLoginInput!) {
      wechatLogin(input: $input) {
        success
        token
        refresh_token
        user {
          id
          username
          email
          phone
          avatar
          level {
            id
            name
            color
          }
          points
          balance
          wechat_openid
          wechat_unionid
        }
        message
        expires_in
      }
    }
  ''';

  /// 更新个人信息
  static const String updateProfile = r'''
    mutation UpdateProfile($input: ProfileUpdateInput!) {
      updateProfile(input: $input) {
        id
        username
        email
        phone
        avatar
        real_name
        gender
        birthday
        level {
          id
          name
          color
        }
        points
        balance
        updated
      }
    }
  ''';

  /// 修改密码
  static const String changePassword = r'''
    mutation ChangePassword($input: ChangePasswordInput!) {
      changePassword(input: $input)
    }
  ''';

  /// =================================
  /// 地址管理
  /// =================================

  /// 添加收货地址
  static const String addAddress = r'''
    mutation AddAddress($input: AddressInput!) {
      addAddress(input: $input) {
        id
        name
        phone
        province
        city
        district
        address
        postal_code
        is_default
        tag
        created
      }
    }
  ''';

  /// 更新收货地址
  static const String updateAddress = r'''
    mutation UpdateAddress($id: ID!, $input: AddressInput!) {
      updateAddress(id: $id, input: $input) {
        id
        name
        phone
        province
        city
        district
        address
        postal_code
        is_default
        tag
        updated
      }
    }
  ''';

  /// 删除收货地址
  static const String deleteAddress = r'''
    mutation DeleteAddress($id: ID!) {
      deleteAddress(id: $id)
    }
  ''';

  /// 设置默认地址
  static const String setDefaultAddress = r'''
    mutation SetDefaultAddress($id: ID!) {
      setDefaultAddress(id: $id)
    }
  ''';

  /// =================================
  /// 购物车管理
  /// =================================

  /// 添加到购物车
  static const String addToCart = r'''
    mutation AddToCart($input: AddToCartInput!) {
      addToCart(input: $input) {
        items {
          id
          product {
            id
            name
            price
            image_url
          }
          quantity
          price
          selected
        }
        total_items
        total_amount
        selected_amount
        selected_items
      }
    }
  ''';

  /// 更新购物车商品
  static const String updateCartItem = r'''
    mutation UpdateCartItem($id: ID!, $quantity: Int!) {
      updateCartItem(id: $id, quantity: $quantity) {
        items {
          id
          quantity
          price
          selected
        }
        total_items
        total_amount
        selected_amount
        selected_items
      }
    }
  ''';

  /// 删除购物车商品
  static const String removeFromCart = r'''
    mutation RemoveFromCart($id: ID!) {
      removeFromCart(id: $id) {
        items {
          id
          quantity
        }
        total_items
        total_amount
        selected_amount
        selected_items
      }
    }
  ''';

  /// 清空购物车
  static const String clearCart = '''
    mutation ClearCart {
      clearCart
    }
  ''';

  /// =================================
  /// 收藏管理
  /// =================================

  /// 添加收藏
  static const String addToFavorites = r'''
    mutation AddToFavorites($product_id: ID!) {
      addToFavorites(product_id: $product_id)
    }
  ''';

  /// 取消收藏
  static const String removeFromFavorites = r'''
    mutation RemoveFromFavorites($product_id: ID!) {
      removeFromFavorites(product_id: $product_id)
    }
  ''';

  /// 批量取消收藏
  static const String batchRemoveFavorites = r'''
    mutation BatchRemoveFavorites($product_ids: [ID!]!) {
      batchRemoveFavorites(product_ids: $product_ids)
    }
  ''';

  /// =================================
  /// 积分操作
  /// =================================

  /// 签到获得积分
  static const String dailyCheckIn = '''
    mutation DailyCheckIn {
      dailyCheckIn {
        id
        type
        points
        balance
        reason
        created
      }
    }
  ''';

  /// 兑换积分商品
  static const String exchangePoints = r'''
    mutation ExchangePoints($exchange_id: ID!) {
      exchangePoints(exchange_id: $exchange_id) {
        id
        user_id
        username
        exchange {
          id
          name
          points_required
          exchange_type
        }
        points_cost
        reward_type
        reward_value
        status
        created
      }
    }
  ''';

  /// =================================
  /// 社交功能
  /// =================================

  /// 关注用户
  static const String followMember = r'''
    mutation FollowMember($user_id: ID!) {
      followMember(user_id: $user_id)
    }
  ''';

  /// 取消关注
  static const String unfollowMember = r'''
    mutation UnfollowMember($user_id: ID!) {
      unfollowMember(user_id: $user_id)
    }
  ''';

  /// 分享商品
  static const String shareProduct = r'''
    mutation ShareProduct($product_id: ID!, $platform: String!) {
      shareProduct(product_id: $product_id, platform: $platform)
    }
  ''';
}

class MemberGraphQLSubscriptions {
  /// =================================
  /// 订阅接口 (Subscription)
  /// =================================

  /// 用户消息通知
  static const String memberNotifications = r'''
    subscription MemberNotifications($user_id: ID!) {
      memberNotifications(user_id: $user_id) {
        id
        user_id
        title
        content
        type
        data
        is_read
        created
      }
    }
  ''';

  /// 积分变动通知
  static const String pointsUpdated = r'''
    subscription PointsUpdated($user_id: ID!) {
      pointsUpdated(user_id: $user_id) {
        id
        type
        points
        balance
        reason
        created
      }
    }
  ''';

  /// 订单状态更新
  static const String orderStatusUpdated = r'''
    subscription OrderStatusUpdated($user_id: ID!) {
      orderStatusUpdated(user_id: $user_id) {
        id
        order_number
        status
        updated_at
      }
    }
  ''';

  /// 系统公告
  static const String systemAnnouncements = '''
    subscription SystemAnnouncements {
      systemAnnouncements {
        id
        title
        content
        type
        created
      }
    }
  ''';
}
