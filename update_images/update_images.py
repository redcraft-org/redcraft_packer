import os
import time
import json

from scaleway.apis import ComputeAPI

if __name__ == '__main__':
    image_prefix = os.environ.get('IMAGE_PREFIX')
    region = os.environ.get('SCALEWAY_REGION')
    auth_token = os.environ.get('SCALEWAY_AUTH_TOKEN')

    api = ComputeAPI(region=region, auth_token=auth_token)

    images = api.query().images.get().get('images')

    latest_images = {}

    base_image_family = '{}-base'.format(image_prefix)

    # Find newest images
    for image in images:
        if not image['name'].startswith(image_prefix):
            continue

        image_family = '-'.join(image['name'].split('-')[:-1])

        image_date = time.strptime(image['creation_date'].split('+')[0], '%Y-%m-%dT%H:%M:%S.%f')
        if not image_family in latest_images or latest_images[image_family]['date'] < image_date:
            latest_images[image_family] = {
                'id': image['id'],
                'date': image_date
            }

    # Delete images that are not the latest
    for image in images:
        if not image['name'].startswith(image_prefix):
            continue

        image_family = '-'.join(image['name'].split('-')[:-1])

        if latest_images.get(image_family, {}).get('id') != image['id']:
            api.query().images(image['id']).delete()
            api.query().snapshots(image['root_volume']['id']).delete()

    # Update .json packer configs with latest base image + reformating
    for image in os.listdir('../images'):
        packer_config = ''
        packer_config_filename = '../images/{image}/{image}.json'.format(image=image)
        with open(packer_config_filename, 'r') as packer_config_file:
            packer_config = json.load(packer_config_file)

        if image != base_image_family:
            packer_config['builders'][0]['image'] = latest_images[base_image_family]['id']

        with open(packer_config_filename, 'w') as packer_config_file:
            json.dump(packer_config, packer_config_file, indent=4, sort_keys=True)
