directory = getDirectory("image");

//Select Shank3
selectWindow("shank3.tif");
run("Duplicate...", "duplicate");
run("Gaussian Blur...", "sigma=3 stack");
imageCalculator("Subtract create stack", "shank3.tif","shank3-1.tif");
selectWindow("Result of shank3.tif");
saveAs("Tiff", directory+"/shank3 in ROI.tif");
selectWindow("shank3 in ROI.tif");
run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D Objects Counter", "threshold=30 slice=1 min.=2 max.=40 objects statistics summary");
selectWindow("Statistics for shank3 in ROI.tif");
saveAs("Results", directory+"/Statistics for shank3 in ROI.csv");
selectWindow("Objects map of shank3 in ROI.tif");
run("16-bit");
saveAs("Tiff", directory+"/Objects map of shank3 in ROI.tif");

close("Statistics for shank3 in ROI.csv");
close("shank3 in ROI.tif");
close("shank3-1.tif");
close("shank3.tif");

//Select Synapsin
selectWindow("synapsin.tif");
run("Duplicate...", "duplicate");
run("Gaussian Blur...", "sigma=4 stack");
imageCalculator("Subtract create stack", "synapsin.tif","synapsin-1.tif");
selectWindow("Result of synapsin.tif");
saveAs("Tiff", directory+"/synapsin in ROI.tif");
selectWindow("synapsin in ROI.tif");
run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D Objects Counter", "threshold=55 slice=1 min.=2 max.=40 objects statistics summary");
selectWindow("Statistics for synapsin in ROI.tif");
saveAs("Results", directory+"/Statistics for synapsin in ROI.csv");
selectWindow("Objects map of synapsin in ROI.tif");
saveAs("Tiff", directory+"/Objects map of synapsin in ROI.tif");

setThreshold(1, 65535);
setThreshold(1, 65535);
run("Convert to Mask", "method=Default background=Dark");
run("Divide...", "value=255.000 stack");
run("16-bit");
saveAs("Tiff", directory+"/synapsin in ROI Mask.tif");

close("backgroundmask.tif");
close("Statistics for synapsin in ROI.csv");
close("synapsin in ROI.tif");
close("synapsin-1.tif");
close("synapsin.tif");

//Shank3 Colocalised with Synapsin in ROI
imageCalculator("Multiply create stack", "Objects map of shank3 in ROI.tif","synapsin in ROI Mask.tif");
selectWindow("Result of Objects map of shank3 in ROI.tif");
run("3D Objects Counter", "threshold=1 slice=5 min.=1 max.=25600000 objects statistics summary");
selectWindow("Statistics for Result of Objects map of shank3 in ROI.tif");
saveAs("Results", directory+"/Stats for Colocalised shank3 in ROI for test.csv");
selectWindow("Objects map of Result of Objects map of shank3 in ROI.tif");
saveAs("Tiff", directory+"/Colocalised Object Map.tif");

close("Objects map of shank3 in ROI.tif");
close("synapsin in ROI Mask.tif");
close("Stats for Colocalised shank3 in ROI for test.csv");
close("Result of Objects map of shank3 in ROI.tif");
close("Colocalised Object Map.tif");
