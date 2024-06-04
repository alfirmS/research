#Change version after edit templates

Version: 3.4

Changelog:
-- fix(new-variable) New variable ENV_FOLDER
-- fix(jenkinsfile) Change stage deploy process
-- fix(jenkinsfie&template) Add new template DEV & RC, Change Jenkinsfile for DEV & RC and Change ENV to ENV_FOLDER in Jenkinsfile
-- fix(templates) Efficiency templates
-- fix(sshagent) Add ssh agent in stages k8s-template/Jenkinsfile and k8s-template-beta-prod/Jenkinsfile
-- fix(Jenkinsfile) Change """ to '''
-- fix(commit) Add CLI Commit
-- fix(bug) Checking folder log push
-- add(test) test push
-- fix(build-template) Fixing folder log-push not exist
-- fix(bug) fixing tag docker
-- fix(bug) Create folder log-push in template build pushcommit
-- fix(delete) delete stage vault send to secret deployment
-- fix(add) Mounting env/secret
-- fix(bug) Template DEV and RC
-- change(name-image) Change format image DEV-RC
-- Fix(bug) Change format name image in template pushcommit
-- fix(bug) Checking file log push
-- fix(bug) Checking file log push dev or prod
-- fix(bug) Add new push commit devrc and change name image in beta prod push commit
-- fix(pushcommit) Delete pushcommit devrc and change pushcommit betaprod
