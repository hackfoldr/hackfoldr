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

    // See: http://www.cplusplus.com/reference/algorithm/find_if/
    // @return index of first element that make pred be true,
    //         or -1 if no element matched
    var find_if = function(array, pred) {
        if (!$.isFunction(pred)) {
            console.error('pred must be a function');
        }
        var first = -1;
        $.each(array, function(index, element) {
            if (pred(element, index)) {
                first = index;
                return false;
            }
        });
        return first;
    };

    // See: http://stackoverflow.com/a/10192255
    var array_unique = function(array) {
        return $.grep(array, function(element, index) {
            return index == $.inArray(element, array);
        });
    };

    /**
     * @param eq functor to test whether or not any 2 array elements are equal
     */
    var array_unique_if = function(array, eq) {
        if (!$.isFunction(eq)) {
            console.error('eq must be a function');
        }
        return $.grep(array, function(x, i) {
            var prior = find_if(array.slice(0, i), function(y, j) {
                return eq(y, x);
            });
            return prior < 0; // pick if there is no same prior elements
        });
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
                    issue.labels = $.map(issue.labels, function(label) {
                        label.colorType = Github.get_label_color_type(label);
                        return label;
                    });
                    every_issues[issue.key] = issue;
                });
                on_update_do();
            });
        }
    };

    return {
//      // These interfaces are exposed for debugging/testing.
//      ghapi: ghapi,
//      parse_iso8601: parse_iso8601,
//      get_repositories: function() { return repositories; },
//      get_every_issues: function() { return every_issues; },
        find_if: find_if,
        array_unique_if: array_unique_if,

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
            if (filter && filter.by_labels && (filter.by_labels.length > 0)) {
                // filter.by_labels is array of label names
//              console.log($.map(filter.by_labels, function(x) { return x.name; }));
                issue_keys = $.grep(issue_keys, function(issue_key) {
                    var matched = $.grep(filter.by_labels, function(label) {
                        // every_issues[issue_key].labels is array of label structures
                        return find_if(every_issues[issue_key].labels, function(x, i) {
                            return x.name == label;
                        }) >= 0;
                    });
                    // AND
                    return matched.length == filter.by_labels.length;
//                  // OR
//                  return matched.length > 0;
                });
            }
            return $.map(issue_keys, function(issue_key) {
                return every_issues[issue_key];
            });
        },

        get_labels: function(filter) {
            delete filter.by_labels;
            var issues = Github.get_issues(filter);
            var labels = array_unique_if(
                $.map(issues, function(issue) { return issue.labels; }),
                function(a, b) { return a.name == b.name; }
            ).sort(function(a, b) {
                var a_name = a && a.name || '';
                var b_name = b && b.name || '';
                return a_name.localeCompare(b_name);
            });
            return labels;
        },

        // determine the type (light || dark) of label color to derive foreground text color
        get_label_color_type: function(label) {
            var color_int = parseInt(label.color, 16); // label.color = AABBCC
            var r = (color_int & 0xff0000) >> 16,
                g = (color_int & 0x00ff00) >> 8,
                b = (color_int & 0x0000ff);
            var luminance = 0.375 * r + 0.5 * g + 0.125 * b;
            var color_type = (luminance > 140) ? "light" : "dark";
            return color_type;
        },

        get_repositories: function() {
            var repo_full_names = Object.keys(repositories).sort(function(a, b) {
                var a_name = repositories[a].name || '';
                var b_name = repositories[b].name || '';
                return a_name.localeCompare(b_name);
            });
            return $.map(repo_full_names, function(repo_full_name) {
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
.controller('IssueCtrl', [ '$scope', 'Hub', function($scope, Hub) {
    $scope.opt_project = 'all';
    $scope.$watch('opt_project', function() {
//      console.log($scope.opt_project);
        $scope.setPage();
    });
    $scope.set_project = function(name) {
        $scope.opt_project = name;
    };

    $scope.opt_labels = []; // array of label names.
    $scope.$watch('opt_labels', function() {
//      console.log($scope.opt_labels);
        $scope.setPage();
    });

    $scope.projects = [];
    $scope.issues = [];
    $scope.numPerPage = 5;
    $scope.currentPage = 1;
    $scope.setPage = function() {
        // Load issues/labels based on given filters.
        var filter = {
            by_project: $scope.opt_project,
            by_labels: $scope.opt_labels,
        };
        var issues = Github.get_issues(filter);
        var labels = Github.get_labels(filter);

        // Set labels to $scope.
        var name_cmp = function(a, b) {
            var a_name = a && a.name || '';
            var b_name = b && b.name || '';
            return a_name.localeCompare(b_name);
        };
        // compile label list for showing in .issue-label-filter
        var g0v_labels = $.map(window.global.config.G0V_LABELS, function(x) {
            x.kind = 'g0v';
            x.text = x.zh ? (x.name + ': ' + x.zh) : x.name;
            return x;
        }).sort(name_cmp);
        var other_labels = $.map(
            $.grep(labels, function(x) {
                return $.inArray(x.name, $.map(g0v_labels, function(y) { return y.name; })) < 0;
            }),
            function(x) {
                x.kind = 'other';
                x.text = x.name; // there is no x.zh field
                return x;
            }
        ).sort(name_cmp);
        $scope.labels = g0v_labels.concat(other_labels); // array of label structures

        // Set issues (of current page) to $scope.
        $scope.numPages = Math.ceil(issues.length / $scope.numPerPage);
        var offset = ($scope.currentPage - 1) * $scope.numPerPage;
        $scope.issues = issues.slice(offset, offset + $scope.numPerPage);
    };
    $scope.$watch('currentPage', $scope.setPage);
    Github.set_on_update(function() {
        $scope.projects = Github.get_repositories();
        $scope.setPage();
    });

    $scope.$on('event:hub-ready', function() {
        $scope.firebase_projects = Hub.projects;
        $scope.$watch('firebase_projects.length', function() {
            angular.forEach($scope.firebase_projects, function(value, key) {
                if (value.repository) {
                    Github.add_repository(value.repository.url, value.name_zh);
                }
            });
        });
    });

    // Do not unbind since $scope.labels may change when we load more labels.
    $scope.$watch('labels', function() {
        if ($scope.labels.length) {
            setTimeout(function() {
                $(".issues-label-filter select").trigger("chosen:updated");
            }, 500);
        }
    });
}]);
