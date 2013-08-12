var Github = (function($) {
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
			var r = parse_ghurl(url);
			var api = 'https://api.github.com/repos/' + r.name + '/' + r.repo + '/issues';
			$.getJSON(api, function(data) {
				// Only select these fields: title, state, body, html_url, label.name
				var issues = [];
				$.each(data, function(i, datum) {
					var issue = { label: [] };
					$.each(
						['title', 'state', 'body', 'html_url'],
						function(j, key) {
							issue[key] = datum[key];
						}
					);
					$.each(datum.labels, function(k, label) {
						issue.label.push(label.name);
					});
					issues.push(issue);
				});
				callback(issues);
			});
		},
	};
})(jQuery);


angular.module("github", [])
.filter('github_url_to_repo_name', function() {
	return function(input) {
		return Github.url_to_repo_name(input);
	};
});

