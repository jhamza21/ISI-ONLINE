class Draft {
  String num;
  String title;
  String date;
  String uid;
  String proUid;
  String statut;
  Draft({this.num, this.title, this.date, this.uid, this.proUid, this.statut});

  Draft.fromMap(Map snapshot)
      : num = snapshot['app_number'] ?? '',
        uid = snapshot['app_uid'] ?? '',
        title = snapshot['app_pro_title'] ?? '',
        date = snapshot['app_create_date'] ?? '',
        proUid = snapshot['pro_uid'] ?? '',
        statut = snapshot['app_status'] ?? '';
}
