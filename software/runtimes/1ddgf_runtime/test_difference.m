clear

errLimit=-180;%dB

err_tmp = diffwaveformdb('./e_jdelta_dgf_trans.bin', './e_jdelta_trans.bin', 1000)
err=err_tmp;
err_tmp = diffwaveformdb('./h_jdelta_dgf_trans.bin', './h_jdelta_trans.bin', 1000)
err=[err err_tmp];
err_tmp = diffwaveformdb('./e_mdelta_dgf_trans.bin', './e_mdelta_trans.bin', 1000)
err=[err err_tmp];
err_tmp = diffwaveformdb('./h_mdelta_dgf_trans.bin', './h_mdelta_trans.bin', 1000)
err=[err err_tmp];

%TEST
errMax = max(err)
errMin = min(err)

if (errMax > errLimit)
	error('TEST FAILED');
else
	disp('TEST PASSED');
end
