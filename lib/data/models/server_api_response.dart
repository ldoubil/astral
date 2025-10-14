import 'package:json_annotation/json_annotation.dart';
import 'server_json_node.dart';

part 'server_api_response.g.dart';

@JsonSerializable()
class ServerApiData {
  final List<ServerJsonNode> items;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  ServerApiData({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory ServerApiData.fromJson(Map<String, dynamic> json) => _$ServerApiDataFromJson(json);
  Map<String, dynamic> toJson() => _$ServerApiDataToJson(this);
}

@JsonSerializable()
class ServerApiResponse {
  final bool success;
  final ServerApiData data;
  final String? error;
  final String? message;

  ServerApiResponse({
    required this.success,
    required this.data,
    this.error,
    this.message,
  });

  factory ServerApiResponse.fromJson(Map<String, dynamic> json) => _$ServerApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServerApiResponseToJson(this);
}