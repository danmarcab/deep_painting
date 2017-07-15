from keras.preprocessing.image import load_img, img_to_array
import argparse

def load():
    args = parse_args()
    config = expand(args)
    log_config(config)

    return config

def parse_args():
    parser = argparse.ArgumentParser(description='Apply style to a picture using a deep NN.')
    parser.add_argument('content_img', help='Path to the image to transform.')
    parser.add_argument('style_img', help='Path to the style image.')
    parser.add_argument('output_dir', help='Dir prefix for result images.')
    parser.add_argument('-r', '--runner', choices=['cli', 'port'], default='cli', help='Type of runner (cli or port).')
    parser.add_argument('-i', '--iterations', type=int, default=15, help='Iterations to run.')
    parser.add_argument('-it', '--initial_type', choices=['content', 'style', 'random'], default='content', help='Type of initial image (content, style or random).')
    parser.add_argument('-cw', '--content_weight', type=float, default=0.1, help='Content weight.')
    parser.add_argument('-sw', '--style_weight', type=float, default=100.0, help='Style weight.')
    parser.add_argument('-vw', '--variation_weight', type=float, default=1.0, help='Variation weight.')
    parser.add_argument('--output_width', type=int, default=400, help='Width of the output image in pixels.')

    return parser.parse_args()

def expand(config):
    w, h = load_img(config.content_img).size
    height = config.output_width
    img_size = (height, int(w * height / h))

    content = load_img(config.content_img, target_size=img_size)
    style = load_img(config.style_img, target_size=img_size)

    img = argparse.Namespace(content=content,
                             style=style,
                             img_size=img_size,
                             initial=config.initial_type)
    loss = argparse.Namespace(content_weight=config.content_weight,
                              style_weight=config.style_weight,
                              variation_weight=config.variation_weight,
                              img_size=img_size)

    output_dir = config.output_dir
    logger = argparse.Namespace(output_path=output_dir, img_size=img_size)

    optimizer = argparse.Namespace()
    runner = argparse.Namespace(type=config.runner, iterations=config.iterations, img_size=img_size, output_path=output_dir)

    return argparse.Namespace(img=img, loss=loss, optimizer=optimizer, logger=logger, runner=runner)

def log_config(config):
    f = open(config.logger.output_path + '/config.txt', 'w')
    f.write(str(config))
