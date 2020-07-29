class CaseDetails {
  String name;
  String description;
  CaseDetails({
    this.name,
    this.description,
  });

  CaseDetails.fromMap(Map snapshot)
      : name = snapshot['prj_name'] ?? '',
        description = snapshot['prj_description'] ?? '';
}
