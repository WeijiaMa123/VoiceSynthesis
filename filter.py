# wave_filter_python.py

import pyaudio
import wave
import struct
import math

from myfunctions import clip16


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

p = pyaudio.PyAudio()

# Open audio stream
stream = p.open(
    format      = pyaudio.paInt16,
    channels    = 1,
    rate        = 41400,
    input       = False,
    output      = True )

i = 20
while i > 0:


    # Difference equations 
    y0 = a6*y6 + a5*y5 + a4*y4 + a3*y3 + a2*y2 + a1*y1
    print(y0)

    # Delays
    y6= y5
    y5 = y4
    y4 = y3
    y3 = y2
    y2 = y1
    y1 = y0
    # Compute output value
    output_value = int(clip16(y0))    # Integer in allowed range

    # Convert output value to binary data
    output_bytes = struct.pack('h', output_value)  

    # Write binary data to audio stream
    stream.write(output_bytes) 
    i -= 1                    


print('* Finished')

stream.stop_stream()
stream.close()
p.terminate()
