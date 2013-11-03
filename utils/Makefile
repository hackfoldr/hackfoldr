JQ=$(shell which jq )
all:
	@echo "Nothing for all"

update-labels: token labels create-github-labels.sh
	@echo "=================================="
	@echo "The following command will be run:"
	@echo "=================================="
	@cat ./create-github-labels.sh
	@echo "=================================="
	@echo "With labels file:"
	@echo "=================================="
	@cat ./labels

	@read -p "Are you sure? [y/n] " option; \
    if [ "$$option" == 'y' ]; then sh ./create-github-labels.sh; fi

check-jq:
	@if [ -z "$(JQ)" ] ; then \
    	echo "ERROR: jq not found." >&2; \
        exit 1; \
	fi;

token: username=$(shell read -p 'Github username: ' username; echo $$username)
token: password=$(shell read -s -p 'Github password: ' password; echo $$password)
token:
	@echo ""; \
	perl ./github-add-repo-issue-labels.pl --output-token-only --username="$(username)" --password="$(password)" > token;
	@[ -s "./token" ] || rm token;


# TODO filter commands by a specific github user.
create-github-labels.sh:
	@curl -sS https://g0vhub.firebaseio.com/projects.json | jq '[.[] | .["repository"]["url"] ]' | grep https | tr -d '" ,' |  awk -F'/' '{ printf "perl ./github-add-repo-issue-labels.pl --token=\"`cat ./token`\" --labels=\"`cat ./labels`\" --org=%s --repo=%s\n", $$4, $$5 }' > create-github-labels.sh
	@chmod +x create-github-labels.sh
	@cat create-github-labels.sh

clean:
	rm -f labels
	rm -f token
	rm -f create-github-labels.sh

labels: check-jq
	@cat ../app/config.jsenv | $(JQ) -r  '.G0V_LABELS | .[] | .name + "|" + .color' > labels
	@cat ./labels

.PHONY: check-jq clean all update-labels
