var myDataRef = new Firebase('https://g0v-fukuball.firebaseio.com/');
var authClient = new FirebaseAuthClient(myDataRef, function(error, user) {
  if (error) {
    // an error occurred while attempting login
    console.log(error);
  } else if (user) {
    // user authenticated with Firebase
    console.log('User ID: ' + user.id + ', Provider: ' + user.provider);
    $('#login-block').css('display', 'none');
    $('#logout-block').css('display', 'block');
  } else {
    // user is logged out
    $('#login-block').css('display', 'block');
    $('#logout-block').css('display', 'none');
  }
});
window.start = function() {
  $('#messageSend').on('click', function(event){
    console.log('click');
    var name = $('#nameInput').val();
    var text = $('#messageInput').val();
    myDataRef.push({name: name, text: text});
    $('#messageInput').val('');
  });
  myDataRef.on('child_added', function(snapshot) {
    var message = snapshot.val();
    displayChatMessage(message.name, message.text);
  });
  function displayChatMessage(name, text) {
    $('<div/>').text(text).prepend($('<em/>').text(name+': ')).appendTo($('#messagesDiv'));
    $('#messagesDiv')[0].scrollTop = $('#messagesDiv')[0].scrollHeight;
  };
  $('#github-login-link').on('click', function(event){
    authClient.login('github', {
      rememberMe: true,
      scope: 'user,gist'
    });
  });
  $('#logout-link').on('click', function(event){
    authClient.logout();
  });

}