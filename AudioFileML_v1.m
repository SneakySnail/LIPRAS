% Parameters
fs = 44100; % Sampling frequency
duration = 1; % Duration of the audio signals (in seconds)
frequencies = [440, 880, 220]; % Frequencies of the sine waves

% Generate time vector
t = 0:1/fs:duration-1/fs;

% Generate sine wave audio signals
audio_signals = zeros(length(frequencies), length(t));
for i = 1:length(frequencies)
    audio_signals(i, :) = sin(2*pi*frequencies(i)*t);
end

% Split data into train, validation, and test sets
train_ratio = 0.6;
val_ratio = 0.2;
test_ratio = 0.2;

num_samples = size(audio_signals, 2);
num_train = round(train_ratio * num_samples);
num_val = round(val_ratio * num_samples);
num_test = num_samples - num_train - num_val;

train_data = audio_signals(:, 1:num_train);
val_data = audio_signals(:, num_train+1:num_train+num_val);
test_data = audio_signals(:, num_train+num_val+1:end);

% Display sizes of the sets
disp(['Number of samples in train set: ' num2str(num_train)]);
disp(['Number of samples in validation set: ' num2str(num_val)]);
disp(['Number of samples in test set: ' num2str(num_test)]);
