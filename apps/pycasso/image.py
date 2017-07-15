from keras.preprocessing.image import load_img, img_to_array
from keras.applications.imagenet_utils import preprocess_input
from keras import backend as K
import numpy as np

def preprocess_image(image):
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    image = preprocess_input(image)
    return image

def deprocess_image(image, (rows, cols)):
    if K.image_dim_ordering() == 'th':
        image = image.reshape((3, rows, cols))
        image = image.transpose((1, 2, 0))
    else:
        image = image.reshape((rows, cols, 3))
    # Remove zero-center by mean pixel
    image[:, :, 0] += 103.939
    image[:, :, 1] += 116.779
    image[:, :, 2] += 123.68
    # 'BGR'->'RGB'
    image = image[:, :, ::-1]
    image = np.clip(image, 0, 255).astype('uint8')
    return image

def initial(config):
    (rows, cols) = config.img_size

    if config.initial == 'content':
        return preprocess_image(config.content)
    elif config.initial == 'style':
        return preprocess_image(config.style)
    # random image
    else:
        if K.image_dim_ordering() == 'th':
            return np.random.uniform(0, 255, (1, 3, rows, cols)) - 128.
        else:
            return np.random.uniform(0, 255, (1, rows, cols, 3)) - 128.
