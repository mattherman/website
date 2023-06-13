# Personal Website

To run locally:

```
./docker-run.sh
```

Then navigate to http://localhost:4000.

Includes Github Actions that will build the site and archive the result.
To deploy, run the following from the server:

```
wget https://github.com/mattherman/mattherman.github.io/releases/latest/download/site.zip
unzip site.zip -d /var/www/matthewherman.net/html
rm site.zip
```
