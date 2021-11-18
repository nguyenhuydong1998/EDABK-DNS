from __future__ import print_function

from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from keras.layers import GRU
from keras.models import load_model
from keras import backend as K

filename = 'training/weights.hdf5'

def mean_squared_sqrt_error(y_true, y_pred):
    return K.mean(K.square(K.sqrt(y_pred) - K.sqrt(y_true)), axis=-1)
def foo(c, name):
    return None
model = load_model(filename, custom_objects={'msse': mean_squared_sqrt_error, 'mean_squared_sqrt_error': mean_squared_sqrt_error, 'my_crossentropy': mean_squared_sqrt_error, 'mycost': mean_squared_sqrt_error, 'WeightClip': foo})

weights = model.get_weights()
print(model.summary())
pass