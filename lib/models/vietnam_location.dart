class Province {
  final String code;
  final String name;
  final List<District> districts;

  Province({required this.code, required this.name, required this.districts});
}

class District {
  final String code;
  final String name;
  final String provinceCode;
  final List<Ward> wards;

  District({
    required this.code,
    required this.name,
    required this.provinceCode,
    required this.wards,
  });
}

class Ward {
  final String code;
  final String name;
  final String districtCode;

  Ward({required this.code, required this.name, required this.districtCode});
}

class VietnamLocationData {
  static List<Province> provinces = [
    Province(
      code: "01",
      name: "Thành phố Hà Nội",
      districts: [
        District(
          code: "001",
          name: "Quận Ba Đình",
          provinceCode: "01",
          wards: [
            Ward(code: "00001", name: "Phường Phúc Xá", districtCode: "001"),
            Ward(code: "00002", name: "Phường Trúc Bạch", districtCode: "001"),
            Ward(code: "00003", name: "Phường Vĩnh Phúc", districtCode: "001"),
            Ward(code: "00004", name: "Phường Cống Vị", districtCode: "001"),
            Ward(code: "00005", name: "Phường Liễu Giai", districtCode: "001"),
          ],
        ),
        District(
          code: "002",
          name: "Quận Hoàn Kiếm",
          provinceCode: "01",
          wards: [
            Ward(code: "00006", name: "Phường Phúc Tân", districtCode: "002"),
            Ward(code: "00007", name: "Phường Đồng Xuân", districtCode: "002"),
            Ward(code: "00008", name: "Phường Hàng Mã", districtCode: "002"),
            Ward(code: "00009", name: "Phường Hàng Buồm", districtCode: "002"),
            Ward(code: "00010", name: "Phường Hàng Đào", districtCode: "002"),
          ],
        ),
        District(
          code: "003",
          name: "Quận Hai Bà Trưng",
          provinceCode: "01",
          wards: [
            Ward(code: "00011", name: "Phường Nguyễn Du", districtCode: "003"),
            Ward(
              code: "00012",
              name: "Phường Bùi Thị Xuân",
              districtCode: "003",
            ),
            Ward(
              code: "00013",
              name: "Phường Lê Đại Hành",
              districtCode: "003",
            ),
            Ward(code: "00014", name: "Phường Đồng Nhân", districtCode: "003"),
            Ward(
              code: "00015",
              name: "Phường Phạm Đình Hổ",
              districtCode: "003",
            ),
          ],
        ),
      ],
    ),
    Province(
      code: "79",
      name: "Thành phố Hồ Chí Minh",
      districts: [
        District(
          code: "760",
          name: "Quận 1",
          provinceCode: "79",
          wards: [
            Ward(code: "26734", name: "Phường Tân Định", districtCode: "760"),
            Ward(code: "26737", name: "Phường Đa Kao", districtCode: "760"),
            Ward(code: "26740", name: "Phường Bến Nghé", districtCode: "760"),
            Ward(code: "26743", name: "Phường Bến Thành", districtCode: "760"),
            Ward(
              code: "26746",
              name: "Phường Nguyễn Thái Bình",
              districtCode: "760",
            ),
          ],
        ),
        District(
          code: "761",
          name: "Quận 3",
          provinceCode: "79",
          wards: [
            Ward(code: "26749", name: "Phường 1", districtCode: "761"),
            Ward(code: "26752", name: "Phường 2", districtCode: "761"),
            Ward(code: "26755", name: "Phường 3", districtCode: "761"),
            Ward(code: "26758", name: "Phường 4", districtCode: "761"),
            Ward(code: "26761", name: "Phường 5", districtCode: "761"),
          ],
        ),
        District(
          code: "764",
          name: "Quận 7",
          provinceCode: "79",
          wards: [
            Ward(
              code: "26764",
              name: "Phường Tân Thuận Đông",
              districtCode: "764",
            ),
            Ward(
              code: "26767",
              name: "Phường Tân Thuận Tây",
              districtCode: "764",
            ),
            Ward(code: "26770", name: "Phường Tân Kiểng", districtCode: "764"),
            Ward(code: "26773", name: "Phường Tân Hưng", districtCode: "764"),
            Ward(code: "26776", name: "Phường Bình Thuận", districtCode: "764"),
          ],
        ),
      ],
    ),
    Province(
      code: "48",
      name: "Tỉnh Đà Nẵng",
      districts: [
        District(
          code: "490",
          name: "Quận Hải Châu",
          provinceCode: "48",
          wards: [
            Ward(code: "20194", name: "Phường Thanh Bình", districtCode: "490"),
            Ward(
              code: "20197",
              name: "Phường Thuận Phước",
              districtCode: "490",
            ),
            Ward(
              code: "20200",
              name: "Phường Thạch Thang",
              districtCode: "490",
            ),
            Ward(code: "20203", name: "Phường Hải Châu I", districtCode: "490"),
            Ward(
              code: "20206",
              name: "Phường Hải Châu II",
              districtCode: "490",
            ),
          ],
        ),
        District(
          code: "491",
          name: "Quận Thanh Khê",
          provinceCode: "48",
          wards: [
            Ward(code: "20209", name: "Phường Tam Thuận", districtCode: "491"),
            Ward(
              code: "20212",
              name: "Phường Thanh Khê Tây",
              districtCode: "491",
            ),
            Ward(
              code: "20215",
              name: "Phường Thanh Khê Đông",
              districtCode: "491",
            ),
            Ward(code: "20218", name: "Phường Xuân Hà", districtCode: "491"),
            Ward(code: "20221", name: "Phường Tân Chính", districtCode: "491"),
          ],
        ),
      ],
    ),
    Province(
      code: "92",
      name: "Tỉnh Cần Thơ",
      districts: [
        District(
          code: "916",
          name: "Quận Ninh Kiều",
          provinceCode: "92",
          wards: [
            Ward(code: "31117", name: "Phường Cái Khế", districtCode: "916"),
            Ward(code: "31120", name: "Phường An Hòa", districtCode: "916"),
            Ward(code: "31123", name: "Phường Thới Bình", districtCode: "916"),
            Ward(code: "31126", name: "Phường An Nghiệp", districtCode: "916"),
            Ward(code: "31129", name: "Phường An Cư", districtCode: "916"),
          ],
        ),
        District(
          code: "917",
          name: "Quận Bình Thủy",
          provinceCode: "92",
          wards: [
            Ward(code: "31132", name: "Phường Bình Thủy", districtCode: "917"),
            Ward(code: "31135", name: "Phường Trà An", districtCode: "917"),
            Ward(code: "31138", name: "Phường Trà Nóc", districtCode: "917"),
            Ward(
              code: "31141",
              name: "Phường Thới An Đông",
              districtCode: "917",
            ),
            Ward(code: "31144", name: "Phường An Thới", districtCode: "917"),
          ],
        ),
      ],
    ),
    Province(
      code: "89",
      name: "Tỉnh An Giang",
      districts: [
        District(
          code: "883",
          name: "Thành phố Long Xuyên",
          provinceCode: "89",
          wards: [
            Ward(code: "30334", name: "Phường Đông Xuyên", districtCode: "883"),
            Ward(code: "30337", name: "Phường Mỹ Bình", districtCode: "883"),
            Ward(code: "30340", name: "Phường Mỹ Long", districtCode: "883"),
            Ward(code: "30343", name: "Phường Mỹ Xuyên", districtCode: "883"),
            Ward(code: "30346", name: "Phường Bình Đức", districtCode: "883"),
          ],
        ),
        District(
          code: "884",
          name: "Thành phố Châu Đốc",
          provinceCode: "89",
          wards: [
            Ward(code: "30349", name: "Phường Châu Phú B", districtCode: "884"),
            Ward(code: "30352", name: "Phường Châu Phú A", districtCode: "884"),
            Ward(code: "30355", name: "Phường Vĩnh Mỹ", districtCode: "884"),
            Ward(code: "30358", name: "Phường Núi Sam", districtCode: "884"),
            Ward(code: "30361", name: "Phường Vĩnh Ngươn", districtCode: "884"),
          ],
        ),
      ],
    ),
    Province(
      code: "77",
      name: "Tỉnh Bà Rịa - Vũng Tàu",
      districts: [
        District(
          code: "747",
          name: "Thành phố Vũng Tàu",
          provinceCode: "77",
          wards: [
            Ward(code: "26299", name: "Phường 1", districtCode: "747"),
            Ward(code: "26302", name: "Phường Thắng Tam", districtCode: "747"),
            Ward(code: "26305", name: "Phường 2", districtCode: "747"),
            Ward(code: "26308", name: "Phường 3", districtCode: "747"),
            Ward(code: "26311", name: "Phường 4", districtCode: "747"),
          ],
        ),
        District(
          code: "748",
          name: "Thành phố Bà Rịa",
          provinceCode: "77",
          wards: [
            Ward(code: "26314", name: "Phường Phước Hiệp", districtCode: "748"),
            Ward(
              code: "26317",
              name: "Phường Phước Nguyên",
              districtCode: "748",
            ),
            Ward(code: "26320", name: "Phường Long Toàn", districtCode: "748"),
            Ward(code: "26323", name: "Phường Long Tâm", districtCode: "748"),
            Ward(
              code: "26326",
              name: "Phường Phước Trung",
              districtCode: "748",
            ),
          ],
        ),
      ],
    ),
    Province(
      code: "74",
      name: "Tỉnh Bình Dương",
      districts: [
        District(
          code: "724",
          name: "Thành phố Thủ Dầu Một",
          provinceCode: "74",
          wards: [
            Ward(code: "25663", name: "Phường Hiệp Thành", districtCode: "724"),
            Ward(code: "25666", name: "Phường Phú Lợi", districtCode: "724"),
            Ward(code: "25669", name: "Phường Phú Cường", districtCode: "724"),
            Ward(code: "25672", name: "Phường Phú Hòa", districtCode: "724"),
            Ward(code: "25675", name: "Phường Phú Thọ", districtCode: "724"),
          ],
        ),
        District(
          code: "725",
          name: "Huyện Bàu Bàng",
          provinceCode: "74",
          wards: [
            Ward(code: "25678", name: "Thị trấn Lai Uyên", districtCode: "725"),
            Ward(code: "25681", name: "Xã Lai Hưng", districtCode: "725"),
            Ward(code: "25684", name: "Xã Lai Thành", districtCode: "725"),
            Ward(code: "25687", name: "Xã Bàu Bàng", districtCode: "725"),
            Ward(code: "25690", name: "Xã Long Nguyên", districtCode: "725"),
          ],
        ),
      ],
    ),
  ];

  static Province? getProvinceByCode(String code) {
    try {
      return provinces.firstWhere((province) => province.code == code);
    } catch (e) {
      return null;
    }
  }

  static District? getDistrictByCode(String provinceCode, String districtCode) {
    try {
      final province = getProvinceByCode(provinceCode);
      return province?.districts.firstWhere(
        (district) => district.code == districtCode,
      );
    } catch (e) {
      return null;
    }
  }

  static Ward? getWardByCode(
    String provinceCode,
    String districtCode,
    String wardCode,
  ) {
    try {
      final district = getDistrictByCode(provinceCode, districtCode);
      return district?.wards.firstWhere((ward) => ward.code == wardCode);
    } catch (e) {
      return null;
    }
  }
}
