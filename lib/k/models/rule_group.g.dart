// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_group.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRuleGroupCollection on Isar {
  IsarCollection<RuleGroup> get ruleGroups => this.collection();
}

const RuleGroupSchema = CollectionSchema(
  name: r'RuleGroup',
  id: -6311251632446884521,
  properties: {
    r'name': PropertySchema(id: 0, name: r'name', type: IsarType.string),
    r'regex': PropertySchema(id: 1, name: r'regex', type: IsarType.string),
    r'rules': PropertySchema(
      id: 2,
      name: r'rules',
      type: IsarType.objectList,

      target: r'Rule',
    ),
  },

  estimateSize: _ruleGroupEstimateSize,
  serialize: _ruleGroupSerialize,
  deserialize: _ruleGroupDeserialize,
  deserializeProp: _ruleGroupDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'Rule': RuleSchema},

  getId: _ruleGroupGetId,
  getLinks: _ruleGroupGetLinks,
  attach: _ruleGroupAttach,
  version: '3.3.0',
);

int _ruleGroupEstimateSize(
  RuleGroup object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.regex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.rules.length * 3;
  {
    final offsets = allOffsets[Rule]!;
    for (var i = 0; i < object.rules.length; i++) {
      final value = object.rules[i];
      bytesCount += RuleSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _ruleGroupSerialize(
  RuleGroup object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeString(offsets[1], object.regex);
  writer.writeObjectList<Rule>(
    offsets[2],
    allOffsets,
    RuleSchema.serialize,
    object.rules,
  );
}

RuleGroup _ruleGroupDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RuleGroup(
    name: reader.readStringOrNull(offsets[0]),
    regex: reader.readStringOrNull(offsets[1]),
    rules:
        reader.readObjectList<Rule>(
          offsets[2],
          RuleSchema.deserialize,
          allOffsets,
          Rule(),
        ) ??
        const [],
  );
  object.id = id;
  return object;
}

P _ruleGroupDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readObjectList<Rule>(
                offset,
                RuleSchema.deserialize,
                allOffsets,
                Rule(),
              ) ??
              const [])
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ruleGroupGetId(RuleGroup object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ruleGroupGetLinks(RuleGroup object) {
  return [];
}

void _ruleGroupAttach(IsarCollection<dynamic> col, Id id, RuleGroup object) {
  object.id = id;
}

extension RuleGroupQueryWhereSort
    on QueryBuilder<RuleGroup, RuleGroup, QWhere> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RuleGroupQueryWhere
    on QueryBuilder<RuleGroup, RuleGroup, QWhereClause> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterWhereClause> idBetween(
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

extension RuleGroupQueryFilter
    on QueryBuilder<RuleGroup, RuleGroup, QFilterCondition> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'name'),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'name'),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameEqualTo(
    String? value, {
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameGreaterThan(
    String? value, {
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameLessThan(
    String? value, {
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameContains(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'regex'),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'regex'),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'regex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'regex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'regex',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'regex', value: ''),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> regexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'regex', value: ''),
      );
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rules', length, true, length, true);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rules', 0, true, 0, true);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rules', 0, false, 999999, true);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rules', 0, true, length, include);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition>
  rulesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'rules', length, include, 999999, true);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'rules',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RuleGroupQueryObject
    on QueryBuilder<RuleGroup, RuleGroup, QFilterCondition> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterFilterCondition> rulesElement(
    FilterQuery<Rule> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'rules');
    });
  }
}

extension RuleGroupQueryLinks
    on QueryBuilder<RuleGroup, RuleGroup, QFilterCondition> {}

extension RuleGroupQuerySortBy on QueryBuilder<RuleGroup, RuleGroup, QSortBy> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> sortByRegex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regex', Sort.asc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> sortByRegexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regex', Sort.desc);
    });
  }
}

extension RuleGroupQuerySortThenBy
    on QueryBuilder<RuleGroup, RuleGroup, QSortThenBy> {
  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenByRegex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regex', Sort.asc);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QAfterSortBy> thenByRegexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regex', Sort.desc);
    });
  }
}

extension RuleGroupQueryWhereDistinct
    on QueryBuilder<RuleGroup, RuleGroup, QDistinct> {
  QueryBuilder<RuleGroup, RuleGroup, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuleGroup, RuleGroup, QDistinct> distinctByRegex({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regex', caseSensitive: caseSensitive);
    });
  }
}

extension RuleGroupQueryProperty
    on QueryBuilder<RuleGroup, RuleGroup, QQueryProperty> {
  QueryBuilder<RuleGroup, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RuleGroup, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<RuleGroup, String?, QQueryOperations> regexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regex');
    });
  }

  QueryBuilder<RuleGroup, List<Rule>, QQueryOperations> rulesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rules');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RuleSchema = Schema(
  name: r'Rule',
  id: -2659006343538057288,
  properties: {
    r'bindNic': PropertySchema(id: 0, name: r'bindNic', type: IsarType.string),
    r'enableAutoNic': PropertySchema(
      id: 1,
      name: r'enableAutoNic',
      type: IsarType.bool,
    ),
    r'matchIp': PropertySchema(id: 2, name: r'matchIp', type: IsarType.string),
    r'matchPort': PropertySchema(
      id: 3,
      name: r'matchPort',
      type: IsarType.long,
    ),
    r'nicNameFilter': PropertySchema(
      id: 4,
      name: r'nicNameFilter',
      type: IsarType.string,
    ),
    r'op': PropertySchema(
      id: 5,
      name: r'op',
      type: IsarType.byte,
      enumMap: _RuleopEnumValueMap,
    ),
    r'replaceIp': PropertySchema(
      id: 6,
      name: r'replaceIp',
      type: IsarType.string,
    ),
    r'replacePort': PropertySchema(
      id: 7,
      name: r'replacePort',
      type: IsarType.long,
    ),
  },

  estimateSize: _ruleEstimateSize,
  serialize: _ruleSerialize,
  deserialize: _ruleDeserialize,
  deserializeProp: _ruleDeserializeProp,
);

int _ruleEstimateSize(
  Rule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bindNic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.matchIp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nicNameFilter;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.replaceIp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _ruleSerialize(
  Rule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bindNic);
  writer.writeBool(offsets[1], object.enableAutoNic);
  writer.writeString(offsets[2], object.matchIp);
  writer.writeLong(offsets[3], object.matchPort);
  writer.writeString(offsets[4], object.nicNameFilter);
  writer.writeByte(offsets[5], object.op.index);
  writer.writeString(offsets[6], object.replaceIp);
  writer.writeLong(offsets[7], object.replacePort);
}

Rule _ruleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Rule(
    bindNic: reader.readStringOrNull(offsets[0]),
    enableAutoNic: reader.readBoolOrNull(offsets[1]),
    matchIp: reader.readStringOrNull(offsets[2]),
    matchPort: reader.readLongOrNull(offsets[3]),
    nicNameFilter: reader.readStringOrNull(offsets[4]),
    op:
        _RuleopValueEnumMap[reader.readByteOrNull(offsets[5])] ??
        OperationType.all,
    replaceIp: reader.readStringOrNull(offsets[6]),
    replacePort: reader.readLongOrNull(offsets[7]),
  );
  return object;
}

P _ruleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_RuleopValueEnumMap[reader.readByteOrNull(offset)] ??
              OperationType.all)
          as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RuleopEnumValueMap = {
  'connect': 0,
  'bind': 1,
  'sendto': 2,
  'recvfrom': 3,
  'all': 4,
};
const _RuleopValueEnumMap = {
  0: OperationType.connect,
  1: OperationType.bind,
  2: OperationType.sendto,
  3: OperationType.recvfrom,
  4: OperationType.all,
};

extension RuleQueryFilter on QueryBuilder<Rule, Rule, QFilterCondition> {
  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'bindNic'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'bindNic'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bindNic',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bindNic',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bindNic',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bindNic', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> bindNicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bindNic', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> enableAutoNicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'enableAutoNic'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> enableAutoNicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'enableAutoNic'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> enableAutoNicEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enableAutoNic', value: value),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'matchIp'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'matchIp'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'matchIp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'matchIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'matchIp',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'matchIp', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'matchIp', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'matchPort'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'matchPort'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'matchPort', value: value),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'matchPort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'matchPort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> matchPortBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'matchPort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nicNameFilter'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nicNameFilter'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nicNameFilter',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nicNameFilter',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nicNameFilter',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nicNameFilter', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> nicNameFilterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nicNameFilter', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> opEqualTo(
    OperationType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'op', value: value),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> opGreaterThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'op',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> opLessThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'op',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> opBetween(
    OperationType lower,
    OperationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'op',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'replaceIp'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'replaceIp'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'replaceIp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'replaceIp',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'replaceIp',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'replaceIp', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replaceIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'replaceIp', value: ''),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'replacePort'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'replacePort'),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'replacePort', value: value),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'replacePort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'replacePort',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Rule, Rule, QAfterFilterCondition> replacePortBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'replacePort',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RuleQueryObject on QueryBuilder<Rule, Rule, QFilterCondition> {}
