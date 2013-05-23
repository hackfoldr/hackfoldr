var myDataRef = new Firebase('https://g0v-fukuball.firebaseio.com/');
$("#messageInput").on("click", function(event){
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