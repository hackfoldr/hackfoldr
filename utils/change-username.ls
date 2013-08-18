require! <[firebase optimist]>

{FIREBASE='https://g0vhub.firebaseio.com', FIREBASE_SECRET} = process.env
root = new firebase FIREBASE
err <- root.auth FIREBASE_SECRET
throw err if err


[old-username, username] = optimist.argv._
console.log old-username
throw "no username" unless username
throw "no username" unless old-username

<- root.child "people/#username" .once 'value'
throw "new username taken" if it.val!

data <- root.child "people/#old-username" .once 'value'

throw "no data" unless data

val = data.val!
for service, info of val.auth
  root.child "auth-map/#service/#{info.id}" .once 'value' ->
    it.ref!update {username}
    console.log \zzz it.val!
root.child "people"

val <<< {username}
console.log val

root.child "people/#username" .set val
data.ref!remove!
