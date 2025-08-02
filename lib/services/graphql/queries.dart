/// GraphQL查询语句集合
class GraphQLQueries {
  /// 首页数据查询
  static const String homeData = '''
    query AppHomeData {
      appHomeData {
        banners {
          id title image_url link_url link_type target_type description
        }
        featured_products {
          id 
          name 
          price 
          original_price 
          image_url 
          rating 
          sales_count
        }
        trending_items {
          id
          name
          image_url
          score
          type
        }
        recommendations {
          id
          name
          type
          position
          products {
            id
            name
            price
            original_price
            image_url
            rating
            sales_count
          }
        }
        advertisements {
          id
          title
          image_url
          link_url
          position
          type
        }
        categories {
          id
          name
          icon_url 
          product_count
        }
      }
    }
  ''';

  /// 用户资料查询
  static const String userProfile = '''
    query AppProfile {
      appProfile {
        id
        email
        avatar
        points
        balance
      }
    }
  ''';

  /// 购物车数量查询
  static const String cartCount = '''
    query AppCartCount {
      appCart {
        total_items
      }
    }
  ''';

  /// 商品列表查询
  static const String productList = r'''
    query ProductList($input: ProductListInput!) {
      productList(input: $input) {
        products {
          id
          name
          price
          original_price
          image_url
          rating
          sales_count
          category_id
          description
          is_hot
          is_new
          tags
        }
        pagination {
          current_page
          total_pages
          total_items
          has_more
        }
      }
    }
  ''';

  /// 商品详情查询
  static const String productDetail = r'''
    query ProductDetail($id: ID!) {
      productDetail(id: $id) {
        id
        name
        price
        original_price
        images
        description
        rating
        sales_count
        category_id
        specifications {
          name
          value
        }
        reviews {
          id
          user_name
          rating
          content
          created_at
        }
        related_products {
          id
          name
          price
          image_url
          rating
        }
      }
    }
  ''';

  /// 搜索商品查询
  static const String searchProducts = r'''
    query SearchProducts($input: SearchInput!) {
      searchProducts(input: $input) {
        products {
          id
          name
          price
          original_price
          image_url
          rating
          sales_count
        }
        suggestions
        total_count
        pagination {
          current_page
          total_pages
          has_more
        }
      }
    }
  ''';

  /// 分类列表查询
  static const String categories = '''
    query Categories {
      categories {
        id
        name
        icon_url
        product_count
        parent_id
        children {
          id
          name
          product_count
        }
      }
    }
  ''';

  /// 购物车详情查询
  static const String cartDetails = '''
    query CartDetails {
      cart {
        items {
          id
          product {
            id
            name
            price
            image_url
          }
          quantity
          unit_price
          total_price
        }
        total_items
        total_price
        shipping_fee
        discount_amount
      }
    }
  ''';

  /// 订单列表查询
  static const String orderList = r'''
    query OrderList($input: OrderListInput!) {
      orderList(input: $input) {
        orders {
          id
          order_number
          status
          total_amount
          created_at
          items {
            id
            product_name
            quantity
            unit_price
            image_url
          }
        }
        pagination {
          current_page
          total_pages
          has_more
        }
      }
    }
  ''';

  /// 订单详情查询
  static const String orderDetail = r'''
    query OrderDetail($id: ID!) {
      orderDetail(id: $id) {
        id
        order_number
        status
        total_amount
        shipping_fee
        discount_amount
        created_at
        updated_at
        shipping_address {
          name
          phone
          address
          city
          province
          postal_code
        }
        items {
          id
          product_name
          quantity
          unit_price
          total_price
          image_url
        }
        payment_info {
          method
          status
          paid_at
        }
        shipping_info {
          carrier
          tracking_number
          shipped_at
          delivered_at
        }
      }
    }
  ''';

  /// 用户收藏列表查询
  static const String favoriteList = r'''
    query FavoriteList($input: FavoriteListInput!) {
      favoriteList(input: $input) {
        items {
          id
          type
          product {
            id
            name
            price
            original_price
            image_url
            rating
            sales_count
          }
          store {
            id
            name
            logo
            rating
          }
          created_at
        }
        pagination {
          current_page
          total_pages
          has_more
        }
      }
    }
  ''';

  /// 地址列表查询
  static const String addressList = '''
    query AddressList {
      addressList {
        id
        name
        phone
        address
        city
        province
        postal_code
        is_default
        created_at
      }
    }
  ''';

  /// 优惠券列表查询
  static const String couponList = r'''
    query CouponList($status: CouponStatus) {
      couponList(status: $status) {
        id
        name
        description
        type
        discount_amount
        min_amount
        start_date
        end_date
        status
        usage_count
        usage_limit
      }
    }
  ''';

  /// 通知列表查询
  static const String notificationList = r'''
    query NotificationList($input: NotificationListInput!) {
      notificationList(input: $input) {
        notifications {
          id
          title
          content
          type
          is_read
          created_at
          data
        }
        unread_count
        pagination {
          current_page
          total_pages
          has_more
        }
      }
    }
  ''';
}
