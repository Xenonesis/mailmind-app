import 'dart:convert';
import 'dart:io';

// Simple API test to verify backend connection
void main() async {
  const baseUrl = 'http://localhost:3000/api';
  
  print('🧪 Testing MailMind Backend API Connection...\n');
  
  // Test 1: Register a new user
  print('📝 Test 1: User Registration');
  try {
    final registerData = {
      'email': 'test@mailmind.app',
      'password': 'testpassword123',
      'name': 'Test User'
    };
    
    final registerResponse = await _makeRequest(
      'POST', 
      '$baseUrl/auth/register', 
      body: registerData
    );
    
    if (registerResponse['success']) {
      print('✅ Registration successful');
      print('   Token: ${registerResponse['data']['access_token']?.substring(0, 20)}...');
      print('   User: ${registerResponse['data']['user']['name']}');
    } else {
      print('❌ Registration failed: ${registerResponse['error']}');
    }
  } catch (e) {
    print('❌ Registration error: $e');
  }
  
  print('\n' + '='*50 + '\n');
  
  // Test 2: Login with the same user
  print('🔐 Test 2: User Login');
  try {
    final loginData = {
      'email': 'test@mailmind.app',
      'password': 'testpassword123'
    };
    
    final loginResponse = await _makeRequest(
      'POST', 
      '$baseUrl/auth/login', 
      body: loginData
    );
    
    if (loginResponse['success']) {
      print('✅ Login successful');
      final token = loginResponse['data']['access_token'];
      print('   Token: ${token?.substring(0, 20)}...');
      print('   User: ${loginResponse['data']['user']['name']}');
      
      // Test 3: Get user profile with token
      print('\n👤 Test 3: Get User Profile');
      final profileResponse = await _makeRequest(
        'GET', 
        '$baseUrl/user/profile',
        headers: {'Authorization': 'Bearer $token'}
      );
      
      if (profileResponse['success']) {
        print('✅ Profile fetch successful');
        print('   Name: ${profileResponse['data']['name']}');
        print('   Email: ${profileResponse['data']['email']}');
      } else {
        print('❌ Profile fetch failed: ${profileResponse['error']}');
      }
      
      // Test 4: Get user settings
      print('\n⚙️ Test 4: Get User Settings');
      final settingsResponse = await _makeRequest(
        'GET', 
        '$baseUrl/user/settings',
        headers: {'Authorization': 'Bearer $token'}
      );
      
      if (settingsResponse['success']) {
        print('✅ Settings fetch successful');
        print('   Settings: ${settingsResponse['data']}');
      } else {
        print('❌ Settings fetch failed: ${settingsResponse['error']}');
      }
      
      // Test 5: Get emails
      print('\n📧 Test 5: Get Emails');
      final emailsResponse = await _makeRequest(
        'GET', 
        '$baseUrl/emails',
        headers: {'Authorization': 'Bearer $token'}
      );
      
      if (emailsResponse['success']) {
        print('✅ Emails fetch successful');
        print('   Email count: ${emailsResponse['data']?.length ?? 0}');
      } else {
        print('❌ Emails fetch failed: ${emailsResponse['error']}');
      }
      
    } else {
      print('❌ Login failed: ${loginResponse['error']}');
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
  
  print('\n' + '='*50);
  print('🏁 API Testing Complete!');
}

Future<Map<String, dynamic>> _makeRequest(
  String method, 
  String url, {
  Map<String, dynamic>? body,
  Map<String, String>? headers,
}) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse(url);
    
    late HttpClientRequest request;
    switch (method.toUpperCase()) {
      case 'GET':
        request = await client.getUrl(uri);
        break;
      case 'POST':
        request = await client.postUrl(uri);
        break;
      case 'PUT':
        request = await client.putUrl(uri);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
    
    // Set headers
    request.headers.set('Content-Type', 'application/json');
    if (headers != null) {
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    
    // Add body if provided
    if (body != null) {
      request.write(jsonEncode(body));
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    client.close();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': jsonDecode(responseBody),
        'statusCode': response.statusCode,
      };
    } else {
      return {
        'success': false,
        'error': responseBody,
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
      'statusCode': 0,
    };
  }
}
