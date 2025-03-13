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
error = y-yhat

mean_e = np.mean(error)
s_e = np.std(error)
print("mean of error:", mean_e)
print("variance of error:", s_e)



# Plot results with two subplots
fig, axs = plt.subplots(3, 1, figsize=(10, 8), sharex=False)

# Plot actual vs. predicted
axs[0].plot(y, label="Actual", color="blue")
axs[0].plot(yhat, label="Predicted", color="red", linestyle="dashed")
axs[0].set_ylabel("Amplitude")
axs[0].set_title("Actual vs. Predicted Values")
axs[0].legend()
axs[0].grid()

# Plot error in separate subplot
axs[1].plot(error, label="Error", color="black")
axs[1].set_xlabel("Samples")
axs[1].set_ylabel("Error")
axs[1].set_title("Prediction Error")
axs[1].legend()
axs[1].grid()


# Plot histogram of error in third subplot
axs[2].hist(error, bins=50, color="gray", edgecolor="black", alpha=0.7)
axs[2].set_xlabel("Error Amplitude")
axs[2].set_ylabel("Frequency")
axs[2].set_title("Histogram of Prediction Error")
axs[2].set_xlim(-100, 100)  
axs[2].grid()



# Show the plots
plt.tight_layout()
plt.show()