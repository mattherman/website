# Personal Website

## Local Development

To run locally:

```
./docker-run.sh
```

Then navigate to http://localhost:4000.

## Deployment

The project includes Github Actions that will build the site and archive the result.

To deploy, copy the `deploy.sh` script to the server and run it:

```
wget https://raw.githubusercontent.com/mattherman/website/master/deploy.sh
chmod +x ./deploy.sh
./deploy.sh
```
