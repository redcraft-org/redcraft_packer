import os
import time
import json

from scaleway.apis import ComputeAPI

if __name__ == '__main__':
    image_prefix = os.environ.get('IMAGE_PREFIX', 'redcraft')
    region = os.environ.get('SCW_DEFAULT_REGION')
    secret_key = os.environ.get('SCW_SECRET_KEY')

    if not image_prefix:
        print('Please set IMAGE_PREFIX in order to get this script running')
        exit(1)

    api = ComputeAPI(region=region, auth_token=secret_key)

    images = api.query().images.get().get('images')

    latest_images = {}

    stats = {
        'scanned': 0,
        'deleted': 0,
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

    print('Scanned {scanned} image(s) and deleted {deleted} image(s)'.format(**stats))
