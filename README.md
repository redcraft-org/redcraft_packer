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

Notice: As of 2020, RedCraft uses the `par-2` zone.

### Configure first start provisioning

The first start provisioning script is ran when the image is actually deployed, not during the image build.

Make sure to run `cp common/tasks/first_start_provisioning.sh.example common/tasks/first_start_provisioning.sh` and edit the script to add your Netdata Cloud token and rooms, or even setup any other kind of monitoring. You can also use an empty file if you don't care about monitoring.

Please make sure that the script ends with `rm /etc/cron.d/first_start_provisioning` and `rm -- "$0"` or it will be provisioned at each boot!

### Generate image

To build an image, `cd` to the image directory and run the following command :
`packer build redcraft-*.json`

An alternative to setting environment variables is to define variables in the build command (not recommended, especially if you share your computer):
`packer build -var 'access_key=<access_key>' -var 'secret_key=<secret_key>' -var 'project_id=<project_id>' -var 'zone=<zone>' redcraft-*.json`

Notice: all our images are based on Debian 10, and its Scaleway ID is `cc9188b3-3938-47d7-b091-c9ecad1fe507`
