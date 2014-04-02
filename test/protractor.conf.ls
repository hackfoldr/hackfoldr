exports.config = do
  allScriptsTimeout: 11000,

  baseURL: 'http://localhost:3333'

  capabilities:
    browserName: 'chrome'

  specs:
    'e2e/app/*.ls'
    ...

if process.env.SAUCE_ACCESS_KEY
  exports.config <<< do
    seleniumAddress: ''
    sauceUser: process.env.SAUCE_USERNAME
    sauceKey: process.env.SAUCE_ACCESS_KEY
    'capabilities.tunnel-identifier': process.env.TRAVIS_JOB_NUMBER
    'capabilities.build': process.env.TRAVIS_BUILD_NUMBER