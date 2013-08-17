var Github = (function($) {
//	var API_BASE = 'https://api.github.com';
	var API_BASE = 'http://utcr.org:8080';

	var copy_fields = function(to, from, fields) {
		$.each(fields, function(j, key) { to[key] = from[key]; });
	};

	var    re_ghurl = /^((http|https):\/\/github\.com\/([^\/]+)\/([^\/]+))(\/.*)?$/;
	var parse_ghurl = function(url) {
		if (url) {
			var found = url.match(re_ghurl);
			if (found) {
				return {
					url:   found[1],
					owner: found[3],
					repo:  found[4],
				};
			}
			return null;
		}
	};

	/**
	 * Resolve Github API specification with parameter interpolated:
	 * - Interpolate params into url_spec
	 * - Replace prefix with API_BASE if it exist
	 */
	var ghapi = function(url_spec, params) {
		var found = url_spec.match(/^(((http|https):\/\/(api\.github\.com)(:[0-9]+)?)(\/.*)?)$/);
		var url = API_BASE ? API_BASE : found[2];
		var path = found[6] ? found[6] : '';
		while (found = path.match(/^([^{}]*)({(\/([^\/{}]+))})(.*)$/)) {
			path = found[1];
			if (params && params[found[4]]) {
				path += '/';
				path += params[found[4]];
			}
			path += found[5];
		}
		url += path;
		console.log(url);
		return url;
	};

	return {
		'url_to_repo_name': function(url) {
			var r = parse_ghurl(url);
//			console.log(r);
			return r ? r.repo : null;
		},
		is_ghurl: function(url) {
			return (url && url.match(re_ghurl));
		},
		load_issues: function(url, callback) {
			if ($.isArray(url)) {
//				console.log('url is array.');
//				console.log(url);
				$.each(url, function(i, u) {
					Github.load_issues(u, callback);
				});
			} else {
//				console.log('loading ' + url);
				var r = parse_ghurl(url);
				var repo_api = API_BASE + '/repos/' + r.owner + '/' + r.repo;
				$.getJSON(repo_api, function(repo) {
					if (repo.has_issues) {
						$.getJSON(repo_api + '/issues', function(data) {
							// Only select these fields: title, state, body, html_url, label.name
							var issues = [];
							$.each(data, function(i, datum) {
//								console.log(datum);
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
.controller('IssueCtrl', [ '$scope', 'Hub', function($scope, Hub) {
	$scope.showFilters = false;

	$scope.data = [];
	$scope.numPerPage = 5;
	$scope.currentPage = 1;
	$scope.setPage = function() {
		var offset = ($scope.currentPage - 1) * $scope.numPerPage;
		$scope.issues = $scope.data.slice(offset, offset + $scope.numPerPage);
	};
	$scope.$watch('currentPage', $scope.setPage);

	var repo_urls = [];
	$scope.projects = Hub.projects;
	$scope.$watch('projects.length', function() {
		angular.forEach($scope.projects, function(value, key) {
			if (value.repository) {
				var url = value.repository.url;
				if (Github.is_ghurl(url) && (repo_urls.indexOf(url) < 0)) {
					repo_urls.push(url);
					Github.load_issues(
						url,
						function(issues) {
							$scope.data = issues.concat($scope.data);
							$scope.numPages = Math.ceil($scope.data.length / $scope.numPerPage);
							if ($scope.currentPage > $scope.numPages) {
								$scope.currentPage = 1;
							}
							$scope.setPage();
						}
					);
				}
			}
		});
//		console.log(repo_urls);
	});

}]);

