var myDataRef;
var authClient;
$(function() {
  myDataRef = new Firebase(window.global.config.FIREBASE);
  authClient = new FirebaseAuthClient(myDataRef, function(error, user) {
    if (error) {
      // an error occurred while attempting login
      console.log(error);
    } else if (user) {
      // user authenticated with Firebase
      console.log(user);
      console.log('User ID: ' + user.id + ', Provider: ' + user.provider);
      $('#login-block').css('display', 'none');
      $('#logout-block').css('display', 'block');

      var g0vUserKey = [user.provider, user.id].join('|').toLowerCase();
      var g0vUserDisplayName = user.displayName;
      var g0vAvatarUrl = user.avatar_url;
      var g0vEmail = user.email;

      $('#login-user-info').html(g0vUserDisplayName);
      var g0vUsersRef = myDataRef.child("g0vUsers");
      var g0vUserRef = g0vUsersRef.child(g0vUserKey);

      g0vUserRef.once("value", function(peopleSnap) {
        console.log(peopleSnap);
        var info = {};
        var val = peopleSnap.val();
        if (!val) {
          console.log("first time login");
          info = {
            g0v_user_id: g0vUserKey,
            display_name: g0vUserDisplayName,
            avatar_url: g0vAvatarUrl,
            email: g0vEmail
          };
          g0vUserRef.set(info);
        } else {
          console.log("account exist");
          info = val;
          console.log(info);
        }
        /*
        info = {
          g0vUserKey: g0vUserKey
        };
        g0vUserRef.set(info);
        */
      });

    } else {
      // user is logged out
      $('#login-block').css('display', 'block');
      $('#logout-block').css('display', 'none');
    }
  });
});
window.loginCheck = function() {
  $('#github-login-link').on('click', function(event){
    authClient.login('github', {
      rememberMe: true,
      scope: 'user,gist'
    });
  });
}