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

/// User device registration for FCM push notifications
abstract class UserDevice
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserDevice._({
    this.id,
    required this.userId,
    required this.fcmToken,
    required this.platform,
    required this.lastUpdated,
  });

  factory UserDevice({
    int? id,
    required String userId,
    required String fcmToken,
    required String platform,
    required DateTime lastUpdated,
  }) = _UserDeviceImpl;

  factory UserDevice.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserDevice(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      fcmToken: jsonSerialization['fcmToken'] as String,
      platform: jsonSerialization['platform'] as String,
      lastUpdated: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdated'],
      ),
    );
  }

  static final t = UserDeviceTable();

  static const db = UserDeviceRepository._();

  @override
  int? id;

  /// Reference to the user who owns this device (serverpod_auth user UUID)
  String userId;

  /// Firebase Cloud Messaging token for push notifications
  String fcmToken;

  /// Platform identifier ('android' or 'ios')
  String platform;

  /// When the FCM token was last updated
  DateTime lastUpdated;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserDevice copyWith({
    int? id,
    String? userId,
    String? fcmToken,
    String? platform,
    DateTime? lastUpdated,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserDevice',
      if (id != null) 'id': id,
      'userId': userId,
      'fcmToken': fcmToken,
      'platform': platform,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserDevice',
      if (id != null) 'id': id,
      'userId': userId,
      'fcmToken': fcmToken,
      'platform': platform,
      'lastUpdated': lastUpdated.toJson(),
    };
  }

  static UserDeviceInclude include() {
    return UserDeviceInclude._();
  }

  static UserDeviceIncludeList includeList({
    _i1.WhereExpressionBuilder<UserDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserDeviceTable>? orderByList,
    UserDeviceInclude? include,
  }) {
    return UserDeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDevice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserDevice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserDeviceImpl extends UserDevice {
  _UserDeviceImpl({
    int? id,
    required String userId,
    required String fcmToken,
    required String platform,
    required DateTime lastUpdated,
  }) : super._(
         id: id,
         userId: userId,
         fcmToken: fcmToken,
         platform: platform,
         lastUpdated: lastUpdated,
       );

  /// Returns a shallow copy of this [UserDevice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserDevice copyWith({
    Object? id = _Undefined,
    String? userId,
    String? fcmToken,
    String? platform,
    DateTime? lastUpdated,
  }) {
    return UserDevice(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserDeviceUpdateTable extends _i1.UpdateTable<UserDeviceTable> {
  UserDeviceUpdateTable(super.table);

  _i1.ColumnValue<String, String> userId(String value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> fcmToken(String value) => _i1.ColumnValue(
    table.fcmToken,
    value,
  );

  _i1.ColumnValue<String, String> platform(String value) => _i1.ColumnValue(
    table.platform,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastUpdated(DateTime value) =>
      _i1.ColumnValue(
        table.lastUpdated,
        value,
      );
}

class UserDeviceTable extends _i1.Table<int?> {
  UserDeviceTable({super.tableRelation}) : super(tableName: 'user_device') {
    updateTable = UserDeviceUpdateTable(this);
    userId = _i1.ColumnString(
      'userId',
      this,
    );
    fcmToken = _i1.ColumnString(
      'fcmToken',
      this,
    );
    platform = _i1.ColumnString(
      'platform',
      this,
    );
    lastUpdated = _i1.ColumnDateTime(
      'lastUpdated',
      this,
    );
  }

  late final UserDeviceUpdateTable updateTable;

  /// Reference to the user who owns this device (serverpod_auth user UUID)
  late final _i1.ColumnString userId;

  /// Firebase Cloud Messaging token for push notifications
  late final _i1.ColumnString fcmToken;

  /// Platform identifier ('android' or 'ios')
  late final _i1.ColumnString platform;

  /// When the FCM token was last updated
  late final _i1.ColumnDateTime lastUpdated;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    fcmToken,
    platform,
    lastUpdated,
  ];
}

class UserDeviceInclude extends _i1.IncludeObject {
  UserDeviceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserDevice.t;
}

class UserDeviceIncludeList extends _i1.IncludeList {
  UserDeviceIncludeList._({
    _i1.WhereExpressionBuilder<UserDeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserDevice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserDevice.t;
}

class UserDeviceRepository {
  const UserDeviceRepository._();

  /// Returns a list of [UserDevice]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UserDevice>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserDeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserDeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<UserDevice>(
      where: where?.call(UserDevice.t),
      orderBy: orderBy?.call(UserDevice.t),
      orderByList: orderByList?.call(UserDevice.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [UserDevice] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UserDevice?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserDeviceTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserDeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserDeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<UserDevice>(
      where: where?.call(UserDevice.t),
      orderBy: orderBy?.call(UserDevice.t),
      orderByList: orderByList?.call(UserDevice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [UserDevice] by its [id] or null if no such row exists.
  Future<UserDevice?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<UserDevice>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [UserDevice]s in the list and returns the inserted rows.
  ///
  /// The returned [UserDevice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<UserDevice>> insert(
    _i1.Session session,
    List<UserDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<UserDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [UserDevice] and returns the inserted row.
  ///
  /// The returned [UserDevice] will have its `id` field set.
  Future<UserDevice> insertRow(
    _i1.Session session,
    UserDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserDevice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserDevice>> update(
    _i1.Session session,
    List<UserDevice> rows, {
    _i1.ColumnSelections<UserDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserDevice>(
      rows,
      columns: columns?.call(UserDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserDevice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserDevice> updateRow(
    _i1.Session session,
    UserDevice row, {
    _i1.ColumnSelections<UserDeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserDevice>(
      row,
      columns: columns?.call(UserDevice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserDevice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserDevice?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<UserDeviceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserDevice>(
      id,
      columnValues: columnValues(UserDevice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserDevice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserDevice>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<UserDeviceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserDeviceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserDeviceTable>? orderBy,
    _i1.OrderByListBuilder<UserDeviceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserDevice>(
      columnValues: columnValues(UserDevice.t.updateTable),
      where: where(UserDevice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserDevice.t),
      orderByList: orderByList?.call(UserDevice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserDevice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserDevice>> delete(
    _i1.Session session,
    List<UserDevice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserDevice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserDevice].
  Future<UserDevice> deleteRow(
    _i1.Session session,
    UserDevice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserDevice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserDevice>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<UserDeviceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserDevice>(
      where: where(UserDevice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<UserDeviceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserDevice>(
      where: where?.call(UserDevice.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
