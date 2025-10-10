// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAllSettingsCollection on Isar {
  IsarCollection<AllSettings> get allSettings => this.collection();
}

const AllSettingsSchema = CollectionSchema(
  name: r'AllSettings',
  id: 7675443445704401613,
  properties: {
    r'autoCheckUpdate': PropertySchema(
      id: 0,
      name: r'autoCheckUpdate',
      type: IsarType.bool,
    ),
    r'autoSetMTU': PropertySchema(
      id: 1,
      name: r'autoSetMTU',
      type: IsarType.bool,
    ),
    r'beta': PropertySchema(id: 2, name: r'beta', type: IsarType.bool),
    r'closeMinimize': PropertySchema(
      id: 3,
      name: r'closeMinimize',
      type: IsarType.bool,
    ),
    r'customVpn': PropertySchema(
      id: 4,
      name: r'customVpn',
      type: IsarType.stringList,
    ),
    r'displayMode': PropertySchema(
      id: 5,
      name: r'displayMode',
      type: IsarType.long,
    ),
    r'downloadAccelerate': PropertySchema(
      id: 6,
      name: r'downloadAccelerate',
      type: IsarType.string,
    ),
    r'latestVersion': PropertySchema(
      id: 7,
      name: r'latestVersion',
      type: IsarType.string,
    ),
    r'listenList': PropertySchema(
      id: 8,
      name: r'listenList',
      type: IsarType.stringList,
    ),
    r'playerName': PropertySchema(
      id: 9,
      name: r'playerName',
      type: IsarType.string,
    ),
    r'room': PropertySchema(id: 10, name: r'room', type: IsarType.long),
    r'serverSortField': PropertySchema(
      id: 11,
      name: r'serverSortField',
      type: IsarType.string,
    ),
    r'sortOption': PropertySchema(
      id: 12,
      name: r'sortOption',
      type: IsarType.long,
    ),
    r'sortOrder': PropertySchema(
      id: 13,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'startup': PropertySchema(id: 14, name: r'startup', type: IsarType.bool),
    r'startupAutoConnect': PropertySchema(
      id: 15,
      name: r'startupAutoConnect',
      type: IsarType.bool,
    ),
    r'startupMinimize': PropertySchema(
      id: 16,
      name: r'startupMinimize',
      type: IsarType.bool,
    ),
    r'userId': PropertySchema(id: 17, name: r'userId', type: IsarType.string),
    r'userListSimple': PropertySchema(
      id: 18,
      name: r'userListSimple',
      type: IsarType.bool,
    ),
  },
  estimateSize: _allSettingsEstimateSize,
  serialize: _allSettingsSerialize,
  deserialize: _allSettingsDeserialize,
  deserializeProp: _allSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _allSettingsGetId,
  getLinks: _allSettingsGetLinks,
  attach: _allSettingsAttach,
  version: '3.1.8',
);

int _allSettingsEstimateSize(
  AllSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.customVpn.length * 3;
  {
    for (var i = 0; i < object.customVpn.length; i++) {
      final value = object.customVpn[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.downloadAccelerate.length * 3;
  {
    final value = object.latestVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.listenList;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.playerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serverSortField.length * 3;
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _allSettingsSerialize(
  AllSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoCheckUpdate);
  writer.writeBool(offsets[1], object.autoSetMTU);
  writer.writeBool(offsets[2], object.beta);
  writer.writeBool(offsets[3], object.closeMinimize);
  writer.writeStringList(offsets[4], object.customVpn);
  writer.writeLong(offsets[5], object.displayMode);
  writer.writeString(offsets[6], object.downloadAccelerate);
  writer.writeString(offsets[7], object.latestVersion);
  writer.writeStringList(offsets[8], object.listenList);
  writer.writeString(offsets[9], object.playerName);
  writer.writeLong(offsets[10], object.room);
  writer.writeString(offsets[11], object.serverSortField);
  writer.writeLong(offsets[12], object.sortOption);
  writer.writeLong(offsets[13], object.sortOrder);
  writer.writeBool(offsets[14], object.startup);
  writer.writeBool(offsets[15], object.startupAutoConnect);
  writer.writeBool(offsets[16], object.startupMinimize);
  writer.writeString(offsets[17], object.userId);
  writer.writeBool(offsets[18], object.userListSimple);
}

AllSettings _allSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AllSettings();
  object.autoCheckUpdate = reader.readBool(offsets[0]);
  object.autoSetMTU = reader.readBool(offsets[1]);
  object.beta = reader.readBool(offsets[2]);
  object.closeMinimize = reader.readBool(offsets[3]);
  object.customVpn = reader.readStringList(offsets[4]) ?? [];
  object.displayMode = reader.readLong(offsets[5]);
  object.downloadAccelerate = reader.readString(offsets[6]);
  object.id = id;
  object.latestVersion = reader.readStringOrNull(offsets[7]);
  object.listenList = reader.readStringList(offsets[8]);
  object.playerName = reader.readStringOrNull(offsets[9]);
  object.room = reader.readLongOrNull(offsets[10]);
  object.serverSortField = reader.readString(offsets[11]);
  object.sortOption = reader.readLong(offsets[12]);
  object.sortOrder = reader.readLong(offsets[13]);
  object.startup = reader.readBool(offsets[14]);
  object.startupAutoConnect = reader.readBool(offsets[15]);
  object.startupMinimize = reader.readBool(offsets[16]);
  object.userId = reader.readStringOrNull(offsets[17]);
  object.userListSimple = reader.readBool(offsets[18]);
  return object;
}

P _allSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringList(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _allSettingsGetId(AllSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _allSettingsGetLinks(AllSettings object) {
  return [];
}

void _allSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  AllSettings object,
) {
  object.id = id;
}

extension AllSettingsQueryWhereSort
    on QueryBuilder<AllSettings, AllSettings, QWhere> {
  QueryBuilder<AllSettings, AllSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AllSettingsQueryWhere
    on QueryBuilder<AllSettings, AllSettings, QWhereClause> {
  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AllSettingsQueryFilter
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {
  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  autoCheckUpdateEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoCheckUpdate', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  autoSetMTUEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoSetMTU', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> betaEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'beta', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  closeMinimizeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'closeMinimize', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'customVpn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'customVpn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'customVpn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'customVpn', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'customVpn', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customVpn', length, true, length, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customVpn', 0, true, 0, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customVpn', 0, false, 999999, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customVpn', 0, true, length, include);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'customVpn', length, include, 999999, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  customVpnLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'customVpn',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  displayModeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayMode', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  displayModeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  displayModeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayMode',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  displayModeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayMode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'downloadAccelerate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'downloadAccelerate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'downloadAccelerate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'downloadAccelerate', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  downloadAccelerateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'downloadAccelerate', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'latestVersion'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'latestVersion'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latestVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'latestVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'latestVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'latestVersion', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  latestVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'latestVersion', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'listenList'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'listenList'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'listenList',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'listenList',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'listenList',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'listenList', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'listenList', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'listenList', length, true, length, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'listenList', 0, true, 0, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'listenList', 0, false, 999999, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'listenList', 0, true, length, include);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'listenList', length, include, 999999, true);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  listenListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'listenList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'playerName'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'playerName'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'playerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'playerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'playerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'playerName', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  playerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'playerName', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'room'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  roomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'room'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'room', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'room',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'room',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> roomBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'room',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverSortField',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'serverSortField',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'serverSortField',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverSortField', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  serverSortFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'serverSortField', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOptionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOption', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOptionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOptionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOption',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOptionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOption',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> startupEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startup', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  startupAutoConnectEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startupAutoConnect', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  startupMinimizeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startupMinimize', value: value),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition> userIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterFilterCondition>
  userListSimpleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userListSimple', value: value),
      );
    });
  }
}

extension AllSettingsQueryObject
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {}

extension AllSettingsQueryLinks
    on QueryBuilder<AllSettings, AllSettings, QFilterCondition> {}

extension AllSettingsQuerySortBy
    on QueryBuilder<AllSettings, AllSettings, QSortBy> {
  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByAutoCheckUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCheckUpdate', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByAutoCheckUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCheckUpdate', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByAutoSetMTU() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSetMTU', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByAutoSetMTUDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSetMTU', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByBetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByCloseMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeMinimize', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByCloseMinimizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeMinimize', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByDownloadAccelerate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAccelerate', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByDownloadAccelerateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAccelerate', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByLatestVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestVersion', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByLatestVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestVersion', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByServerSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverSortField', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByServerSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverSortField', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortBySortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startup', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByStartupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startup', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByStartupAutoConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupAutoConnect', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByStartupAutoConnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupAutoConnect', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByStartupMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupMinimize', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByStartupMinimizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupMinimize', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> sortByUserListSimple() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userListSimple', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  sortByUserListSimpleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userListSimple', Sort.desc);
    });
  }
}

extension AllSettingsQuerySortThenBy
    on QueryBuilder<AllSettings, AllSettings, QSortThenBy> {
  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByAutoCheckUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCheckUpdate', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByAutoCheckUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoCheckUpdate', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByAutoSetMTU() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSetMTU', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByAutoSetMTUDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSetMTU', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByBetaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beta', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByCloseMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeMinimize', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByCloseMinimizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closeMinimize', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByDownloadAccelerate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAccelerate', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByDownloadAccelerateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadAccelerate', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByLatestVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestVersion', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByLatestVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latestVersion', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByPlayerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByPlayerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerName', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByServerSortField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverSortField', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByServerSortFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverSortField', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenBySortOptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOption', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startup', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByStartupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startup', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByStartupAutoConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupAutoConnect', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByStartupAutoConnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupAutoConnect', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByStartupMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupMinimize', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByStartupMinimizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startupMinimize', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy> thenByUserListSimple() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userListSimple', Sort.asc);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QAfterSortBy>
  thenByUserListSimpleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userListSimple', Sort.desc);
    });
  }
}

extension AllSettingsQueryWhereDistinct
    on QueryBuilder<AllSettings, AllSettings, QDistinct> {
  QueryBuilder<AllSettings, AllSettings, QDistinct>
  distinctByAutoCheckUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoCheckUpdate');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByAutoSetMTU() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoSetMTU');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByBeta() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beta');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByCloseMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closeMinimize');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByCustomVpn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customVpn');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayMode');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct>
  distinctByDownloadAccelerate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'downloadAccelerate',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByLatestVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'latestVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByListenList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'listenList');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByPlayerName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'room');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByServerSortField({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'serverSortField',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctBySortOption() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOption');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByStartup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startup');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct>
  distinctByStartupAutoConnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startupAutoConnect');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct>
  distinctByStartupMinimize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startupMinimize');
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByUserId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AllSettings, AllSettings, QDistinct> distinctByUserListSimple() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userListSimple');
    });
  }
}

extension AllSettingsQueryProperty
    on QueryBuilder<AllSettings, AllSettings, QQueryProperty> {
  QueryBuilder<AllSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> autoCheckUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoCheckUpdate');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> autoSetMTUProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoSetMTU');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> betaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beta');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> closeMinimizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closeMinimize');
    });
  }

  QueryBuilder<AllSettings, List<String>, QQueryOperations>
  customVpnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customVpn');
    });
  }

  QueryBuilder<AllSettings, int, QQueryOperations> displayModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayMode');
    });
  }

  QueryBuilder<AllSettings, String, QQueryOperations>
  downloadAccelerateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadAccelerate');
    });
  }

  QueryBuilder<AllSettings, String?, QQueryOperations> latestVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latestVersion');
    });
  }

  QueryBuilder<AllSettings, List<String>?, QQueryOperations>
  listenListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'listenList');
    });
  }

  QueryBuilder<AllSettings, String?, QQueryOperations> playerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerName');
    });
  }

  QueryBuilder<AllSettings, int?, QQueryOperations> roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'room');
    });
  }

  QueryBuilder<AllSettings, String, QQueryOperations>
  serverSortFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverSortField');
    });
  }

  QueryBuilder<AllSettings, int, QQueryOperations> sortOptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOption');
    });
  }

  QueryBuilder<AllSettings, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> startupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startup');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations>
  startupAutoConnectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startupAutoConnect');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> startupMinimizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startupMinimize');
    });
  }

  QueryBuilder<AllSettings, String?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<AllSettings, bool, QQueryOperations> userListSimpleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userListSimple');
    });
  }
}
