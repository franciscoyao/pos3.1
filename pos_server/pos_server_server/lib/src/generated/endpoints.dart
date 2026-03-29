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
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/categories_endpoint.dart' as _i4;
import '../endpoints/checkout_endpoint.dart' as _i5;
import '../endpoints/events_endpoint.dart' as _i6;
import '../endpoints/orders_endpoint.dart' as _i7;
import '../endpoints/products_endpoint.dart' as _i8;
import '../endpoints/reports_endpoint.dart' as _i9;
import '../endpoints/subcategories_endpoint.dart' as _i10;
import '../endpoints/tables_endpoint.dart' as _i11;
import '../endpoints/users_endpoint.dart' as _i12;
import '../greetings/greeting_endpoint.dart' as _i13;
import 'package:pos_server_server/src/generated/order_item.dart' as _i14;
import 'package:pos_server_server/src/generated/product.dart' as _i15;
import 'package:pos_server_server/src/generated/pos_user.dart' as _i16;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i17;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i18;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'categories': _i4.CategoriesEndpoint()
        ..initialize(
          server,
          'categories',
          null,
        ),
      'checkout': _i5.CheckoutEndpoint()
        ..initialize(
          server,
          'checkout',
          null,
        ),
      'events': _i6.EventsEndpoint()
        ..initialize(
          server,
          'events',
          null,
        ),
      'orders': _i7.OrdersEndpoint()
        ..initialize(
          server,
          'orders',
          null,
        ),
      'products': _i8.ProductsEndpoint()
        ..initialize(
          server,
          'products',
          null,
        ),
      'reports': _i9.ReportsEndpoint()
        ..initialize(
          server,
          'reports',
          null,
        ),
      'subcategories': _i10.SubcategoriesEndpoint()
        ..initialize(
          server,
          'subcategories',
          null,
        ),
      'tables': _i11.TablesEndpoint()
        ..initialize(
          server,
          'tables',
          null,
        ),
      'users': _i12.UsersEndpoint()
        ..initialize(
          server,
          'users',
          null,
        ),
      'greeting': _i13.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['categories'] = _i1.EndpointConnector(
      name: 'categories',
      endpoint: endpoints['categories']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['categories'] as _i4.CategoriesEndpoint)
                  .getAll(session),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'station': _i1.ParameterDescription(
              name: 'station',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'orderType': _i1.ParameterDescription(
              name: 'orderType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['categories'] as _i4.CategoriesEndpoint).create(
                    session,
                    params['name'],
                    params['sortOrder'],
                    params['station'],
                    params['orderType'],
                  ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'station': _i1.ParameterDescription(
              name: 'station',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'orderType': _i1.ParameterDescription(
              name: 'orderType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['categories'] as _i4.CategoriesEndpoint).update(
                    session,
                    params['id'],
                    params['name'],
                    params['sortOrder'],
                    params['station'],
                    params['orderType'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['categories'] as _i4.CategoriesEndpoint).delete(
                    session,
                    params['id'],
                  ),
        ),
      },
    );
    connectors['checkout'] = _i1.EndpointConnector(
      name: 'checkout',
      endpoint: endpoints['checkout']!,
      methodConnectors: {
        'checkout': _i1.MethodConnector(
          name: 'checkout',
          params: {
            'orderId': _i1.ParameterDescription(
              name: 'orderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'paymentMethod': _i1.ParameterDescription(
              name: 'paymentMethod',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'waiterName': _i1.ParameterDescription(
              name: 'waiterName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'subtotal': _i1.ParameterDescription(
              name: 'subtotal',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'taxAmount': _i1.ParameterDescription(
              name: 'taxAmount',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'serviceAmount': _i1.ParameterDescription(
              name: 'serviceAmount',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'tipAmount': _i1.ParameterDescription(
              name: 'tipAmount',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
            'total': _i1.ParameterDescription(
              name: 'total',
              type: _i1.getType<double?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['checkout'] as _i5.CheckoutEndpoint).checkout(
                    session,
                    params['orderId'],
                    params['paymentMethod'],
                    waiterName: params['waiterName'],
                    subtotal: params['subtotal'],
                    taxAmount: params['taxAmount'],
                    serviceAmount: params['serviceAmount'],
                    tipAmount: params['tipAmount'],
                    total: params['total'],
                  ),
        ),
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['checkout'] as _i5.CheckoutEndpoint).getAll(
                session,
              ),
        ),
        'getDetails': _i1.MethodConnector(
          name: 'getDetails',
          params: {
            'billId': _i1.ParameterDescription(
              name: 'billId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['checkout'] as _i5.CheckoutEndpoint).getDetails(
                    session,
                    params['billId'],
                  ),
        ),
      },
    );
    connectors['events'] = _i1.EndpointConnector(
      name: 'events',
      endpoint: endpoints['events']!,
      methodConnectors: {
        'subscribe': _i1.MethodStreamConnector(
          name: 'subscribe',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['events'] as _i6.EventsEndpoint).subscribe(
                session,
              ),
        ),
      },
    );
    connectors['orders'] = _i1.EndpointConnector(
      name: 'orders',
      endpoint: endpoints['orders']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {
            'includeItems': _i1.ParameterDescription(
              name: 'includeItems',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'statusFilter': _i1.ParameterDescription(
              name: 'statusFilter',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'stationFilter': _i1.ParameterDescription(
              name: 'stationFilter',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['orders'] as _i7.OrdersEndpoint).getAll(
                session,
                includeItems: params['includeItems'],
                statusFilter: params['statusFilter'],
                stationFilter: params['stationFilter'],
              ),
        ),
        'getById': _i1.MethodConnector(
          name: 'getById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['orders'] as _i7.OrdersEndpoint).getById(
                session,
                params['id'],
              ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'total': _i1.ParameterDescription(
              name: 'total',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'orderType': _i1.ParameterDescription(
              name: 'orderType',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'tableNo': _i1.ParameterDescription(
              name: 'tableNo',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'orderCode': _i1.ParameterDescription(
              name: 'orderCode',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'waiterName': _i1.ParameterDescription(
              name: 'waiterName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<List<_i14.OrderItem>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['orders'] as _i7.OrdersEndpoint).create(
                session,
                params['total'],
                params['orderType'],
                params['tableNo'],
                params['orderCode'],
                params['waiterName'],
                params['items'],
              ),
        ),
        'updateStatus': _i1.MethodConnector(
          name: 'updateStatus',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['orders'] as _i7.OrdersEndpoint).updateStatus(
                    session,
                    params['id'],
                    params['status'],
                  ),
        ),
        'merge': _i1.MethodConnector(
          name: 'merge',
          params: {
            'targetOrderId': _i1.ParameterDescription(
              name: 'targetOrderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'sourceOrderId': _i1.ParameterDescription(
              name: 'sourceOrderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['orders'] as _i7.OrdersEndpoint).merge(
                session,
                params['targetOrderId'],
                params['sourceOrderId'],
              ),
        ),
        'split': _i1.MethodConnector(
          name: 'split',
          params: {
            'sourceOrderId': _i1.ParameterDescription(
              name: 'sourceOrderId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'splitItems': _i1.ParameterDescription(
              name: 'splitItems',
              type: _i1.getType<List<Map<String, dynamic>>>(),
              nullable: false,
            ),
            'newTableNo': _i1.ParameterDescription(
              name: 'newTableNo',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newOrderType': _i1.ParameterDescription(
              name: 'newOrderType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sourceNewSubtotal': _i1.ParameterDescription(
              name: 'sourceNewSubtotal',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'sourceNewTax': _i1.ParameterDescription(
              name: 'sourceNewTax',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'sourceNewService': _i1.ParameterDescription(
              name: 'sourceNewService',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'sourceNewTotal': _i1.ParameterDescription(
              name: 'sourceNewTotal',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'targetSubtotal': _i1.ParameterDescription(
              name: 'targetSubtotal',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'targetTax': _i1.ParameterDescription(
              name: 'targetTax',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'targetService': _i1.ParameterDescription(
              name: 'targetService',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'targetTotal': _i1.ParameterDescription(
              name: 'targetTotal',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['orders'] as _i7.OrdersEndpoint).split(
                session,
                params['sourceOrderId'],
                params['splitItems'],
                params['newTableNo'],
                params['newOrderType'],
                params['sourceNewSubtotal'],
                params['sourceNewTax'],
                params['sourceNewService'],
                params['sourceNewTotal'],
                params['targetSubtotal'],
                params['targetTax'],
                params['targetService'],
                params['targetTotal'],
              ),
        ),
      },
    );
    connectors['products'] = _i1.EndpointConnector(
      name: 'products',
      endpoint: endpoints['products']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['products'] as _i8.ProductsEndpoint).getAll(
                session,
              ),
        ),
        'getPopular': _i1.MethodConnector(
          name: 'getPopular',
          params: {
            'orderType': _i1.ParameterDescription(
              name: 'orderType',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['products'] as _i8.ProductsEndpoint).getPopular(
                    session,
                    params['orderType'],
                  ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'product': _i1.ParameterDescription(
              name: 'product',
              type: _i1.getType<_i15.Product>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['products'] as _i8.ProductsEndpoint).create(
                session,
                params['product'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'product': _i1.ParameterDescription(
              name: 'product',
              type: _i1.getType<_i15.Product>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['products'] as _i8.ProductsEndpoint).update(
                session,
                params['id'],
                params['product'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['products'] as _i8.ProductsEndpoint).delete(
                session,
                params['id'],
              ),
        ),
        'addExtra': _i1.MethodConnector(
          name: 'addExtra',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'price': _i1.ParameterDescription(
              name: 'price',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['products'] as _i8.ProductsEndpoint).addExtra(
                    session,
                    params['productId'],
                    params['name'],
                    params['price'],
                  ),
        ),
        'deleteExtra': _i1.MethodConnector(
          name: 'deleteExtra',
          params: {
            'extraId': _i1.ParameterDescription(
              name: 'extraId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['products'] as _i8.ProductsEndpoint).deleteExtra(
                    session,
                    params['extraId'],
                  ),
        ),
      },
    );
    connectors['reports'] = _i1.EndpointConnector(
      name: 'reports',
      endpoint: endpoints['reports']!,
      methodConnectors: {
        'getSummaryJson': _i1.MethodConnector(
          name: 'getSummaryJson',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['reports'] as _i9.ReportsEndpoint)
                  .getSummaryJson(session),
        ),
      },
    );
    connectors['subcategories'] = _i1.EndpointConnector(
      name: 'subcategories',
      endpoint: endpoints['subcategories']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subcategories'] as _i10.SubcategoriesEndpoint)
                      .getAll(session),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subcategories'] as _i10.SubcategoriesEndpoint)
                      .create(
                        session,
                        params['categoryId'],
                        params['name'],
                        params['sortOrder'],
                      ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'sortOrder': _i1.ParameterDescription(
              name: 'sortOrder',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subcategories'] as _i10.SubcategoriesEndpoint)
                      .update(
                        session,
                        params['id'],
                        params['categoryId'],
                        params['name'],
                        params['sortOrder'],
                      ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['subcategories'] as _i10.SubcategoriesEndpoint)
                      .delete(
                        session,
                        params['id'],
                      ),
        ),
      },
    );
    connectors['tables'] = _i1.EndpointConnector(
      name: 'tables',
      endpoint: endpoints['tables']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['tables'] as _i11.TablesEndpoint).getAll(session),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'tableNumber': _i1.ParameterDescription(
              name: 'tableNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tables'] as _i11.TablesEndpoint).create(
                session,
                params['tableNumber'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'orderCode': _i1.ParameterDescription(
              name: 'orderCode',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'guestCount': _i1.ParameterDescription(
              name: 'guestCount',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['tables'] as _i11.TablesEndpoint).update(
                session,
                params['id'],
                params['status'],
                params['orderCode'],
                params['guestCount'],
              ),
        ),
      },
    );
    connectors['users'] = _i1.EndpointConnector(
      name: 'users',
      endpoint: endpoints['users']!,
      methodConnectors: {
        'getAll': _i1.MethodConnector(
          name: 'getAll',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['users'] as _i12.UsersEndpoint).getAll(session),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i16.PosUser>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['users'] as _i12.UsersEndpoint).create(
                session,
                params['user'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i16.PosUser>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['users'] as _i12.UsersEndpoint).update(
                session,
                params['id'],
                params['user'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['users'] as _i12.UsersEndpoint).delete(
                session,
                params['id'],
              ),
        ),
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'username': _i1.ParameterDescription(
              name: 'username',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'pin': _i1.ParameterDescription(
              name: 'pin',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['users'] as _i12.UsersEndpoint).login(
                session,
                params['role'],
                params['username'],
                params['pin'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i13.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i17.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i18.Endpoints()
      ..initializeEndpoints(server);
  }
}
