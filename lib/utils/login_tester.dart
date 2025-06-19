import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/graphql_service.dart';

class LoginTester {
  /// 测试不同的登录凭据
  static Future<Map<String, dynamic>> testLoginCredentials() async {
    final results = <String, dynamic>{};

    // 测试用的凭据列表
    final testCredentials = [
      {'identity': 'test@example.com', 'password': 'test123'},
      {'identity': 'admin@example.com', 'password': 'admin123'},
      {'identity': 'user@test.com', 'password': 'password'},
      {'identity': 'demo@demo.com', 'password': 'demo123'},
      {'identity': 'test', 'password': 'test'},
      {'identity': 'admin', 'password': 'admin'},
      // 添加用户提供的凭据
      {'identity': 'test@example.com', 'password': 'kpyu1512'},
      {'identity': 'ahukpyu@outlook.com', 'password': 'kpyu1512..@'},
    ];

    for (int i = 0; i < testCredentials.length; i++) {
      final cred = testCredentials[i];
      debugPrint('🔐 测试凭据 ${i + 1}: ${cred['identity']}');

      try {
        final result = await GraphQLService.login(
          cred['identity']!,
          cred['password']!,
        );

        if (result != null) {
          results['success'] = {
            'credentials': cred,
            'user': result.user,
            'token': result.token.substring(0, 20) + '...',
          };
          debugPrint('✅ 成功找到有效凭据！');
          break;
        }
      } catch (e) {
        results['attempt_$i'] = {'credentials': cred, 'error': e.toString()};
        debugPrint('❌ 凭据 ${i + 1} 失败: ${e.toString().split(':').first}');
      }

      // 避免请求过快
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// 测试不同的mutation格式
  static Future<Map<String, dynamic>> testMutationFormats(
    String identity,
    String password,
  ) async {
    final results = <String, dynamic>{};

    // 不同的mutation格式
    final mutations = [
      {
        'name': 'login',
        'mutation': '''
          mutation Login(\$input: LoginInput!) {
            login(input: \$input) {
              token
              record {
                id
                email
                name
                avatar
              }
            }
          }
        ''',
        'responseField': 'login',
      },
      {
        'name': 'mobileLogin',
        'mutation': '''
          mutation MobileLogin(\$input: LoginInput!) {
            mobileLogin(input: \$input) {
              token
              record {
                id
                email
                name
                avatar
              }
            }
          }
        ''',
        'responseField': 'mobileLogin',
      },
      {
        'name': 'authenticate',
        'mutation': '''
          mutation Authenticate(\$input: LoginInput!) {
            authenticate(input: \$input) {
              token
              user {
                id
                email
                name
                avatar
              }
            }
          }
        ''',
        'responseField': 'authenticate',
      },
    ];

    for (final mutationConfig in mutations) {
      debugPrint('🔐 测试mutation: ${mutationConfig['name']}');

      try {
        final client = GraphQLService.client;

        final MutationOptions options = MutationOptions(
          document: gql(mutationConfig['mutation'] as String),
          variables: {
            'input': {'identity': identity, 'password': password},
          },
          fetchPolicy: FetchPolicy.noCache,
          errorPolicy: ErrorPolicy.all,
        );

        final QueryResult result = await client
            .mutate(options)
            .timeout(const Duration(seconds: 15));

        if (result.hasException) {
          results[mutationConfig['name'] as String] = {
            'success': false,
            'error': result.exception.toString(),
            'graphqlErrors': result.exception?.graphqlErrors
                ?.map((e) => e.message)
                .toList(),
          };
        } else {
          final responseField = mutationConfig['responseField'] as String;
          if (result.data != null && result.data![responseField] != null) {
            results[mutationConfig['name'] as String] = {
              'success': true,
              'data': result.data![responseField],
            };
            debugPrint('✅ ${mutationConfig['name']} 成功！');
          } else {
            results[mutationConfig['name'] as String] = {
              'success': false,
              'error': 'No data returned',
              'fullResponse': result.data,
            };
          }
        }
      } catch (e) {
        results[mutationConfig['name'] as String] = {
          'success': false,
          'error': e.toString(),
        };
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// 生成登录测试报告
  static String generateLoginReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('🔐 登录测试报告');
    buffer.writeln('=' * 40);

    if (results.containsKey('success')) {
      final success = results['success'] as Map<String, dynamic>;
      buffer.writeln('\n✅ 找到有效凭据:');
      buffer.writeln('   用户名: ${success['credentials']['identity']}');
      buffer.writeln('   用户信息: ${success['user']}');
      buffer.writeln('   Token: ${success['token']}');
    } else {
      buffer.writeln('\n❌ 未找到有效凭据');
      buffer.writeln('\n测试结果:');

      results.forEach((key, value) {
        if (key.startsWith('attempt_')) {
          final attempt = value as Map<String, dynamic>;
          buffer.writeln(
            '   ${attempt['credentials']['identity']}: ${attempt['error']}',
          );
        }
      });
    }

    return buffer.toString();
  }

  /// 生成mutation测试报告
  static String generateMutationReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('🔐 Mutation测试报告');
    buffer.writeln('=' * 40);

    results.forEach((mutationName, result) {
      final resultData = result as Map<String, dynamic>;
      buffer.writeln('\n$mutationName:');

      if (resultData['success'] == true) {
        buffer.writeln('   ✅ 成功');
        buffer.writeln('   数据: ${resultData['data']}');
      } else {
        buffer.writeln('   ❌ 失败');
        buffer.writeln('   错误: ${resultData['error']}');
        if (resultData['graphqlErrors'] != null) {
          buffer.writeln('   GraphQL错误: ${resultData['graphqlErrors']}');
        }
      }
    });

    return buffer.toString();
  }
}
