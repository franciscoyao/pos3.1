/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:pos_server_client/src/protocol/category.dart' as _i5;
import 'package:pos_server_client/src/protocol/bill.dart' as _i6;
import 'package:pos_server_client/src/protocol/pos_event.dart' as _i7;
import 'package:pos_server_client/src/protocol/order.dart' as _i8;
import 'package:pos_server_client/src/protocol/order_item.dart' as _i9;
import 'package:pos_server_client/src/protocol/product.dart' as _i10;
import 'package:pos_server_client/src/protocol/product_extra.dart' as _i11;
import 'package:pos_server_client/src/protocol/subcategory.dart' as _i12;
import 'package:pos_server_client/src/protocol/restaurant_table.dart' as _i13;
import 'package:pos_server_client/src/protocol/pos_user.dart' as _i14;
import 'package:pos_server_client/src/protocol/greetings/greeting.dart' as _i15;
import 'protocol.dart' as _i16;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointCategories extends _i2.EndpointRef {
  EndpointCategories(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'categories';

  _i3.Future<List<_i5.Category>> getAll() =>
      caller.callServerEndpoint<List<_i5.Category>>(
        'categories',
        'getAll',
        {},
      );

  _i3.Future<_i5.Category> create(
    String name,
    int sortOrder,
    String? station,
    String orderType,
  ) => caller.callServerEndpoint<_i5.Category>(
    'categories',
    'create',
    {
      'name': name,
      'sortOrder': sortOrder,
      'station': station,
      'orderType': orderType,
    },
  );

  _i3.Future<_i5.Category> update(
    int id,
    String name,
    int sortOrder,
    String? station,
    String orderType,
  ) => caller.callServerEndpoint<_i5.Category>(
    'categories',
    'update',
    {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
      'station': station,
      'orderType': orderType,
    },
  );

  _i3.Future<bool> delete(int id) => caller.callServerEndpoint<bool>(
    'categories',
    'delete',
    {'id': id},
  );
}

/// {@category Endpoint}
class EndpointCheckout extends _i2.EndpointRef {
  EndpointCheckout(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'checkout';

  _i3.Future<_i6.Bill> checkout(
    int orderId,
    String paymentMethod, {
    String? waiterName,
    double? subtotal,
    double? taxAmount,
    double? serviceAmount,
    double? tipAmount,
    double? total,
  }) => caller.callServerEndpoint<_i6.Bill>(
    'checkout',
    'checkout',
    {
      'orderId': orderId,
      'paymentMethod': paymentMethod,
      'waiterName': waiterName,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'serviceAmount': serviceAmount,
      'tipAmount': tipAmount,
      'total': total,
    },
  );

  _i3.Future<List<_i6.Bill>> getAll() =>
      caller.callServerEndpoint<List<_i6.Bill>>(
        'checkout',
        'getAll',
        {},
      );

  _i3.Future<_i6.Bill> getDetails(int billId) =>
      caller.callServerEndpoint<_i6.Bill>(
        'checkout',
        'getDetails',
        {'billId': billId},
      );
}

/// Streaming endpoint — clients subscribe here to receive real-time PosEvents.
/// The Flutter app opens a persistent stream connection and receives events
/// whenever any endpoint calls EventService.broadcast().
/// {@category Endpoint}
class EndpointEvents extends _i2.EndpointRef {
  EndpointEvents(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'events';

  /// Subscribe to all POS real-time events.
  _i3.Stream<_i7.PosEvent> subscribe() => caller
      .callStreamingServerEndpoint<_i3.Stream<_i7.PosEvent>, _i7.PosEvent>(
        'events',
        'subscribe',
        {},
        {},
      );
}

/// {@category Endpoint}
class EndpointOrders extends _i2.EndpointRef {
  EndpointOrders(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'orders';

  _i3.Future<List<_i8.PosOrder>> getAll({
    required bool includeItems,
    String? statusFilter,
    String? stationFilter,
  }) => caller.callServerEndpoint<List<_i8.PosOrder>>(
    'orders',
    'getAll',
    {
      'includeItems': includeItems,
      'statusFilter': statusFilter,
      'stationFilter': stationFilter,
    },
  );

  _i3.Future<_i8.PosOrder> getById(int id) =>
      caller.callServerEndpoint<_i8.PosOrder>(
        'orders',
        'getById',
        {'id': id},
      );

  _i3.Future<_i8.PosOrder> create(
    double total,
    String? orderType,
    String? tableNo,
    String? orderCode,
    String? waiterName,
    List<_i9.OrderItem> items,
  ) => caller.callServerEndpoint<_i8.PosOrder>(
    'orders',
    'create',
    {
      'total': total,
      'orderType': orderType,
      'tableNo': tableNo,
      'orderCode': orderCode,
      'waiterName': waiterName,
      'items': items,
    },
  );

  _i3.Future<_i8.PosOrder> updateStatus(
    int id,
    String status,
  ) => caller.callServerEndpoint<_i8.PosOrder>(
    'orders',
    'updateStatus',
    {
      'id': id,
      'status': status,
    },
  );

  _i3.Future<bool> merge(
    int targetOrderId,
    int sourceOrderId,
  ) => caller.callServerEndpoint<bool>(
    'orders',
    'merge',
    {
      'targetOrderId': targetOrderId,
      'sourceOrderId': sourceOrderId,
    },
  );

  _i3.Future<int> split(
    int sourceOrderId,
    List<Map<String, dynamic>> splitItems,
    String newTableNo,
    String newOrderType,
    double sourceNewSubtotal,
    double sourceNewTax,
    double sourceNewService,
    double sourceNewTotal,
    double targetSubtotal,
    double targetTax,
    double targetService,
    double targetTotal,
  ) => caller.callServerEndpoint<int>(
    'orders',
    'split',
    {
      'sourceOrderId': sourceOrderId,
      'splitItems': splitItems,
      'newTableNo': newTableNo,
      'newOrderType': newOrderType,
      'sourceNewSubtotal': sourceNewSubtotal,
      'sourceNewTax': sourceNewTax,
      'sourceNewService': sourceNewService,
      'sourceNewTotal': sourceNewTotal,
      'targetSubtotal': targetSubtotal,
      'targetTax': targetTax,
      'targetService': targetService,
      'targetTotal': targetTotal,
    },
  );
}

/// {@category Endpoint}
class EndpointProducts extends _i2.EndpointRef {
  EndpointProducts(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'products';

  _i3.Future<List<_i10.Product>> getAll() =>
      caller.callServerEndpoint<List<_i10.Product>>(
        'products',
        'getAll',
        {},
      );

  _i3.Future<List<_i10.Product>> getPopular(String? orderType) =>
      caller.callServerEndpoint<List<_i10.Product>>(
        'products',
        'getPopular',
        {'orderType': orderType},
      );

  _i3.Future<_i10.Product> create(_i10.Product product) =>
      caller.callServerEndpoint<_i10.Product>(
        'products',
        'create',
        {'product': product},
      );

  _i3.Future<_i10.Product> update(
    int id,
    _i10.Product product,
  ) => caller.callServerEndpoint<_i10.Product>(
    'products',
    'update',
    {
      'id': id,
      'product': product,
    },
  );

  _i3.Future<bool> delete(int id) => caller.callServerEndpoint<bool>(
    'products',
    'delete',
    {'id': id},
  );

  _i3.Future<_i11.ProductExtra> addExtra(
    int productId,
    String name,
    double price,
  ) => caller.callServerEndpoint<_i11.ProductExtra>(
    'products',
    'addExtra',
    {
      'productId': productId,
      'name': name,
      'price': price,
    },
  );

  _i3.Future<bool> deleteExtra(int extraId) => caller.callServerEndpoint<bool>(
    'products',
    'deleteExtra',
    {'extraId': extraId},
  );
}

/// {@category Endpoint}
class EndpointReports extends _i2.EndpointRef {
  EndpointReports(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'reports';

  _i3.Future<String> getSummaryJson() => caller.callServerEndpoint<String>(
    'reports',
    'getSummaryJson',
    {},
  );
}

/// {@category Endpoint}
class EndpointSubcategories extends _i2.EndpointRef {
  EndpointSubcategories(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'subcategories';

  _i3.Future<List<_i12.Subcategory>> getAll() =>
      caller.callServerEndpoint<List<_i12.Subcategory>>(
        'subcategories',
        'getAll',
        {},
      );

  _i3.Future<_i12.Subcategory> create(
    int categoryId,
    String name,
    int sortOrder,
  ) => caller.callServerEndpoint<_i12.Subcategory>(
    'subcategories',
    'create',
    {
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
    },
  );

  _i3.Future<_i12.Subcategory> update(
    int id,
    int categoryId,
    String name,
    int sortOrder,
  ) => caller.callServerEndpoint<_i12.Subcategory>(
    'subcategories',
    'update',
    {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'sortOrder': sortOrder,
    },
  );

  _i3.Future<bool> delete(int id) => caller.callServerEndpoint<bool>(
    'subcategories',
    'delete',
    {'id': id},
  );
}

/// {@category Endpoint}
class EndpointTables extends _i2.EndpointRef {
  EndpointTables(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'tables';

  _i3.Future<List<_i13.RestaurantTable>> getAll() =>
      caller.callServerEndpoint<List<_i13.RestaurantTable>>(
        'tables',
        'getAll',
        {},
      );

  _i3.Future<_i13.RestaurantTable> create(String tableNumber) =>
      caller.callServerEndpoint<_i13.RestaurantTable>(
        'tables',
        'create',
        {'tableNumber': tableNumber},
      );

  _i3.Future<_i13.RestaurantTable> update(
    int id,
    String status,
    String? orderCode,
    int guestCount,
  ) => caller.callServerEndpoint<_i13.RestaurantTable>(
    'tables',
    'update',
    {
      'id': id,
      'status': status,
      'orderCode': orderCode,
      'guestCount': guestCount,
    },
  );
}

/// {@category Endpoint}
class EndpointUsers extends _i2.EndpointRef {
  EndpointUsers(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  _i3.Future<List<_i14.PosUser>> getAll() =>
      caller.callServerEndpoint<List<_i14.PosUser>>(
        'users',
        'getAll',
        {},
      );

  _i3.Future<_i14.PosUser> create(_i14.PosUser user) =>
      caller.callServerEndpoint<_i14.PosUser>(
        'users',
        'create',
        {'user': user},
      );

  _i3.Future<_i14.PosUser> update(
    int id,
    _i14.PosUser user,
  ) => caller.callServerEndpoint<_i14.PosUser>(
    'users',
    'update',
    {
      'id': id,
      'user': user,
    },
  );

  _i3.Future<bool> delete(int id) => caller.callServerEndpoint<bool>(
    'users',
    'delete',
    {'id': id},
  );

  _i3.Future<_i14.PosUser?> login(
    String role,
    String? username,
    String? pin,
  ) => caller.callServerEndpoint<_i14.PosUser?>(
    'users',
    'login',
    {
      'role': role,
      'username': username,
      'pin': pin,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i15.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i15.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i16.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    categories = EndpointCategories(this);
    checkout = EndpointCheckout(this);
    events = EndpointEvents(this);
    orders = EndpointOrders(this);
    products = EndpointProducts(this);
    reports = EndpointReports(this);
    subcategories = EndpointSubcategories(this);
    tables = EndpointTables(this);
    users = EndpointUsers(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointCategories categories;

  late final EndpointCheckout checkout;

  late final EndpointEvents events;

  late final EndpointOrders orders;

  late final EndpointProducts products;

  late final EndpointReports reports;

  late final EndpointSubcategories subcategories;

  late final EndpointTables tables;

  late final EndpointUsers users;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'categories': categories,
    'checkout': checkout,
    'events': events,
    'orders': orders,
    'products': products,
    'reports': reports,
    'subcategories': subcategories,
    'tables': tables,
    'users': users,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
