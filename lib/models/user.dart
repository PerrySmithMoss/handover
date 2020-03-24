class UserUpdated {

   String uid;
   String email;
   String profileImageUrl;
   String name;
   String followers;
   String following;
   String posts;
   String bio;

   UserUpdated({this.uid, this.email, this.profileImageUrl, this.name, this.followers, this.following, this.bio, this.posts});

    Map toMap(UserUpdated user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['profileImageUrl'] = user.profileImageUrl;
    data['name'] = user.name;
    data['followers'] = user.followers;
    data['following'] = user.following;
    data['bio'] = user.bio;
    data['posts'] = user.posts;
    return data;
  }

  UserUpdated.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.email = mapData['email'];
    this.profileImageUrl = mapData['profileImageUrl'];
    this.name = mapData['name'];
    this.followers = mapData['followers'];
    this.following = mapData['following'];
    this.bio = mapData['bio'];
    this.posts = mapData['posts'];
  }
}