import numpy as np
from keras import backend as K

class Evaluator(object):

    def __init__(self, model, config, combination_image):
        self.loss_value = None
        self.grads_values = None
        rows, cols = config.img_size
        self.rows = rows
        self.cols = cols

        outputs_dict = dict([(layer.name, layer.output) for layer in model.layers])

        loss = K.variable(0.)
        layer_features = outputs_dict['block5_conv2']
        content_features = layer_features[0, :, :, :]
        combination_features = layer_features[2, :, :, :]
        loss += config.content_weight * self.content_loss(content_features, combination_features)

        feature_layers = ['block1_conv1', 'block2_conv1',
                          'block3_conv1', 'block4_conv1',
                          'block5_conv1']
        for layer_name in feature_layers:
            layer_features = outputs_dict[layer_name]
            style_features = layer_features[1, :, :, :]
            combination_features = layer_features[2, :, :, :]
            sl = self.style_loss(style_features, combination_features)
            loss += (config.style_weight / len(feature_layers)) * sl
        loss += config.variation_weight * self.total_variation_loss(combination_image)

        # get the gradients of the generated image wrt the loss
        grads = K.gradients(loss, combination_image)

        outputs = [loss]
        if isinstance(grads, (list, tuple)):
            outputs += grads
        else:
            outputs.append(grads)

        self.f_outputs = K.function([combination_image], outputs)

    def loss_and_grads(self, x):
        if K.image_data_format() == 'channels_first':
            x = x.reshape((1, 3, self.rows, self.cols))
        else:
            x = x.reshape((1, self.rows, self.cols, 3))
        outs = self.f_outputs([x])
        loss_value = outs[0]
        if len(outs[1:]) == 1:
            grad_values = outs[1].flatten().astype('float64')
        else:
            grad_values = np.array(outs[1:]).flatten().astype('float64')

        print '*'

        return loss_value, grad_values

    def loss(self, x):
        assert self.loss_value is None
        loss_value, grad_values = self.loss_and_grads(x)
        self.loss_value = loss_value
        self.grad_values = grad_values
        return self.loss_value

    def grads(self, x):
        assert self.loss_value is not None
        grad_values = np.copy(self.grad_values)
        self.loss_value = None
        self.grad_values = None
        return grad_values


    def gram_matrix(self, x):
        assert K.ndim(x) == 3
        if K.image_data_format() == 'channels_first':
            features = K.batch_flatten(x)
        else:
            features = K.batch_flatten(K.permute_dimensions(x, (2, 0, 1)))
        gram = K.dot(features, K.transpose(features))
        return gram

    def style_loss(self, style, combination):
        assert K.ndim(style) == 3
        assert K.ndim(combination) == 3
        S = self.gram_matrix(style)
        C = self.gram_matrix(combination)
        channels = 3
        size = self.rows * self.cols
        return K.sum(K.square(S - C)) / (4. * (channels ** 2) * (size ** 2))

    def content_loss(self, content_features, combination):
        return K.sum(K.square(combination - content_features))

    def total_variation_loss(self, x):
        assert K.ndim(x) == 4
        if K.image_data_format() == 'channels_first':
            a = K.square(x[:, :, :self.rows - 1, :self.cols - 1] - x[:, :, 1:, :self.cols - 1])
            b = K.square(x[:, :, :self.rows - 1, :self.cols - 1] - x[:, :, :self.rows - 1, 1:])
        else:
            a = K.square(x[:, :self.rows - 1, :self.cols - 1, :] - x[:, 1:, :self.cols - 1, :])
            b = K.square(x[:, :self.rows - 1, :self.cols - 1, :] - x[:, :self.rows - 1, 1:, :])
        return K.sum(K.pow(a + b, 1.25))
