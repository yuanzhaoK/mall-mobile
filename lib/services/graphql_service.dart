import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/api_models.dart';

class GraphQLService {
  // 使用确认可用的GraphQL端点
  static String get _endpoint {
    // 直接使用确认可用的端点
    const endpoint = 'http://10.241.25.183:8082/graphql';
    debugPrint('🔗 GraphQL使用端点: $endpoint');
    return endpoint;
  }

  static GraphQLClient? _client;

  static GraphQLClient get client {
    if (_client == null) {
      final HttpLink httpLink = HttpLink(_endpoint);

      _client = GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      );

      debugPrint('🔗 GraphQL客户端已配置，端点: $_endpoint');
    }
    return _client!;
  }

  // GraphQL查询语句
  static const String _homeDataQuery = '''
    query {
      appHomeData {
        featured_products { id name price }
        categories { id name, created, description }
      }
    }
  ''';

  // 获取首页数据
  static Future<AppHomeData?> getHomeData() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_homeDataQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        // 在生产环境中，应该使用适当的日志系统替代print
        debugPrint('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data != null && result.data!['appHomeData'] != null) {
        return AppHomeData.fromJson(result.data!['appHomeData']);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      return null;
    }
  }
}
