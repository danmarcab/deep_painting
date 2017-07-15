import config as cfg
import image
import loss
import optimizer as optim
import runner as run
from keras.layers import Input

from custom_vgg19 import VGG19
from keras import backend as K

config = cfg.load()

# load/init images
content_image = image.preprocess_image(config.img.content)
style_image = image.preprocess_image(config.img.style)
initial_image = image.initial(config.img)

# init model, evaluator and logger
initial_tensor = K.variable(initial_image)
model = VGG19(input_tensor=Input(tensor=initial_tensor))
evaluator = loss.Evaluator(model, config.loss, initial_tensor, content_image, style_image)
optimizer = optim.Optimizer(config.optimizer, evaluator, initial_image)

if config.runner.type == 'port':
    runner = run.PortRunner(config.runner, optimizer)
else:
    runner = run.CLIRunner(config.runner,optimizer)

# optimize!
(initial_loss, initial_grads) = evaluator.loss_and_grads(initial_image)
runner.run((initial_image.copy(), initial_loss))


