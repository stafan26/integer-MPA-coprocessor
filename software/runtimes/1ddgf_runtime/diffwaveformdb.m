% Difference plotter developed as a part of the project:
% Advanced Simulation Methods for Electromagnetic Exposure Assessment
% supported by Foundation for Polish Science 2011-2013



function difference=diffwaveformdb(filename1, filename2, range)

plot_charts=0;

fptr1=fopen(filename1);
fptr2=fopen(filename2);%reference point



[array, nx]=fread(fptr1,'double');
[reference, mx]=fread(fptr2,'double');


if (nx~=mx)
	error('wrong data size!');
end

array=array(1:range);
reference=reference(1:range);

%%% plot charts
if plot_charts
    max_ref=max(abs(reference));
    c=20*log10( abs(array-reference)/max_ref );
    subplot(2,1,1);
    plot(c);
    title('1D error chart');
    xlabel('t (iteration)');
    ylabel('difference (dB)');

    subplot(2,1,2);
    plot(1:nx, array, 1:mx, reference);
end
%%%

% difference=20*log10( norm(array-reference)/norm(reference) );
difference=20*log10( max( abs(array-reference)/max(abs(reference)) ) );

fclose(fptr1);
fclose(fptr2);