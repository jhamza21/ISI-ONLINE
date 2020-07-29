class Case {
  String id;
  String title;
  String idProj;
  Case({
    this.id,
    this.title,
    this.idProj,
  });

  Case.fromMap(Map snapshot)
      : id = snapshot['tas_uid'] ?? '',
        title = snapshot['pro_title'] ?? '',
        idProj = snapshot['pro_uid'] ?? '';
}
