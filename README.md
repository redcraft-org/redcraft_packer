# RedCraft packer

[Packer](https://packer.io) is a tool for building identical machine images for multiple platforms from a single source configuration.

## How to use it

### Set up Scaleway environment

We build all our images for Scaleway, so you'll need a Scaleway account.

You need to make sure the following environment variables are defined (you can generate credentials from [the Scaleway console](https://console.scaleway.com/project/credentials)):

- `SCW_ACCESS_KEY`
- `SCW_SECRET_KEY`
- `SCW_DEFAULT_PROJECT_ID`
- `SCW_DEFAULT_ZONE`

Notice: As of 2020, RedCraft uses the `fr-par-1` zone.

### Generate image

To build an image, `cd` to the image directory and run the following command :
`packer build redcraft-*.json`

An alternative to setting environment variables is to define variables in the build command (not recommended, especially if you share your computer):
`packer build -var 'access_key=<access_key>' -var 'secret_key=<secret_key>' -var 'project_id=<project_id>' -var 'zone=<zone>' redcraft-*.json`
