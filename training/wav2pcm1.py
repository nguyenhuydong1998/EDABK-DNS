import numpy as np
from scipy.io import wavfile as wave 
from scipy import signal 
import os
import soundfile
import librosa

# this function is to convert float to pcm, we use float32 type because librosa.load() is used to Load an audio file as a floating point time series.
def float2pcm(sig, dtype='int16'):
    """Convert floating point signal with a range from -1 to 1 to PCM.
    Any signal values outside the interval [-1.0, 1.0) are clipped.
    No dithering is used.
    Note that there are different possibilities for scaling floating
    point numbers to PCM numbers, this function implements just one of
    them.  For an overview of alternatives see
    http://blog.bjornroche.com/2009/12/int-float-int-its-jungle-out-there.html
    """
    i = np.iinfo(dtype)
    abs_max = 2 ** (i.bits - 1)
    offset = i.min + abs_max
    return (sig * abs_max + offset).clip(i.min, i.max).astype(dtype)
    

# this function is to convert pcm to float, which is used to check the output files
def pcm2float(sig, dtype='float32'):
    """Convert PCM signal to floating point with a range from -1 to 1.
    Use dtype='float32' for single precision.
    """
    i = np.iinfo(sig.dtype)
    abs_max = 2 ** (i.bits - 1)
    offset = i.min + abs_max
    return (sig.astype(dtype) - offset) / abs_max

def float_to_byte(sig):
    # float32 -> int16(PCM_16) -> byte
    return  float2pcm(sig, dtype='int16').tobytes()

def byte_to_float(byte):
    # byte -> int16(PCM_16) -> float32
    return pcm2float(np.frombuffer(byte,dtype=np.int16), dtype='float32')

if __name__ == "__main__":
    y,sr = librosa.load('Soft Piano Music_16000_mono.wav',sr=48000)
    # convert to byte(PCM16)
    byt = float_to_byte(y)
    # save to pcm file
    with open("1.pcm","wb") as f:
        f.write(byt)

    #test
    # read pcm file
    with open("1.pcm","rb") as f:
        byt = f.read()
    # byte(PCM16) to float32
    f = byte_to_float(byt)
    # save float32 to PCM16 with soundfile
    soundfile.write("2.wav",f,48000,'PCM_16')



