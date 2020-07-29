class InputsType {
  String id;
  String type;
  String label;
  String placeHolder;
  bool require;
  List<dynamic> options;
  List<dynamic> columns;

  InputsType(
      {this.id,
      this.type,
      this.label,
      this.require,
      this.placeHolder,
      this.options,
      this.columns});

  InputsType.fromMap(Map snapshot)
      : id = snapshot['id'] ?? '',
        type = snapshot['type'] ?? '',
        label = snapshot['label'] ?? '',
        placeHolder = snapshot['placeholder'] ?? '',
        require = snapshot['required'] ?? false,
        options = snapshot['options'] ?? null,
        columns = snapshot['columns'] ?? null;
}
