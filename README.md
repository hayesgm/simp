# Simp

Simp is a lifecycle management CLI meant to make running a server farm as easy as a single command.

# CLI

The Simp command-line is based on Lisp-syntax (with [] replacing () and ### replacing "").  We did this to make the command-line fully potent (turing complete).  As an example:

     simp build rails

runs the "build" command to tell Simp to build a rails server in your configured Cloud.  But we can do so much more:

     simp [ring staging] add [build mysql]

gets adds a new mysql server to the the staging ring (environment).  Or better:

     simp [ring staging] rem [ring-list staging]

removes all servers from the staging ring.  Moreover,

     simp lb-add [build rails [+ nginx]]

adds a new rails server (using nginx) to load balance, or

     simp bake =Shep Rails= [build rails [+ nginx]]

bakes an "AMI" or appropriate server-image from a new rails +nginx server.

# Tasks:

###Building a Server

%+ Build a Rails server
 - simp build rails
%+ Build a named Rails server
 - simp build rails =Rail Master=
%+ Build a Rails server with AMI xxx
 - simp build rails [mod ami xxx]
+ Build a Rails server with Ruby 1.9.2
 - simp build rails [mod ruby =1.9.2=]
+ Build a Rails server with Unicorn
 - simp build rails [mod unicorn]
+ Build a Sinatra Server
 - simp build sinatra
+ Build a NodeJS Server
 - simp build nodejs 0.8.2
+ Build a Rails Server with a Redis Server
 - simp build rails [+ redis]
+ Build a Rails Server with a Redis Server 2.4.7
 - simp build rails [+ redis 2.4.7]
+ Build a Django Server
 - simp build django
+ Build a Redis Server
 - simp build redis
+ Build a Redis Server as Slave
 - simp build redis [mod slave]
+ Build an NGinx Web Server
 - simp build nginx
+ Build an NGinx Web Server with Reverse Proxy to google.com
 - simp build nginx [mod proxy /google/\$1 google.com]

###Spawning a Server

%+ Spawn a normal server (default config)
 - simp spawn
%+ Spawn a server with mods
 - simp spawn [mod os centos]

###Getting servers

%+ Get a remote server by name
 - simp getr =Geoff=

+ Get a server by type
 - simp getr type:centos

%+ In a command
 - simp install [getr =Geoff=] rails

// + Get a server and install software
//  - simp getr =Geoff= // install rails

###Load Balance

+ Build a Rails server and add it to rotation for Load Balance
 - simp lb-add [build rails [+ nginx]]
+ Add existing server set to Load Balance
 - simp lb add [get rails]
+ Pull specific server out of load balance
 - simp lb-remove [get =john=]

###Baking Servers

+ Bake an AMI from a server config
 - simp bake =Shep Rails= [build rails [+ nginx]]
+ Launch an AMI
 - simp launch =Shep Rails=
+ Add another server to Load Balance
 - simp lb add [launch =Shep Rails=]

###"Tasks"
// TODO -- This is a little tricky
 - simp tasks create install:get_movie <<-EOF
  wget http://my.movie.com/movie.mpg
EOF
 - simp tasks edit install:get_movie
 - simp tasks list

###More Complicated Servers
+ Build a complicated server
 - simp build rails [+ nginx [mod passenger]] [+ emacs] [+ git] [+ free_image] [+ wkhtmltopdf] [+ mudraw]
+ Getting More Complicated
 - simp build rails [+ ruby 1.9.3] [+ nginx [mod passenger 3.0.13]] [+ emacs] [+ git] [+ free_image] [+ wkhtmltopdf] [+ mudraw] [+ cron =0 0 0 0 0 echo \"Hello\"=]

###Custom Build Types
+ Set Custom Build-Types
 - simp buildtype shep_rail rails [+ nginx [mod passenger]] [+ emacs git free_image wkhtmltopdf mudraw]
+ Run build type
 - simp build shep_rails
+ Bake build type
 - simp bake [build shep_rails]

###Rings
+ Create a new ring
 - simp ring-create staging
%+ List all rings
 - simp ring-list
%+ List info about a ring
 - simp ring-info staging
 - simp @staging info
%+ Get a ring
 - simp ring geoff
%+ Get a ring (shorthand)
 - simp @geoff
+ Launch a server in a ring
 - simp ring geoff add [build rails]
+ Add a database to a ring
 - simp [ring geoff] add [build mysql]
+ Create a ring with a rails server and a database
// TODO: Better chaining
 - simp [ring-create staging] lb-add [build rails [mod ruby 1.9.2]] [build mysql]
+ Create a ring with 2 rails servers and a database
 - simp [ring-create staging] lb-add [dup [build rails] 2] [build mysql]
+ Add new server to a ring
 - simp @staging ring-add [build rails]
+ Add existing server to a ring
 - simp [ring staging] add [get =Geoff=]
+ Remove existing server from ring
 - simp [ring staging] rem [get =Geoff=]
%+ Remove all servers from a ring -- Getting a bit crazy here
 - simp [ring staging] rem [ring-list staging]
 - simp @staging rem [ring-list staging]
%+ List all servers in a ring
 - simp [ring staging] list
 - simp ring-list staging
 - simp @staging list
%+ List servers in a ring (verbose)
 - simp @staging list v

###Configuration
%+ Configure Simp by command-line
 - simp config

+ Configure Simp by inputs
 - simp config [set AWS ###]


