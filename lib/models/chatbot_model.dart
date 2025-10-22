class ChatbotModel {
  final String? query;
  final String? response;

  ChatbotModel({this.query, this.response});

  factory ChatbotModel.fromJson(Map<String, dynamic> json) {
    return ChatbotModel(response: json['response']);
  }

  Map<String, dynamic> toJson() => {'query': query};
}
