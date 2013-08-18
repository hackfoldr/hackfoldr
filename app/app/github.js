var Github = (function($) {
	var API_PROXY = 'http://utcr.org:8080';

	// Parse date string in ISO8601 format into javascript Date object.
	// See: http://stackoverflow.com/a/4829642
	var MONTHS = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];
	var parse_iso8601 = function(iso8601) {
		// Convert from ISO8601 to ISO2822 so Date.parse() can handle.
		// XXX: Date.parse() in some JS engine can parse ISO8601?!
		//      For example, Firefox 4 (JS 1.8.5).
		var iso2822 = iso8601.replace(
			/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|\w{3})/,
			function(str, yyyy, mm, dd, HH, MM, SS, zone) {
				return dd + ' ' + MONTHS[mm-1] + ' ' + yyyy + ' ' + HH + ':' + MM + ':' + SS + ' GMT';
			}
		);
		return new Date(Date.parse(iso2822));
	};

	var parse_ghurl = function(url) {
		if (url) {
			var found = url.match(/^((http|https):\/\/github\.com\/([^\/]+)\/([^\/]+))(\/.*)?$/);
			if (found) {
				return {
					url:   found[1],
					owner: found[3],
					repo:  found[4],
					name:  found[3] + '/' + found[4], // e.g., g0v/hack.g0v.tw
				};
			}
			return null;
		}
	};

	/**
	 * Resolve Github API specification with parameter interpolated:
	 * - Interpolate params into url_spec
	 * - Replace prefix with APY_PROXY if it exist
	 */
	var ghapi = function(url_spec, params) {
		var found = url_spec.match(/^(((http|https):\/\/(api\.github\.com)(:[0-9]+)?)(\/.*)?)$/);
		var url = API_PROXY ? API_PROXY : found[2];
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
		return url;
	};

	var on_update_do = function() {};
	var repositories = {};
	var every_issues = {};
	var issue_orders = { // name: compare_function
		updated_at_desc: function(a, b) {
			var t1 = parse_iso8601(every_issues[b].updated_at);
			var t2 = parse_iso8601(every_issues[a].updated_at);
			return (t1 > t2) - (t1 < t2);
		},
	};

	var load_issues2 = function(name) {
		var repo = repositories[name];
		if (repo) {
			$.getJSON(ghapi(repo.issues_url), function(issues) {
				$.each(issues, function(i, issue) {
					issue.key = name + '#' + issue.number;
					issue.repo = name.split('/')[1];
					every_issues[issue.key] = issue;
				});
				on_update_do();
			});
		}
	};

	return {
//		// These interfaces are exposed for debugging/testing.
//		ghapi: ghapi,
//		parse_iso8601: parse_iso8601,
//		get_repositories: function() { return repositories; },
//		get_every_issues: function() { return every_issues; },

		add_repository: function(url, name_zh) {
			var r = parse_ghurl(url);
			if (r) {
				// XXX: We should be able to write the url spec as: {/owner{/repo}}.
				$.getJSON(ghapi('https://api.github.com/repos{/owner}{/repo}', r), function(repo) {
					if (repo.has_issues) {
						if (!repositories[repo.full_name]) {
							repo.name_zh = name_zh;
							repositories[repo.full_name] = repo;
							load_issues2(repo.full_name); // XXX: or trigger by setTimeout()?
						}
					}
				});
			}
		},

		set_on_update: function(fn) { on_update_do = fn; },

		num_issues: function() {
			return Object.keys(every_issues).length;
		},

		get_issues: function(filter) {
			var issue_keys = Object.keys(every_issues)
			                       .sort(issue_orders['updated_at_desc']);
			if (filter && filter.by_project && (filter.by_project != 'all')) {
				issue_keys = $.grep(issue_keys, function(issue_key) {
					return (issue_key.split('/')[1].split('#')[0] == filter.by_project);
				});
			}
			return $.map(issue_keys, function(issue_key) {
				return every_issues[issue_key];
			});
		},

		get_repositories: function() {
			return $.map(Object.keys(repositories), function(repo_full_name) {
				return repositories[repo_full_name];
			});
		},

		has_issues: function(url) {
			return $.grep(Object.keys(repositories), function(key) {
				return ((repositories[key].html_url == url)
				     && (repositories[key].has_issues));
			}).length > 0;
		},

		'url_to_repo_name': function(url) {
			var r = parse_ghurl(url);
			return r ? r.repo : null;
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
	$scope.opt_project = 'all';
	$scope.$watch('opt_project', function() {
//		console.log($scope.opt_project);
		$scope.setPage();
	});
	$scope.set_project = function(name) {
		$scope.opt_project = name;
	};

	$scope.projects = [];
	$scope.issues = [];
	$scope.numPerPage = 5;
	$scope.currentPage = 1;
	$scope.setPage = function() {
		var issues = Github.get_issues(/*filter*/{
			by_project: $scope.opt_project,
		});
		$scope.numPages = Math.ceil(issues.length / $scope.numPerPage);
		var offset = ($scope.currentPage - 1) * $scope.numPerPage;
		$scope.issues = issues.slice(offset, offset + $scope.numPerPage);
	};
	$scope.$watch('currentPage', $scope.setPage);
	Github.set_on_update(function() {
		$scope.projects = Github.get_repositories();
		$scope.setPage();
	});

	$scope.firebase_projects = Hub.projects;
	$scope.$watch('firebase_projects.length', function() {
		angular.forEach($scope.firebase_projects, function(value, key) {
			if (value.repository) {
				Github.add_repository(value.repository.url, value.name_zh);
			}
		});
	});

	$scope.$watch('issues', function() {
		if ($scope.issues.length) {
			$(".issues-loading").hide();
		}
	});
}]);

