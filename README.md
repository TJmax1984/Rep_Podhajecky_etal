# Rep_Podhajecky_etal
In this depository there is code to analyze ring ingression from midplane movies manually and to plot it.

FOR ANALYZING RING INGRESSION FROM A SINGLE MIDPLANE SLICE:

1. prepare data. All for each condition should go in one path, with 1 subfolder for each embryo, how they are named is not important for this code
2. In each subfolder there should be a midplane tif file time series
3. there should be ONLY ONE tif file in the folder, it should be a tif file, not a tiff file
4. in addition there should be a paramters.txt file in each folder. In this parameters.txt file there should be the following info organized like in the following example: 'rotation 70 anaphase 58 last 66'. Rotation = rotation required to align the AP axis horizontally, anaphase: timeframe when anaphase starts, last = last timepoint (ring closure).
5. Run the Ring\_ingression\_analysis.m code. This should be done for EACH condition to be analyzed separately
6. Specify the pixel size (in um) and the time interval (dt, in s) in the pop up window that appears when running Ring\_ingression\_analysis.m.
7. then specify the path in the pop up window that appears when running Ring\_ingression\_analysis.m
8. The user subsequently has to manually click on the 2 protruding fronts of the ring. 
9. Running Ring\_ingression\_analysis.m returns Ring\_closure.mat files in each embryo directory. This will subsequently be used by cytokinesis\_analysis.m for extracting all the data.
10. Now run the cytokinesis_analysis.m code. This can be done once for all the conditions in the experiemnt that you want to compare.  
11. A GUI pop-up window appears in which you have to specify the number of conditions, followed by another pop-up window in which the conditions, conditions names, and various other parameters are specified.
12. You can choose to have a temp shift experiment analyzed, in case different quantities will be extracted than when you extract data from 'normal' constant temp experiments.
13. The code returns one large data table in which various quantities are saved. It saves this data table as mat file and csv file in the directory 1 upstream of the first condition.
14. The code also returns single quantity plots: duration of cytokinesis, mean ingression velocity, fluo density ratio (end/begin)   
15. The code also returns traces: density in the ring over time, ring diameter over time, ring diameter vs density, under different normalization/binning routines.     
16. Plots are saved as fig and png files in the same directory. 
