#!/usr/bin/python

from __future__ import print_function
from h5py._hl.base import find_item_type
from h5py._hl.dataset import ChunkIterator

import numpy as np
import h5py
import sys
import os

from numpy.core.fromnumeric import shape
from sqlalchemy.sql.expression import false


# data = np.fromfile(sys.argv[1], dtype='float32');
# data = np.reshape(data, (int(sys.argv[2]), int(sys.argv[3])));
# h5f = h5py.File(sys.argv[4], 'w');
# h5f.create_dataset('data', data=data)
# h5f.close()

# argv = ['bin2hdf5', './training/training.f32', '1000', '87', './training/training1.h5']
argv = sys.argv

# data = np.fromfile(sys.argv[1], dtype='float32');
# data = np.reshape(data, (int(sys.argv[2]), int(sys.argv[3])));
# h5f = h5py.File(sys.argv[4], 'w');
# h5f.create_dataset('data', data=data)
# h5f.close()

lenSample = int(argv[3])
maxIdx = int(argv[2])
stepIdx = 10000
offset = 0
if os.path.exists(argv[4]):
    os.remove(argv[4])
h5f = h5py.File(argv[4], 'a')
dset = h5f.create_dataset('data', (0,lenSample), chunks=True, maxshape=(None,lenSample))
fileIn = open(argv[1], 'rb')
# convert bin to h5 file
for a in range(0, maxIdx, stepIdx):
    offset = a
    data = fileIn.read(stepIdx*lenSample*4)
    # data = list(data)
    data = np.fromstring(data, 'float32')
    # data = np.fromfile(argv[1], dtype='float32', count=stepIdx*lenSample, offset=offset)
    data = np.reshape(data, (int(stepIdx), lenSample))
    dset.resize(dset.shape[0]+stepIdx, axis=0)   
    dset[-stepIdx:] = data
    print(dset.shape)
h5f.close()


# filename1 = "./training/training1.h5"
# filename = "./training/training.h5"

# with h5py.File(filename1, "r") as f1:
#     # List all groups
#     print("Keys: %s" % f1.keys())
#     a_group_key1 = list(f1.keys())[0]

#     # Get the data
#     data1 = list(f1[a_group_key1])
# with h5py.File(filename, "r") as f:
#     # List all groups
#     print("Keys: %s" % f.keys())
#     a_group_key = list(f.keys())[0]

#     # Get the data
#     data = list(f[a_group_key])
#     print(shape(data))
#     print(shape(data1))
#     print(np.array_equal(data1,data))
# pass