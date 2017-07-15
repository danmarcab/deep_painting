from scipy.optimize import fmin_l_bfgs_b
import time

class Optimizer(object):

    def __init__(self, config, evaluator, x):
        self.config = config
        self.x = x
        self.loss = None
        self.evaluator = evaluator

    def optimize(self):
        x, loss, info = fmin_l_bfgs_b(self.evaluator.loss, self.x.flatten(),
                                         fprime=self.evaluator.grads, maxfun=20)
        self.x = x
        self.loss = loss

        return (x.copy(), loss)

