// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magic_wall_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMagicWallRuleModelCollection on Isar {
  IsarCollection<MagicWallRuleModel> get magicWallRuleModels =>
      this.collection();
}

const MagicWallRuleModelSchema = CollectionSchema(
  name: r'MagicWallRuleModel',
  id: 5823447978384867968,
  properties: {
    r'action': PropertySchema(id: 0, name: r'action', type: IsarType.string),
    r'appPath': PropertySchema(id: 1, name: r'appPath', type: IsarType.string),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'direction': PropertySchema(
      id: 4,
      name: r'direction',
      type: IsarType.string,
    ),
    r'enabled': PropertySchema(id: 5, name: r'enabled', type: IsarType.bool),
    r'localIp': PropertySchema(id: 6, name: r'localIp', type: IsarType.string),
    r'localPort': PropertySchema(
      id: 7,
      name: r'localPort',
      type: IsarType.string,
    ),
    r'name': PropertySchema(id: 8, name: r'name', type: IsarType.string),
    r'priority': PropertySchema(id: 9, name: r'priority', type: IsarType.long),
    r'protocol': PropertySchema(
      id: 10,
      name: r'protocol',
      type: IsarType.string,
    ),
    r'remoteIp': PropertySchema(
      id: 11,
      name: r'remoteIp',
      type: IsarType.string,
    ),
    r'remotePort': PropertySchema(
      id: 12,
      name: r'remotePort',
      type: IsarType.string,
    ),
    r'ruleId': PropertySchema(id: 13, name: r'ruleId', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.long,
    ),
  },

  estimateSize: _magicWallRuleModelEstimateSize,
  serialize: _magicWallRuleModelSerialize,
  deserialize: _magicWallRuleModelDeserialize,
  deserializeProp: _magicWallRuleModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'ruleId': IndexSchema(
      id: -7287016718321404572,
      name: r'ruleId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ruleId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _magicWallRuleModelGetId,
  getLinks: _magicWallRuleModelGetLinks,
  attach: _magicWallRuleModelAttach,
  version: '3.3.0',
);

int _magicWallRuleModelEstimateSize(
  MagicWallRuleModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  {
    final value = object.appPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.direction.length * 3;
  {
    final value = object.localIp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localPort;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.protocol.length * 3;
  {
    final value = object.remoteIp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.remotePort;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.ruleId.length * 3;
  return bytesCount;
}

void _magicWallRuleModelSerialize(
  MagicWallRuleModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeString(offsets[1], object.appPath);
  writer.writeLong(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.description);
  writer.writeString(offsets[4], object.direction);
  writer.writeBool(offsets[5], object.enabled);
  writer.writeString(offsets[6], object.localIp);
  writer.writeString(offsets[7], object.localPort);
  writer.writeString(offsets[8], object.name);
  writer.writeLong(offsets[9], object.priority);
  writer.writeString(offsets[10], object.protocol);
  writer.writeString(offsets[11], object.remoteIp);
  writer.writeString(offsets[12], object.remotePort);
  writer.writeString(offsets[13], object.ruleId);
  writer.writeLong(offsets[14], object.updatedAt);
}

MagicWallRuleModel _magicWallRuleModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MagicWallRuleModel();
  object.action = reader.readString(offsets[0]);
  object.appPath = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readLongOrNull(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.direction = reader.readString(offsets[4]);
  object.enabled = reader.readBool(offsets[5]);
  object.id = id;
  object.localIp = reader.readStringOrNull(offsets[6]);
  object.localPort = reader.readStringOrNull(offsets[7]);
  object.name = reader.readString(offsets[8]);
  object.priority = reader.readLong(offsets[9]);
  object.protocol = reader.readString(offsets[10]);
  object.remoteIp = reader.readStringOrNull(offsets[11]);
  object.remotePort = reader.readStringOrNull(offsets[12]);
  object.ruleId = reader.readString(offsets[13]);
  object.updatedAt = reader.readLongOrNull(offsets[14]);
  return object;
}

P _magicWallRuleModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _magicWallRuleModelGetId(MagicWallRuleModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _magicWallRuleModelGetLinks(
  MagicWallRuleModel object,
) {
  return [];
}

void _magicWallRuleModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  MagicWallRuleModel object,
) {
  object.id = id;
}

extension MagicWallRuleModelByIndex on IsarCollection<MagicWallRuleModel> {
  Future<MagicWallRuleModel?> getByRuleId(String ruleId) {
    return getByIndex(r'ruleId', [ruleId]);
  }

  MagicWallRuleModel? getByRuleIdSync(String ruleId) {
    return getByIndexSync(r'ruleId', [ruleId]);
  }

  Future<bool> deleteByRuleId(String ruleId) {
    return deleteByIndex(r'ruleId', [ruleId]);
  }

  bool deleteByRuleIdSync(String ruleId) {
    return deleteByIndexSync(r'ruleId', [ruleId]);
  }

  Future<List<MagicWallRuleModel?>> getAllByRuleId(List<String> ruleIdValues) {
    final values = ruleIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'ruleId', values);
  }

  List<MagicWallRuleModel?> getAllByRuleIdSync(List<String> ruleIdValues) {
    final values = ruleIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'ruleId', values);
  }

  Future<int> deleteAllByRuleId(List<String> ruleIdValues) {
    final values = ruleIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'ruleId', values);
  }

  int deleteAllByRuleIdSync(List<String> ruleIdValues) {
    final values = ruleIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'ruleId', values);
  }

  Future<Id> putByRuleId(MagicWallRuleModel object) {
    return putByIndex(r'ruleId', object);
  }

  Id putByRuleIdSync(MagicWallRuleModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'ruleId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRuleId(List<MagicWallRuleModel> objects) {
    return putAllByIndex(r'ruleId', objects);
  }

  List<Id> putAllByRuleIdSync(
    List<MagicWallRuleModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'ruleId', objects, saveLinks: saveLinks);
  }
}

extension MagicWallRuleModelQueryWhereSort
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QWhere> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MagicWallRuleModelQueryWhere
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QWhereClause> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  ruleIdEqualTo(String ruleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ruleId', value: [ruleId]),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  ruleIdNotEqualTo(String ruleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ruleId',
                lower: [],
                upper: [ruleId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ruleId',
                lower: [ruleId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ruleId',
                lower: [ruleId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ruleId',
                lower: [],
                upper: [ruleId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'name', value: [name]),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterWhereClause>
  nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [name],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'name',
                lower: [],
                upper: [name],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension MagicWallRuleModelQueryFilter
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QFilterCondition> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'action',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'action',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'action',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'action', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'action', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'appPath'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'appPath'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'appPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'appPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'appPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'appPath', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  appPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'appPath', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdAt'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  createdAtBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'description'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'description'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'direction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'direction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'localIp'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'localIp'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localIp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localIp',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localIp', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localIp', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'localPort'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'localPort'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localPort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localPort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localPort',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localPort', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  localPortIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localPort', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'priority', value: value),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  priorityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  priorityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'priority',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'priority',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'protocol',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'protocol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'protocol',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'protocol', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  protocolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'protocol', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remoteIp'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remoteIp'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteIp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteIp',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteIp', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remoteIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteIp', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'remotePort'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'remotePort'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remotePort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remotePort',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remotePort',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remotePort', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  remotePortIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remotePort', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ruleId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ruleId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ruleId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ruleId', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  ruleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ruleId', value: ''),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterFilterCondition>
  updatedAtBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension MagicWallRuleModelQueryObject
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QFilterCondition> {}

extension MagicWallRuleModelQueryLinks
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QFilterCondition> {}

extension MagicWallRuleModelQuerySortBy
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QSortBy> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByAppPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appPath', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByAppPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appPath', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByLocalIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localIp', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByLocalIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localIp', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByLocalPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPort', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByLocalPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPort', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByProtocol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByProtocolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRemoteIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteIp', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRemoteIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteIp', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRemotePort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remotePort', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRemotePortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remotePort', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MagicWallRuleModelQuerySortThenBy
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QSortThenBy> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByAppPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appPath', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByAppPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appPath', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByLocalIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localIp', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByLocalIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localIp', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByLocalPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPort', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByLocalPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localPort', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByProtocol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByProtocolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocol', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRemoteIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteIp', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRemoteIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteIp', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRemotePort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remotePort', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRemotePortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remotePort', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRuleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByRuleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ruleId', Sort.desc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension MagicWallRuleModelQueryWhereDistinct
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct> {
  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByAction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByAppPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByDirection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByLocalIp({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localIp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByLocalPort({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localPort', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByProtocol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protocol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByRemoteIp({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteIp', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByRemotePort({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remotePort', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByRuleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ruleId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension MagicWallRuleModelQueryProperty
    on QueryBuilder<MagicWallRuleModel, MagicWallRuleModel, QQueryProperty> {
  QueryBuilder<MagicWallRuleModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MagicWallRuleModel, String, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  appPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appPath');
    });
  }

  QueryBuilder<MagicWallRuleModel, int?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<MagicWallRuleModel, String, QQueryOperations>
  directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<MagicWallRuleModel, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  localIpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localIp');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  localPortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localPort');
    });
  }

  QueryBuilder<MagicWallRuleModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MagicWallRuleModel, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<MagicWallRuleModel, String, QQueryOperations>
  protocolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protocol');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  remoteIpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteIp');
    });
  }

  QueryBuilder<MagicWallRuleModel, String?, QQueryOperations>
  remotePortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remotePort');
    });
  }

  QueryBuilder<MagicWallRuleModel, String, QQueryOperations> ruleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ruleId');
    });
  }

  QueryBuilder<MagicWallRuleModel, int?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
