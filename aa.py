import pyaudio
import wave
import struct

import numpy as np
import matplotlib.pyplot as plt


from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score

file_name = 'aa.wave'

wavefile = 'aa.wav'

# Open wave file (should be mono channel)
wf = wave.open( wavefile, 'rb' )

# Read the wave file properties
num_channels    = wf.getnchannels()     # Number of channels
RATE            = wf.getframerate()     # Sampling rate (frames/second)
length          = wf.getnframes()       # Signal length
width           = wf.getsampwidth()     # Number of bytes per sample

print('The file has %d channel(s).'            % num_channels)
print('The frame rate is %d frames/second.'    % RATE)
print('The file has %d frames.'                % length)
print('There are %d bytes per sample.'         % width)

a = np.zeros((length))

p = pyaudio.PyAudio()

# Open audio stream
stream = p.open(
    format      = pyaudio.paInt16,
    channels    = num_channels,
    rate        = RATE,
    input       = False,
    output      = True )

# Get first frame from wave file
 
input_bytes = wf.readframes(1)
i = 0
while len(input_bytes) > 0:

    # Convert binary data to number
    input_tuple = struct.unpack('h', input_bytes)  # One-element tuple
    input_value = input_tuple[0]
    a[i] = input_value
    output_value = input_value
    # Write binary data to audio stream
    output_bytes = struct.pack('h', output_value)  
    # Write binary data to audio stream
    stream.write(output_bytes)
    i += 1        
    input_bytes = wf.readframes(1)
             

print('* Finished')
print(a[0:20])
stream.stop_stream()
stream.close()
p.terminate()

num_poles = 6

X = np.zeros((length-6,6))
for i in range(length-6):
    X[i,:] = a[i:i+6]


y = a[6:]
regr = LinearRegression(fit_intercept=False)
regr.fit(X, y)

beta = regr.coef_
print(beta)

yhat = regr.predict(X)
print(y-yhat)
plt.figure(figsize=(10, 5))

# Plot actual values
plt.plot(y[0:100], label="Actual Values", color="blue")

# Plot predicted values
plt.plot(yhat[0:100], label="Predicted Values", color="red", linestyle="dashed")


plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.title("Actual vs. Predicted Values with Error Shading")
plt.legend()
plt.grid()

plt.show()
print(yhat[0:20])
print(y[0:20])