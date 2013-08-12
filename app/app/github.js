var Github = (function() {
	var re_url = /^(http|https):\/\/github\.com\/([^\/]+)\/([^\/]+)(\/.*)?$/;
	return {
		'url_to_repo_name': function(url) {
			if (url) {
				// https://github.com/g0v/twbudget
				var found = url.match(re_url);
				if (found) {
					var user_org = found[2];
					var reponame = found[3];
//					console.log(user_org + '/' + reponame);
					return reponame;
				}
			}
			return url;
		},
	};
})();

angular.module("github", [])
.filter('github_url_to_repo_name', function() {
	return function(input) {
		return Github.url_to_repo_name(input);
	};
});

