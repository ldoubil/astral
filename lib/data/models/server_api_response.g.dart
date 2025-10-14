// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerApiData _$ServerApiDataFromJson(Map<String, dynamic> json) =>
    ServerApiData(
      items: (json['items'] as List<dynamic>)
          .map((e) => ServerJsonNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$ServerApiDataToJson(ServerApiData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'per_page': instance.perPage,
      'total_pages': instance.totalPages,
    };

ServerApiResponse _$ServerApiResponseFromJson(Map<String, dynamic> json) =>
    ServerApiResponse(
      success: json['success'] as bool,
      data: ServerApiData.fromJson(json['data'] as Map<String, dynamic>),
      error: json['error'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ServerApiResponseToJson(ServerApiResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'message': instance.message,
    };
