# wave_filter_python.py

import pyaudio
import wave
import struct
import math
import numpy as np
from myfunctions import clip16
import matplotlib.pyplot as plt


a6 = 0.24511241
a5 = 0.07484454
a4 = -1.4823002 
a3 = 2.29845421
a2 = -2.63340862
a1 = 2.49555074



# Initialization
y6 = 1679
y5 = 1755
y4 = 1804
y3 = 1856
y2 = 1920
y1 = 1963
init_values = [1679, 1755, 1804, 1856, 1920, 1963]
p = pyaudio.PyAudio()

# Open audio stream
stream = p.open(
    format      = pyaudio.paInt16,
    channels    = 1,
    rate        = 41400,
    input       = False,
    output      = True )

i = 0
N = 20000
store_y = np.zeros(N+1)
freq = 300
# Create a zero array
x = np.zeros(N+1)

# Set ones at specified frequency
#x[::freq] = 2**10
num_repeat = 5

# Apply repeated values at specific intervals
for idx in range(1,num_repeat):
    pos = int(idx * (N / num_repeat))  # Ensure integer index
    if pos + 1 < N:  # Check to prevent out-of-bounds error
        x[pos] = init_values[0]
        x[pos + 1] = init_values[1]


while i < N:
    noise = np.random.normal(0,5)
    # y6 is the 6th before vaule
    # Difference equations 
    y0 = a6*y6 + a5*y5 + a4*y4 + a3*y3 + a2*y2 + a1*y1 + x[i] + noise
    #y0 = a6*y6 + a5*y5 + a4*y4 + a3*y3 + a2*y2 + a1*y1 + x[i-1] 


    # Delays
    y6= y5
    y5 = y4
    y4 = y3
    y3 = y2
    y2 = y1
    y1 = y0
    # Compute output value
    output_value = int(clip16(y0))    # Integer in allowed range
    #print(y0)
    store_y[i] = output_value

    # Convert output value to binary data
    output_bytes = struct.pack('h', output_value)  

    # Write binary data to audio stream
    stream.write(output_bytes) 
    i += 1                    


print('* Finished')

stream.stop_stream()
stream.close()
p.terminate()


plt.figure(figsize=(8, 4))
plt.plot(store_y)
plt.grid()
plt.show()