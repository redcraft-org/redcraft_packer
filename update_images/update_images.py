import os
import time
import json

from scaleway.apis import ComputeAPI

if __name__ == '__main__':
    image_prefix = os.environ.get('IMAGE_PREFIX')
    region = os.environ.get('SCALEWAY_REGION')
    auth_token = os.environ.get('SCALEWAY_AUTH_TOKEN')

    if not image_prefix:
        print('Please set IMAGE_PREFIX in order to get this script running')
        exit(1)

    api = ComputeAPI(region=region, auth_token=auth_token)

    images = api.query().images.get().get('images')

    latest_images = {}

    base_image_family = '{}-base'.format(image_prefix)

    stats = {
        'scanned': 0,
        'deleted': 0,
        'updated': 0,
        'already_updated': 0,
    }

    # Find newest images
    for image in images:
        if not image['name'].startswith(image_prefix):
            continue

        stats['scanned'] += 1

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

            stats['deleted'] += 1

    # Update .json packer configs with latest base image + reformating
    for image in os.listdir('../images'):
        packer_config = ''
        packer_config_filename = '../images/{image}/{image}.json'.format(image=image)
        with open(packer_config_filename, 'r') as packer_config_file:
            packer_config = json.load(packer_config_file)

        if image != base_image_family:
            if packer_config['builders'][0]['image'] != latest_images[base_image_family]['id']:
                stats['updated'] += 1
                packer_config['builders'][0]['image'] = latest_images[base_image_family]['id']
            else:
                stats['already_updated'] += 1

        with open(packer_config_filename, 'w') as packer_config_file:
            json.dump(packer_config, packer_config_file, indent=4, sort_keys=True)

    print('Scanned {scanned} image(s), deleted {deleted} image(s), updated {updated} image(s) - {already_updated} already updated'.format(**stats))
