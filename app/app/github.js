var Github = (function($) {
	var copy_fields = function(to, from, fields) {
		$.each(fields, function(j, key) { to[key] = from[key]; });
	};

	var    re_ghurl = /^((http|https):\/\/github\.com\/([^\/]+)\/([^\/]+))(\/.*)?$/;
	var parse_ghurl = function(url) {
		if (url) {
			var found = url.match(re_ghurl);
			if (found) {
				return {
					url:  found[1],
					name: found[3],
					repo: found[4],
				};
			}
			return null;
		}
	};

	return {
		'url_to_repo_name': function(url) {
			var r = parse_ghurl(url);
//			console.log(r);
			return r ? r.repo : null;
		},
		load_issues: function(url, callback) {
			if ($.isArray(url)) {
				console.log('url is array.');
				console.log(url);
				$.each(url, function(i, u) {
					Github.load_issues(u, callback);
				});
			} else {
				console.log('loading ' + url);
				var r = parse_ghurl(url);
//				var api = 'https://api.github.com/repos/' + r.name + '/' + r.repo + '/issues';
				var api = 'http://utcr.org:8080/repos/' + r.name + '/' + r.repo + '/issues';
				$.getJSON(api, function(data) {
					// Only select these fields: title, state, body, html_url, label.name
					var issues = [];
					$.each(data, function(i, datum) {
						console.log(datum);
						var issue = {
							repo: r.repo,
							assignee: datum.assignee,
							labels: []
						};
						copy_fields(issue, datum, ['title', 'state', 'body', 'html_url']);
						$.each(datum.labels, function(k, label) {
							issue.labels.push(label.name);
						});
						issue.label_str = issue.labels.join(':');
						issues.push(issue);
					});
					callback(issues);
				});
			}
		},
	};
})(jQuery);


angular.module("github", [])
.filter('github_url_to_repo_name', function() {
	return function(input) {
		return Github.url_to_repo_name(input);
	};
})
.controller('IssueCtrl', [ '$scope', function($scope) {
	Github.load_issues(
		[ 'http://github.com/g0v/twbudget', 'http://github.com/g0v/hack.g0v.tw' ],
		function(issues) { $scope.issues = issues.concat($scope.issues); }
	);
}]);

