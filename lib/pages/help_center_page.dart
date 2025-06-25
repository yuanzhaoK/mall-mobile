import 'package:flutter/material.dart';

import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/widgets/simple_app_bar.dart';

/// 帮助中心页面
class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 帮助分类
  final List<HelpCategory> _categories = [
    HelpCategory(
      id: 'order',
      title: '订单相关',
      icon: Icons.shopping_bag_outlined,
      color: Colors.blue,
      questions: [
        HelpQuestion(
          question: '如何取消订单？',
          answer: '您可以在订单详情页面点击"取消订单"按钮，或者联系客服协助取消。注意：已发货的订单无法取消。',
        ),
        HelpQuestion(
          question: '订单状态说明',
          answer: '待付款：订单已提交，等待付款\n待发货：订单已付款，商家准备发货\n待收货：订单已发货，等待收货\n已完成：订单已完成',
        ),
        HelpQuestion(
          question: '如何修改收货地址？',
          answer: '订单未发货前，您可以在订单详情页面修改收货地址。已发货订单无法修改地址。',
        ),
      ],
    ),
    HelpCategory(
      id: 'payment',
      title: '支付相关',
      icon: Icons.payment_outlined,
      color: Colors.green,
      questions: [
        HelpQuestion(
          question: '支持哪些支付方式？',
          answer: '我们支持微信支付、支付宝、银行卡支付等多种支付方式，选择您方便的方式即可。',
        ),
        HelpQuestion(
          question: '支付失败怎么办？',
          answer: '如果支付失败，请检查网络连接和支付账户余额，或尝试更换支付方式。如仍有问题，请联系客服。',
        ),
        HelpQuestion(
          question: '如何申请退款？',
          answer: '在订单详情页面点击"申请退款"，填写退款原因，我们会在3-7个工作日内处理您的退款申请。',
        ),
      ],
    ),
    HelpCategory(
      id: 'shipping',
      title: '物流配送',
      icon: Icons.local_shipping_outlined,
      color: Colors.orange,
      questions: [
        HelpQuestion(
          question: '配送时间说明',
          answer: '一般情况下，订单会在24小时内发货，配送时间为1-3个工作日（偏远地区可能延长）。',
        ),
        HelpQuestion(
          question: '如何查看物流信息？',
          answer: '在订单详情页面可以查看详细的物流跟踪信息，包括快递公司和运单号。',
        ),
        HelpQuestion(
          question: '配送费用说明',
          answer: '订单满99元免运费，不满99元收取8元运费。部分偏远地区可能收取额外费用。',
        ),
      ],
    ),
    HelpCategory(
      id: 'account',
      title: '账户安全',
      icon: Icons.security_outlined,
      color: Colors.purple,
      questions: [
        HelpQuestion(
          question: '如何修改密码？',
          answer: '在个人中心-设置-账户安全中可以修改登录密码，建议定期更换密码保证账户安全。',
        ),
        HelpQuestion(
          question: '忘记密码怎么办？',
          answer: '在登录页面点击"忘记密码"，通过手机验证码或邮箱验证重置密码。',
        ),
        HelpQuestion(
          question: '账户被锁定怎么办？',
          answer: '如果账户被锁定，请联系客服提供相关信息进行身份验证，我们会尽快为您解锁。',
        ),
      ],
    ),
    HelpCategory(
      id: 'product',
      title: '商品相关',
      icon: Icons.inventory_2_outlined,
      color: Colors.teal,
      questions: [
        HelpQuestion(
          question: '如何查看商品详情？',
          answer: '点击商品卡片即可查看详细信息，包括规格、参数、评价等。',
        ),
        HelpQuestion(
          question: '商品质量问题',
          answer: '如果收到的商品有质量问题，请在收货后7天内联系客服，我们提供免费退换货服务。',
        ),
        HelpQuestion(
          question: '如何收藏商品？',
          answer: '在商品详情页面点击爱心图标即可收藏，收藏的商品可在个人中心查看。',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: '帮助中心', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(),

          // 内容区域
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildCategoryList()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索帮助内容...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// 构建分类列表
  Widget _buildCategoryList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 常见问题
          _buildPopularQuestions(),
          const SizedBox(height: 16),

          // 帮助分类
          ..._categories.map((category) => _buildCategoryCard(category)),
          const SizedBox(height: 16),

          // 联系客服
          _buildContactCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建热门问题
  Widget _buildPopularQuestions() {
    final popularQuestions = ['如何取消订单？', '支付失败怎么办？', '如何查看物流信息？', '如何申请退款？'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.whatshot, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                '热门问题',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...popularQuestions.map((question) => _buildQuestionTile(question)),
        ],
      ),
    );
  }

  /// 构建分类卡片
  Widget _buildCategoryCard(HelpCategory category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(category.icon, color: category.color, size: 20),
        ),
        title: Text(
          category.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${category.questions.length} 个问题',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        children: category.questions.map((question) {
          return _buildQuestionAnswerTile(question);
        }).toList(),
      ),
    );
  }

  /// 构建问题标题
  Widget _buildQuestionTile(String question) {
    return GestureDetector(
      onTap: () => _showQuestionDetail(question),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建问题答案条目
  Widget _buildQuestionAnswerTile(HelpQuestion helpQuestion) {
    return ExpansionTile(
      title: Text(
        helpQuestion.question,
        style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            helpQuestion.answer,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建联系客服卡片
  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            '还有其他问题？',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '我们的客服团队随时为您提供帮助',
            style: TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _contactCustomerService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('在线客服'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _callCustomerService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('电话客服'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    final results = _searchQuestions(_searchQuery);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到相关内容',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试使用其他关键词搜索',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildQuestionAnswerTile(result),
        );
      },
    );
  }

  /// 搜索问题
  List<HelpQuestion> _searchQuestions(String query) {
    if (query.isEmpty) return [];

    final results = <HelpQuestion>[];
    for (final category in _categories) {
      for (final question in category.questions) {
        if (question.question.toLowerCase().contains(query.toLowerCase()) ||
            question.answer.toLowerCase().contains(query.toLowerCase())) {
          results.add(question);
        }
      }
    }
    return results;
  }

  /// 显示问题详情
  void _showQuestionDetail(String question) {
    // 查找问题详情
    HelpQuestion? foundQuestion;
    for (final category in _categories) {
      for (final q in category.questions) {
        if (q.question == question) {
          foundQuestion = q;
          break;
        }
      }
      if (foundQuestion != null) break;
    }

    if (foundQuestion != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(foundQuestion!.question),
          content: Text(foundQuestion.answer),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  /// 联系在线客服
  void _contactCustomerService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomerServicePage()),
    );
  }

  /// 拨打客服电话
  void _callCustomerService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('客服电话'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('客服热线：400-123-4567'),
            SizedBox(height: 8),
            Text('服务时间：9:00-18:00'),
            SizedBox(height: 8),
            Text('节假日：10:00-16:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以集成拨打电话功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('拨打电话功能即将推出'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('拨打'),
          ),
        ],
      ),
    );
  }
}

/// 帮助分类模型
class HelpCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<HelpQuestion> questions;

  HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

/// 帮助问题模型
class HelpQuestion {
  final String question;
  final String answer;

  HelpQuestion({required this.question, required this.answer});
}

/// 客服页面
class CustomerServicePage extends StatefulWidget {
  const CustomerServicePage({super.key});

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      content: '您好！欢迎使用在线客服，有什么可以帮助您的吗？',
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: '在线客服', showBackButton: true),
      body: Column(
        children: [
          // 客服状态
          _buildServiceStatus(),

          // 聊天消息列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // 输入框
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 构建客服状态
  Widget _buildServiceStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '客服在线',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            '平均响应时间：2分钟',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: message.isFromUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isFromUser
                        ? AppColors.primary
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromUser
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (message.isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.surfaceVariant,
              radius: 16,
              child: const Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 发送消息
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          content: message,
          isFromUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // 模拟客服回复
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              content: '收到您的消息，我正在为您处理，请稍等...',
              isFromUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 聊天消息模型
class ChatMessage {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });
}
