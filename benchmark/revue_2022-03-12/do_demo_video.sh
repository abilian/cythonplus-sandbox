#!/bin/bash
clear
killall tail >/dev/null 2>&1
rm -f /tmp/httpd_plus.pid >/dev/null 2>&1
echo -e "\n\n"
echo 'Demonstration benchmark "Httpd-Plus"'
echo -e "\n\n"
echo 'Critère: dernières lignes du résultat, "Requests/sec" et "Transfer/sec"'
echo -e "\n\n"
echo "Matériel:"
sudo lshw -c cpu | grep -E "(product|configuration)"
echo -e "\n\n"
sleep 5
clear
echo "============================================================================"
echo "Test 1/6                                               (durée 30 secondes)  "
echo "Gunicorn + Whitenoise, 4 workers"
echo "Estimation: ~ 8k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/gu_wn_python_workers_4.sh
sleep 5
# echo -e "\n\n"
clear
echo "============================================================================"
echo "Test 2/6                                               (durée 30 secondes)  "
echo "Httpd-Plus, 4 workers"
echo "Estimation: ~ 4k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/httpd_plus_workers_4.sh
sleep 5
# echo -e "\n\n"
clear
echo "============================================================================"
echo "Test 3/6                                               (durée 30 secondes)  "
echo "Httpd-Plus, 16 workers"
echo "(Note: Gunicorn n'est pas efficace si workers > nb de cores)"
echo "Estimation: ~ 14k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/httpd_plus_workers_16.sh
sleep 5
# echo -e "\n\n"
clear
echo "============================================================================"
echo "Test 4/6                                               (durée 30 secondes)  "
echo "Test: Gunicorn + Whitenoise, 4 workers, petits fichiers (~4k)"
echo "Estimation: ~ 10k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/gu_wn_python_workers_4_small.sh
sleep 5
# echo -e "\n\n"
clear
echo "============================================================================"
echo "Test 5/6                                               (durée 30 secondes)  "
echo "Httpd-Plus, 16 workers, petits fichiers (~4k)"
echo "Estimation: ~ 36k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/httpd_plus_workers_16_small.sh
sleep 5
# echo -e "\n\n"
clear
echo "============================================================================"
echo "Test 6/6                                               (durée 30 secondes)  "
echo "Httpd-Plus, 20 workers, petits fichiers (~4k)"
echo "Estimation: ~ 42k Requests/sec"
echo "----------------------------------------------------------------------------"
echo
./bench_scripts/httpd_plus_workers_20_small.sh
sleep 5
echo -e "\n"
echo "The end."
