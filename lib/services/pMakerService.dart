import 'dart:convert';
import 'package:http/http.dart' as http;

class PMakerService {
  //Service authentification
  Future<http.Response> signIn(String email, String password) async {
    try {
      var url = "http://process.isiforge.tn/isi/oauth2/token";
      return await http.post(url,
          headers: {"content-type": "application/json"},
          body: json.encode({
            "grant_type": "password",
            "username": email,
            "password": password,
            "scope": "*",
            "client_id": "WMZNSSETCJDPTZSVETRNOPGYFKMAKHHQ",
            "client_secret": "5813427175e8e5d18452a90035077331"
          }));
    } catch (e) {
      print(e);
      return null;
    }
  }

// Get all cases
  Future<http.Response> getCases(String token) async {
    try {
      var url = "http://process.isiforge.tn/api/1.0/isi/case/start-cases";
      return await http.get(
        url,
        headers: {'Authorization': 'Bearer ' + token},
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

//Get case details
  Future<http.Response> getCaseDetails(String token, String id) async {
    try {
      var url = "http://process.isiforge.tn/api/1.0/isi/project/$id";
      return await http.get(
        url,
        headers: {'Authorization': 'Bearer ' + token},
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

//Start Case
  Future<http.Response> startCase(String token, String id) async {
    try {
      var url1 =
          "http://process.isiforge.tn/api/1.0/isi/project/$id/starting-tasks";
      var res = await http.get(
        url1,
        headers: {'Authorization': 'Bearer ' + token},
      );
      if (res.statusCode == 200) {
        String actUid = json.decode(res.body)[0]['act_uid'];
        var url2 =
            "http://process.isiforge.tn/api/1.0/isi/project/$id/activity/$actUid/steps";
        res = await http.get(
          url2,
          headers: {'Authorization': 'Bearer ' + token},
        );

        if (res.statusCode == 200) {
          String typeObj = json.decode(res.body)[0]['step_type_obj'];
          String uidObj = json.decode(res.body)[0]['step_uid_obj'];
          var url3 =
              "http://process.isiforge.tn/api/1.0/isi/extrarest/$typeObj/$uidObj";
          return await http.get(
            url3,
            headers: {'Authorization': 'Bearer ' + token},
          );
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> formToDraft(Map<String, dynamic> data, String proUid,
      String tasUid, String token) async {
    try {
      var url = "http://process.isiforge.tn/api/1.0/isi/cases";
      return await http.post(url,
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + token
          },
          body: json.encode({
            "pro_uid": proUid,
            "tas_uid": tasUid,
            "variables": [data],
          }));
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> submitForm(String proUid, String token) async {
    try {
      var url =
          "http://process.isiforge.tn/api/1.0/isi/cases/$proUid/route-case";
      return await http.put(
        url,
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> getDrafts(String token, int start, int limit) async {
    try {
      var url =
          "http://process.isiforge.tn/api/1.0/isi/cases/draft?start=$start&limit=$limit";
      return await http.get(
        url,
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> getToDO(String token, int start, int limit) async {
    try {
      var url =
          "http://process.isiforge.tn/api/1.0/isi/cases/participated?start=$start&limit=$limit";
      return await http.get(
        url,
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<http.Response> getVariables(String token, String uid) async {
    try {
      var url = "http://process.isiforge.tn/api/1.0/isi/cases/$uid/variables";
      return await http.get(
        url,
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer ' + token
        },
      );
    } catch (e) {
      print(e);
      return null;
    }
  }
   Future<http.Response> updateVariables(String token, String uid,Map<String,dynamic> variables) async {
    try {
      var url = "http://process.isiforge.tn/api/1.0/isi/cases/$uid/variable";
      return await http.put(
        url,
        headers: {
          'Authorization': 'Bearer ' + token
        },
        body: variables
      );
    } catch (e) {
      print(e);
      return null;
    }
  }
}
