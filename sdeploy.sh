#!/bin/bash
run_task() {
	echo ""
	colorize ">> Starting '$1'" "$START_COLOR"
	"$1"
	colorize ">> Finished '$1'" "$END_COLOR"
}

colorize() {
	echo -e "\033[$2m$1\033[0m"
}

START_COLOR=33
END_COLOR=36
CONFIG_FILE_NAME="deploy.cfg"
CONFIG_FILE="$(pwd)/"$CONFIG_FILE_NAME

APP_CONSOLE=
APP_PATH=
APP_NAME=
APP_GIT_REPO=
DRY_RUN=
DEP_ENV=

checkConfigFile () {
	if [ ! -f $CONFIG_FILE ]; then
		echo "Generating config file:"
		touch $CONFIG_FILE
		echo "Your application name (MyApp): "
		read x
		echo "$x" >> $CONFIG_FILE
		echo "Project GIT Repo:"
		read x
		echo "$x" >> $CONFIG_FILE
	fi
}

getEnvironmentVals () {
	checkConfigFile
	APP_NAME="$(sed '1q;d' $CONFIG_FILE)"
	APP_GIT_REPO="$(sed '2q;d' $CONFIG_FILE)"
	APP_PATH="$(pwd)/$APP_NAME/app"
	APP_CONSOLE="$APP_PATH/console"
}

doGitClone(){
	git clone $APP_GIT_REPO "$(pwd)/$APP_NAME"
}

doGitUpdate() {
	if cd "$(pwd)/$APP_NAME"
	then
		if git stash &> /dev/null
		then
			if git pull origin master &> /dev/null
			then
				colorize "PROJECT UPDATED" "$START_COLOR"
			else
				colorize "ERROR UPDATING" "$END_COLOR"
			fi
		else
			doGitClone
		fi
		cd ..
	else
		doGitClone
	fi
}

COMPOSER_UPDATE () {
	if [ "$DRY_RUN" == "N" ]; then
		argv=
	else
		argv=--dry-run
	fi
	
	if cd "$(pwd)/$APP_NAME"
	then
		composer update $argv
		if [ $? -nq 0 ]; then
			echo "Cannot update dependencies, installing using composer install $argv"
			composer install $argv
		fi
		php $APP_CONSOLE doctrine:database:create
	fi
}

SCHEMA_UPDATE () {
	if [ "$DRY_RUN" == "N" ]; then
		argv=--force
	else
		argv=--dump-sql
	fi
	
	php $APP_CONSOLE doctrine:schema:update $argv
}

CACHE_CLEAR () {
	if [ "$DRY_RUN" == "N" ]; then
		rm -rf "$APP_PATH/cache/*"
		php $APP_CONSOLE cache:warmup $DEP_ENV
	else
		echo "Skipped cache clearing!"
	fi
}

INSTALL_ASSETS () {
	if [ "$DRY_RUN" == "N" ]; then
		php $APP_CONSOLE assets:install $DEP_ENV
	else
		echo "Skipped installing assets!"
	fi
}

ASSETIC_DUMP () {
	if [ "$DRY_RUN" == "N" ]; then
		php $APP_CONSOLE assetic:dump $DEP_ENV
	else
		echo "Skipped dumping assetics!"
	fi
}
####################
# Script Execution #
####################

getEnvironmentVals
doGitUpdate

echo "Do you want to dry run the deployment? (*/N)"
read DRY_RUN

echo "Do you want to run the deployment on Production environment? (Y/*)"
read DEP_ENV

if [ "$DRY_RUN" = "" ]|| [ "$DRY_RUN" = "N" ] || [ "$DRY_RUN" = "n" ]; then DRY_RUN="N"; fi
if [ "$DEP_ENV" = "" ] || [ "$DEP_ENV" = "Y" ] || [ "$DEP_ENV" = "y" ]; then DEP_ENV="--env=prod"; else DEP_ENV="--env=dev"; fi

run_task "COMPOSER_UPDATE"
run_task "SCHEMA_UPDATE"
run_task "CACHE_CLEAR"
run_task "INSTALL_ASSETS"
run_task "ASSETIC_DUMP"
