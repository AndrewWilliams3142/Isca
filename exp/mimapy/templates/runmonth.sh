#!/usr/bin/env csh
# Run a single month

set npes             = 8


cd {{ workdir }}

cat >> input.nml <<EOF
 &main_nml
     days   = 30,
     hours  = 0,
     minutes = 0,
     seconds = 0,
     dt_atmos = 900,
     current_date = 0001,1,1,0,0,0
     calendar = 'thirty_day' /
EOF

# copy and extract the restart information

{% if restart_file %}
cd INPUT
cp {{ restart_file }} res
cpio -iv < res
cd {{ workdir }}
{% endif %}

cp {{ execdir }}/fms_moist.x fms_moist.x
mpirun  -np $npes fms_moist.x


# combine output files
foreach ncfile (`/bin/ls *.nc.0000`) #ncfile = i, for each i(`/bin/ls *.nc.0000`)
  {{ GFDL_BASE }}/postprocessing/mppnccombine.x $ncfile:r
  if ($status == 0) rm -f $ncfile:r.????  #r.???? eg nc.0003
end


