fs = 48000;
duration = 10;

recorder = audiorecorder(fs, 16, 1);

disp('Recording started...');
recordblocking(recorder, duration);

voice = getaudiodata(recorder);

audiowrite('voice.wav', voice, fs);

disp('Recording saved!');
