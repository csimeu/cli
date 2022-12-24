# include .env.local

# Parameters
remote=atelier-cen




# Misc
.DEFAULT_GOAL = help
.PHONY        : # Not needed here, but you can put your all your targets to be sure
                # there is no name conflict between your files and your targets.

## —— 🐝 The AREA-APISERVER Makefile 🐝 ———————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'


## —— Cli ————————————————————————————————————————————————————————————————
build: ## Build
	@cpm-build

push: build ## Git push origin
	git add -A && git commit -m "@updates"
	git checkout master && git merge devel && git co devel && git push $(remote) master 
