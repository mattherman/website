# Personal Website

To run locally:

```
./docker-run.sh
```

Then navigate to http://localhost:4000.

Includes Github Actions that will build the site and archive the result.
To deploy, run the following from the server:

```
wget <artifact_url>
unzip site.zip -d /var/www/matthewherman.net
```
