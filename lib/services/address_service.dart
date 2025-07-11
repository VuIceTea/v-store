import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddressService {
  static const String _addressesKey = 'user_addresses';
  static const String _defaultAddressKey = 'default_address_key';

  static Future<Map<String, Map<String, String>>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_addressesKey);

      if (addressesJson != null) {
        final Map<String, dynamic> decoded = json.decode(addressesJson);
        return decoded.map(
          (key, value) => MapEntry(key, Map<String, String>.from(value as Map)),
        );
      }
    } catch (e) {
      print('Error loading addresses: $e');
    }

    return {
      'default': {
        'title': 'Địa chỉ mặc định',
        'name': 'Nguyen Phi Vu',
        'phone': '(+84) 123 456 789',
        'address':
            '123 Đường Lê Lợi, Phường Bến Nghé, Quận 1, Thành phố Hồ Chí Minh',
        'isDefault': 'true',
      },
      'company': {
        'title': 'Địa chỉ công ty',
        'name': 'Nguyễn Phi Vu',
        'phone': '(+84) 987 654 321',
        'address':
            '456 Đường Nguyễn Huệ, Phường Bến Nghé, Quận 1, Thành phố Hồ Chí Minh',
        'isDefault': 'false',
      },
    };
  }

  static Future<void> saveAddresses(
    Map<String, Map<String, String>> addresses,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = json.encode(addresses);
      await prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      print('Error saving addresses: $e');
    }
  }

  static Future<String> addAddress({
    required String title,
    required String name,
    required String phone,
    required String address,
    bool setAsDefault = false,
  }) async {
    final addresses = await getAddresses();
    final newAddressKey = 'address_${DateTime.now().millisecondsSinceEpoch}';

    if (setAsDefault) {
      for (var addr in addresses.values) {
        addr['isDefault'] = 'false';
      }
    }

    addresses[newAddressKey] = {
      'title': title,
      'name': name,
      'phone': phone,
      'address': address,
      'isDefault': setAsDefault ? 'true' : 'false',
    };

    await saveAddresses(addresses);

    if (setAsDefault) {
      await setDefaultAddress(newAddressKey);
    }

    return newAddressKey;
  }

  static Future<void> deleteAddress(String addressKey) async {
    final addresses = await getAddresses();
    final isDefault = addresses[addressKey]?['isDefault'] == 'true';

    addresses.remove(addressKey);

    if (isDefault && addresses.isNotEmpty) {
      final firstKey = addresses.keys.first;
      addresses[firstKey]!['isDefault'] = 'true';
      await setDefaultAddress(firstKey);
    }

    await saveAddresses(addresses);
  }

  static Future<void> setAddressAsDefault(String addressKey) async {
    final addresses = await getAddresses();

    for (var addr in addresses.values) {
      addr['isDefault'] = 'false';
    }

    if (addresses.containsKey(addressKey)) {
      addresses[addressKey]!['isDefault'] = 'true';
      await saveAddresses(addresses);
      await setDefaultAddress(addressKey);
    }
  }

  static Future<String> getDefaultAddressKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultKey = prefs.getString(_defaultAddressKey);

      if (defaultKey != null) {
        final addresses = await getAddresses();
        if (addresses.containsKey(defaultKey)) {
          return defaultKey;
        }
      }
    } catch (e) {
      print('Error getting default address key: $e');
    }

    return 'default';
  }

  static Future<void> setDefaultAddress(String addressKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_defaultAddressKey, addressKey);
    } catch (e) {
      print('Error setting default address: $e');
    }
  }

  static Future<Map<String, String>?> getDefaultAddress() async {
    final addresses = await getAddresses();
    final defaultKey = await getDefaultAddressKey();
    return addresses[defaultKey];
  }

  static Future<Map<String, String>?> getCurrentDefaultAddress() async {
    try {
      final defaultAddress = await getDefaultAddress();
      return defaultAddress;
    } catch (e) {
      print('Error getting current default address: $e');
      return null;
    }
  }

  static Future<bool> hasAddresses() async {
    try {
      final addresses = await getAddresses();
      return addresses.isNotEmpty;
    } catch (e) {
      print('Error checking addresses: $e');
      return false;
    }
  }
}
