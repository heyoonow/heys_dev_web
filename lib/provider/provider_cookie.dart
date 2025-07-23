import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/util/cookie_manager.dart';

final providerCookie = Provider((ref) => CookieManager());
