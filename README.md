# RedCraft packer

[Packer](https://packer.io) is a tool for building identical machine images for multiple platforms from a single source configuration.

## How to use it

### Configure first start provisioning

The first start provisioning script is ran when the image is actually deployed, not during the image build.

Make sure to run `cp common/tasks/first_start_provisioning.sh.example common/tasks/first_start_provisioning.sh` and edit the script to add your Netdata Cloud token and rooms, or even setup any other kind of monitoring. You can also use an empty file if you don't care about monitoring.

Please make sure that the script ends with `rm /etc/cron.d/first_start_provisioning` and `rm -- "$0"` or it will be provisioned at each boot!

### Generate image

To build an image, `cd` to the image directory and run the following command :
`packer build redcraft-*.json`

An alternative to setting environment variables is to define variables in the build command (not recommended, especially if you share your computer):
`packer build -var 'access_key=<access_key>' -var 'secret_key=<secret_key>' -var 'project_id=<project_id>' -var 'zone=<zone>' redcraft-*.json`

#### Special notes

##### `minecraft` image

The `redcraft-minecraft` image installs [rcsm](https://github.com/redcraft-org/redcraft_server_management) and you'll need to copy `rcsm_config.example` to `rcsm_config` and update the config to your needs.

You'll need to copy `wireguard.conf.example` to `wireguard.conf` to connect to your cloud provider private network. If you leave this file empty, WireGuard setup will be skipped.

You can setup a remote SSH server with the following command: `SSH_HOST=<ip address> SSH_USERNAME=<username> SSH_PASSWORD=<password> packer build redcraft-minecraft-ssh.json`

## Add your user account

To add your user account, you'll need the following things:

- Your username
- Your SSH public key
- Your encoded password (Can be generated with `mkpasswd -m sha-512`)

Once you have that information, create a JSON file as `common/users/<username>.json` like this:

```json
{
    "username": "<username>",
    "password_hash": "<password hash>",
    "public_key": "ssh-rsa <public key> <username>"
}
```

### bashrc profile (optional)

You can add a custom `.bashrc` for your user. You just have to add it as a plain text file, as `common/users/<username>.bashrc`.
