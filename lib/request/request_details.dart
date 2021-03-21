class RequestDetails {
  final Uri uri;
  final Map<String, String> parameters;
  final Map<String, String> headers;

  RequestDetails({
    required this.uri,
    required this.parameters,
    required this.headers,
  });

  void setParametersFromConfig(final String name, final String? value) {
    if (value != null) {
      parameters[name] = value;
    }
  }

  void addConfigToParameters(final String name, final String? value) {
    if (value != null) {
      parameters.putIfAbsent(name, () => value);
    }
  }
}
