class PhotoMemo {
  String docID;
  String createdBy;
  String title;
  String memo;
  String photoFilename;
  String photoURL;
  DateTime timestamp;
  List<dynamic> sharedWith;
  List<dynamic> imageLabels;
  List<dynamic> comments;

  PhotoMemo(
    String docID,
    Map<String, dynamic> data,
  ) {
    this.docID = docID ?? "";
    this.title = data['title'] ?? "";
    this.memo = data['Memo'] ?? "";
    this.photoURL = data['imgurl'] ?? "";
    this.photoFilename = data['imgname'] ?? "";
    this.sharedWith = data['sharedwith'] ?? [];
    this.createdBy = data['createdBy'] ?? "";
    this.imageLabels=data['photoLabels']?? [];
    this.comments=data['comments']?? [];
  }

  static String validateTitle(String value) {
    if (value == null || value.length < 3)
      return 'too short';
    else
      return null;
  }

  static String validateMemo(String value) {
    if (value == null || value.length < 5)
      return 'too short';
    else
      return null;
  }

  static String validateShareWith(String value) {
    if (value == null || value.trim().length == 0) return null;

    List<String> emailList =
        value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma (,) or space seperated email list';
    }
    return null;
  }
}
