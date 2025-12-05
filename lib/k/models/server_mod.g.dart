// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_mod.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetServerModCollection on Isar {
  IsarCollection<ServerMod> get serverMods => this.collection();
}

const ServerModSchema = CollectionSchema(
  name: r'ServerMod',
  id: 3724355831027954292,
  properties: {
    r'enable': PropertySchema(id: 0, name: r'enable', type: IsarType.bool),
    r'http': PropertySchema(id: 1, name: r'http', type: IsarType.bool),
    r'https': PropertySchema(id: 2, name: r'https', type: IsarType.bool),
    r'name': PropertySchema(id: 3, name: r'name', type: IsarType.string),
    r'quic': PropertySchema(id: 4, name: r'quic', type: IsarType.bool),
    r'sortOrder': PropertySchema(
      id: 5,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'srv': PropertySchema(id: 6, name: r'srv', type: IsarType.bool),
    r'tcp': PropertySchema(id: 7, name: r'tcp', type: IsarType.bool),
    r'txt': PropertySchema(id: 8, name: r'txt', type: IsarType.bool),
    r'udp': PropertySchema(id: 9, name: r'udp', type: IsarType.bool),
    r'url': PropertySchema(id: 10, name: r'url', type: IsarType.string),
    r'wg': PropertySchema(id: 11, name: r'wg', type: IsarType.bool),
    r'ws': PropertySchema(id: 12, name: r'ws', type: IsarType.bool),
    r'wss': PropertySchema(id: 13, name: r'wss', type: IsarType.bool),
  },

  estimateSize: _serverModEstimateSize,
  serialize: _serverModSerialize,
  deserialize: _serverModDeserialize,
  deserializeProp: _serverModDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _serverModGetId,
  getLinks: _serverModGetLinks,
  attach: _serverModAttach,
  version: '3.3.0',
);

int _serverModEstimateSize(
  ServerMod object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _serverModSerialize(
  ServerMod object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enable);
  writer.writeBool(offsets[1], object.http);
  writer.writeBool(offsets[2], object.https);
  writer.writeString(offsets[3], object.name);
  writer.writeBool(offsets[4], object.quic);
  writer.writeLong(offsets[5], object.sortOrder);
  writer.writeBool(offsets[6], object.srv);
  writer.writeBool(offsets[7], object.tcp);
  writer.writeBool(offsets[8], object.txt);
  writer.writeBool(offsets[9], object.udp);
  writer.writeString(offsets[10], object.url);
  writer.writeBool(offsets[11], object.wg);
  writer.writeBool(offsets[12], object.ws);
  writer.writeBool(offsets[13], object.wss);
}

ServerMod _serverModDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ServerMod(
    enable: reader.readBoolOrNull(offsets[0]) ?? false,
    http: reader.readBoolOrNull(offsets[1]) ?? false,
    https: reader.readBoolOrNull(offsets[2]) ?? false,
    id: id,
    name: reader.readString(offsets[3]),
    quic: reader.readBoolOrNull(offsets[4]) ?? false,
    sortOrder: reader.readLongOrNull(offsets[5]) ?? 0,
    srv: reader.readBoolOrNull(offsets[6]) ?? false,
    tcp: reader.readBoolOrNull(offsets[7]) ?? false,
    txt: reader.readBoolOrNull(offsets[8]) ?? false,
    udp: reader.readBoolOrNull(offsets[9]) ?? false,
    url: reader.readString(offsets[10]),
    wg: reader.readBoolOrNull(offsets[11]) ?? false,
    ws: reader.readBoolOrNull(offsets[12]) ?? false,
    wss: reader.readBoolOrNull(offsets[13]) ?? false,
  );
  return object;
}

P _serverModDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 13:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _serverModGetId(ServerMod object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _serverModGetLinks(ServerMod object) {
  return [];
}

void _serverModAttach(IsarCollection<dynamic> col, Id id, ServerMod object) {
  object.id = id;
}

extension ServerModQueryWhereSort
    on QueryBuilder<ServerMod, ServerMod, QWhere> {
  QueryBuilder<ServerMod, ServerMod, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ServerModQueryWhere
    on QueryBuilder<ServerMod, ServerMod, QWhereClause> {
  QueryBuilder<ServerMod, ServerMod, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterWhereClause> idBetween(
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

extension ServerModQueryFilter
    on QueryBuilder<ServerMod, ServerMod, QFilterCondition> {
  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> enableEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enable', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> httpEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'http', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> httpsEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'https', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> quicEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quic', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> sortOrderEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition>
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> sortOrderBetween(
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

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> srvEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'srv', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> tcpEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tcp', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> txtEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'txt', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> udpEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'udp', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> wgEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wg', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> wsEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ws', value: value),
      );
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterFilterCondition> wssEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wss', value: value),
      );
    });
  }
}

extension ServerModQueryObject
    on QueryBuilder<ServerMod, ServerMod, QFilterCondition> {}

extension ServerModQueryLinks
    on QueryBuilder<ServerMod, ServerMod, QFilterCondition> {}

extension ServerModQuerySortBy on QueryBuilder<ServerMod, ServerMod, QSortBy> {
  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByEnable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enable', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByEnableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enable', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByHttp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'http', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByHttpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'http', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByHttps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'https', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByHttpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'https', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByQuic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quic', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByQuicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quic', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortBySrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'srv', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortBySrvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'srv', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByTcp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tcp', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByTcpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tcp', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByTxt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txt', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByTxtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txt', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByUdp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'udp', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByUdpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'udp', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wg', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wg', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ws', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ws', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wss', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> sortByWssDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wss', Sort.desc);
    });
  }
}

extension ServerModQuerySortThenBy
    on QueryBuilder<ServerMod, ServerMod, QSortThenBy> {
  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByEnable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enable', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByEnableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enable', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByHttp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'http', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByHttpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'http', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByHttps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'https', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByHttpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'https', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByQuic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quic', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByQuicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quic', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenBySrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'srv', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenBySrvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'srv', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByTcp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tcp', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByTcpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tcp', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByTxt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txt', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByTxtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'txt', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByUdp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'udp', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByUdpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'udp', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wg', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wg', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ws', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ws', Sort.desc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWss() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wss', Sort.asc);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QAfterSortBy> thenByWssDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wss', Sort.desc);
    });
  }
}

extension ServerModQueryWhereDistinct
    on QueryBuilder<ServerMod, ServerMod, QDistinct> {
  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByEnable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enable');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByHttp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'http');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByHttps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'https');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByQuic() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quic');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctBySrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'srv');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByTcp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tcp');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByTxt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'txt');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByUdp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'udp');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByWg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wg');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByWs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ws');
    });
  }

  QueryBuilder<ServerMod, ServerMod, QDistinct> distinctByWss() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wss');
    });
  }
}

extension ServerModQueryProperty
    on QueryBuilder<ServerMod, ServerMod, QQueryProperty> {
  QueryBuilder<ServerMod, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> enableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enable');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> httpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'http');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> httpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'https');
    });
  }

  QueryBuilder<ServerMod, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> quicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quic');
    });
  }

  QueryBuilder<ServerMod, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> srvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'srv');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> tcpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tcp');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> txtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'txt');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> udpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'udp');
    });
  }

  QueryBuilder<ServerMod, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> wgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wg');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> wsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ws');
    });
  }

  QueryBuilder<ServerMod, bool, QQueryOperations> wssProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wss');
    });
  }
}
