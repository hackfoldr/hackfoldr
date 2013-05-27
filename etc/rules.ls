rules:
  people:
    '.read': true
    $userid:
      '.write': 'auth != null && (data.val() === null || (auth.id == data.child(\'auth/\' + auth.provider + \'/id\').val()))'
  'auth-map':
    $provider:
      $id:
        '.read': 'auth != null && auth.provider === $provider && auth.id === $id'
        '.write': 'auth != null && auth.provider === $provider && auth.id === $id'
  projects:
    '.read': true
    '.write': true
  products:
    '.read': true
    '.write': true
