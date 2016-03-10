# Symfony-Deploy
Simple symfony2 deploy script

## Indroduction
This is a very simple and advanced bash script which helps you throught your application deployment.
Just clone the project, make it globally available from bash command, go to your directory and run the script!

## Installation
### 1. Clone the project 
Simply run the following command:
`git clone https://github.com/AienTech/Symfony-Deploy.git <Symfony-Deploy-Path>`

### 2. Move it to Bin directory
We will make this script gllobaly available using this command:
`sudo mv <Symfony-Deploy-Path>/sdeploy.sh /usr/bin/sdeploy`
and then
`sudo chmod a+x /usr/bin/sdeploy`

## Usage
1. `cd` to the directory which you want to deploy your project (i.e `/var/www/myapp`)
2. run `sdeploy`
3. enter your app name (A directory will be generated in `/var/www/myapp/appname`)
4. enter the git repo address for your project
5. let the script do it's job

## BUGS
I've tested this script in my server and some few other environments and it worked without any problems. If you faced any bugs, please let me know so I could fix it as soon as I can.

## To-Do
- Automatically generate `.htaccess` to `myapp`
