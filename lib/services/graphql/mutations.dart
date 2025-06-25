/// GraphQL变更语句集合
class GraphQLMutations {
  /// 用户登录
  static const String login = r'''
    mutation mobileLogin($input: LoginInput!) {
      mobileLogin(input: $input) {
        token
        record {
          id
          email
          identity
          avatar
        }
      }
    }
  ''';

  /// 用户注册
  static const String register = r'''
    mutation Register($input: RegisterInput!) {
      register(input: $input) {
        token
        record {
          id
          email
          identity
          avatar
        }
      }
    }
  ''';

  /// 用户注销
  static const String logout = '''
    mutation Logout {
      logout
    }
  ''';

  /// 更新用户资料
  static const String updateProfile = r'''
    mutation UpdateProfile($input: UpdateProfileInput!) {
      updateProfile(input: $input) {
        id
        identity
        email
        avatar
        member_level
        points
        balance
      }
    }
  ''';

  /// 修改密码
  static const String changePassword = r'''
    mutation ChangePassword($input: ChangePasswordInput!) {
      changePassword(input: $input) {
        success
        message
      }
    }
  ''';

  /// 添加商品到购物车
  static const String addToCart = r'''
    mutation AddToCart($input: AddToCartInput!) {
      addToCart(input: $input) {
        id
        quantity
        total_price
        cart_total_items
      }
    }
  ''';

  /// 更新购物车商品数量
  static const String updateCartItem = r'''
    mutation UpdateCartItem($input: UpdateCartItemInput!) {
      updateCartItem(input: $input) {
        id
        quantity
        total_price
        cart_total_items
      }
    }
  ''';

  /// 从购物车移除商品
  static const String removeFromCart = r'''
    mutation RemoveFromCart(\$input: RemoveFromCartInput!) {
      removeFromCart(input: \$input) {
        success
        cart_total_items
      }
    }
  ''';

  /// 清空购物车
  static const String clearCart = '''
    mutation ClearCart {
      clearCart {
        success
      }
    }
  ''';

  /// 创建订单
  static const String createOrder = r'''
    mutation CreateOrder($input: CreateOrderInput!) {
      createOrder(input: $input) {
        id
        order_number
        status
        total_amount
        payment_url
      }
    }
  ''';

  /// 取消订单
  static const String cancelOrder = r'''
    mutation CancelOrder($input: CancelOrderInput!) {
      cancelOrder(input: $input) {
        id
        status
        cancelled_at
      }
    }
  ''';

  /// 确认收货
  static const String confirmDelivery = r'''
    mutation ConfirmDelivery($input: ConfirmDeliveryInput!) {
      confirmDelivery(input: $input) {
        id
        status
        delivered_at
      }
    }
  ''';

  /// 申请退款
  static const String requestRefund = r'''
    mutation RequestRefund($input: RefundRequestInput!) {
      requestRefund(input: $input) {
        id
        refund_id
        status
        amount
        reason
      }
    }
  ''';

  /// 添加商品评价
  static const String addReview = r'''
    mutation AddReview($input: AddReviewInput!) {
      addReview(input: $input) {
        id
        rating
        content
        created_at
      }
    }
  ''';

  /// 添加/移除收藏
  static const String toggleFavorite = r'''
    mutation ToggleFavorite($input: ToggleFavoriteInput!) {
      toggleFavorite(input: $input) {
        success
        is_favorited
        message
      }
    }
  ''';

  /// 添加收货地址
  static const String addAddress = r'''
    mutation AddAddress($input: AddAddressInput!) {
      addAddress(input: $input) {
        id
        name
        phone
        address
        city
        province
        postal_code
        is_default
      }
    }
  ''';

  /// 更新收货地址
  static const String updateAddress = r'''
    mutation UpdateAddress($input: UpdateAddressInput!) {
      updateAddress(input: $input) {
        id
        name
        phone
        address
        city
        province
        postal_code
        is_default
      }
    }
  ''';

  /// 删除收货地址
  static const String deleteAddress = r'''
    mutation DeleteAddress($input: DeleteAddressInput!) {
      deleteAddress(input: $input) {
        success
        message
      }
    }
  ''';

  /// 设置默认地址
  static const String setDefaultAddress = r'''
    mutation SetDefaultAddress($input: SetDefaultAddressInput!) {
      setDefaultAddress(input: $input) {
        id
        is_default
      }
    }
  ''';

  /// 使用优惠券
  static const String useCoupon = r'''
    mutation UseCoupon($input: UseCouponInput!) {
      useCoupon(input: $input) {
        id
        discount_amount
        final_amount
      }
    }
  ''';

  /// 领取优惠券
  static const String claimCoupon = r'''
    mutation ClaimCoupon($input: ClaimCouponInput!) {
      claimCoupon(input: $input) {
        id
        name
        discount_amount
        end_date
      }
    }
  ''';

  /// 标记通知为已读
  static const String markNotificationRead = r'''
    mutation MarkNotificationRead($input: MarkNotificationReadInput!) {
      markNotificationRead(input: $input) {
        success
        unread_count
      }
    }
  ''';

  /// 删除通知
  static const String deleteNotification = r'''
    mutation DeleteNotification($input: DeleteNotificationInput!) {
      deleteNotification(input: $input) {
        success
      }
    }
  ''';

  /// 上传文件
  static const String uploadFile = r'''
    mutation UploadFile($file: Upload!) {
      uploadFile(file: $file) {
        url
        filename
        size
        mime_type
      }
    }
  ''';

  /// 发送验证码
  static const String sendVerificationCode = r'''
    mutation SendVerificationCode($input: SendVerificationCodeInput!) {
      sendVerificationCode(input: $input) {
        success
        message
        expires_at
      }
    }
  ''';

  /// 验证验证码
  static const String verifyCode = r'''
    mutation VerifyCode($input: VerifyCodeInput!) {
      verifyCode(input: $input) {
        success
        token
        message
      }
    }
  ''';

  /// 重置密码
  static const String resetPassword = r'''
    mutation ResetPassword($input: ResetPasswordInput!) {
      resetPassword(input: $input) {
        success
        message
      }
    }
  ''';

  /// 绑定第三方账号
  static const String bindThirdParty = r'''
    mutation BindThirdParty($input: BindThirdPartyInput!) {
      bindThirdParty(input: $input) {
        success
        provider
        message
      }
    }
  ''';

  /// 解绑第三方账号
  static const String unbindThirdParty = r'''
    mutation UnbindThirdParty($input: UnbindThirdPartyInput!) {
      unbindThirdParty(input: $input) {
        success
        message
      }
    }
  ''';
}
