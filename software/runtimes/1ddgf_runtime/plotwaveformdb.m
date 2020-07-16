% Waveform plotter developed as a part of the project:

% Advanced Simulation Methods for Electromagnetic Exposure Assessment

% supported by Foundation for Polish Science 2011-2013



function plotwaveformdb(filename)



fptr=fopen(filename);

[array, nx]=fread(fptr,'double');

plot(array);


xlabel('t (iteration)');

ylabel('field value');


fclose(fptr);
