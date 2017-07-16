from __future__ import print_function

from scipy.misc import imsave
import image

import os
import struct
import json

class BasicRunner(object):
    def __init__(self, config, optimizer):
        self.config = config
        self.optimizer = optimizer

    def run(self, (initial_image, initial_loss)):
        self.save_image(initial_image, 'iteration_0.png')
        for i in range(self.config.iterations):
            self.run_once(i + 1)

    def run_once(self, iteration):
        (img, loss) = self.optimizer.optimize()
        file_name = self.save_image(img, 'iteration_%d.png' % iteration)
        return self.log_img(iteration, file_name, loss)

    def log_img(self, iteration, file_name, loss):
        return

    def save_image(self, img, name):
        img = image.deprocess_image(img, self.config.img_size)
        file_name = self.config.output_path + '/' + name
        imsave(file_name, img)
        return os.path.abspath(file_name)

class CLIRunner(BasicRunner):
    def log_img(self, iteration, file_name, loss):
        print('Iteration %d finished!' % iteration)
        print('Image saved as: ', file_name)
        print('Current loss: ', loss)


class PortRunner(BasicRunner):
    def __init__(self, config, optimizer):
        super(PortRunner, self).__init__(config, optimizer)
        self.input = 3
        self.output = 4
        self.packet_size = 4

    def run(self, (initial_image, initial_loss)):
        file_name = self.save_image(initial_image, 'iteration_0.png')
        self.send_response(self.log_img(0, file_name, initial_loss))
        n = 0
        while True:
            input_received = self.receive_input()
            if input_received == "CONT":
                n += 1
                response = self.run_once(n)
                self.send_response(response)
            else:
                break

    def log_img(self, iteration, file_name, loss):
        response = json.dumps({'iteration': iteration, 'file_name': file_name, 'loss': str(loss)})
        f = open(file_name + '.log', 'w')
        f.write(str(response))
        print(response)
        return response

    def receive_input(self):
        encoded_length = os.read(self.input, self.packet_size)

        if encoded_length == "":
            return None
        else:
            (length,) = struct.unpack(">I", encoded_length)
            return os.read(self.input, length)

    def send_response(self, response):
        os.write(self.output, struct.pack(">I", len(response)))
        os.write(self.output, response)