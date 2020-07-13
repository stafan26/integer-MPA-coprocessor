source [lindex $argv 0]

launch_runs impl_1 -to_step write_bitstream -jobs 1
wait_on_run impl_1
open_run impl_1
report_design_analysis -timing -setup -max_path [lindex $argv 1] -logic_level_distribution -logic_level_dist_paths 300000 -congestion -name design_analysis_1 -file [lindex $argv 2]

exit
