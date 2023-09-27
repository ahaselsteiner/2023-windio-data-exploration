# Exploration of two WindIO datasets
This repo contains a Matlab script for exploration of two vibration datasets:
 * the first dataset containts acceleration data from the Krogmann wind turbine in Bremerhaven.
 * the second dataset contains acceleration data from a Senvion wind turbine in Bremen.

Run the file `analyze_msb_and_lidar.m`

The datasets are not public such that you need to contact Andreas (a.haselsteiner@uni-bremen.de) to ask for the datasets to successfully run this script.
You can look at .gitignore to see which parts of this project are not in the public domain.

In addition
 * the repo contains lidar-based wind measurements covering the same time as the Krogmann vibration data (`lidar.mat`)
 * and lidar data from August 16 and 17 in the original ZX300 data format (`Wind_1082@Y2023_M08_D16.CSV`, `Wind_1082@Y2023_M08_D17.CSV`). No vibration data are available for that time period.

Please note that is a data analysis script and not a polished software.
