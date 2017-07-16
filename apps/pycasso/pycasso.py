import config as cfg
import image
import loss
import optimizer as optim
import runner as run

from keras.applications import vgg19

from keras import backend as K

config = cfg.load()

# load/init images
content_image = image.preprocess_image(config.img.content)
style_image = image.preprocess_image(config.img.style)
initial_image = image.initial(config.img)

combination_image = image.combination_image(config.img)

# init model, evaluator and logger
input_tensor = K.concatenate([content_image,
                              style_image,
                              combination_image], axis=0)

model = vgg19.VGG19(input_tensor=input_tensor,
                    weights='imagenet', include_top=False)
evaluator = loss.Evaluator(model, config.loss, combination_image)
optimizer = optim.Optimizer(config.optimizer, evaluator, initial_image)

if config.runner.type == 'port':
    runner = run.PortRunner(config.runner, optimizer)
else:
    runner = run.CLIRunner(config.runner, optimizer)

# optimize!
(initial_loss, initial_grads) = evaluator.loss_and_grads(initial_image)
runner.run((initial_image.copy(), initial_loss))


