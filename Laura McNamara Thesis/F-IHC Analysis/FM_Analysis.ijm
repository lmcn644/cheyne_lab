// Make sure current image stack is selected
title = getTitle();
filename = substring(title, 0, (lengthOf(title)-4));
//print(filename);

setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setAutoThreshold("Default dark no-reset stack");
setThreshold(21.81455921, 255, "raw");  //CHANGE VALUES AFTER OPTIMISATION

run("ROI Manager...");
roiManager("Open", "Z:/Data/Imaging/Myelin_Analysis/FINAL_FLUOROMYELIN_RED_x20/Z-Stack_ROIs/"+ filename +".zip");

for (i = 0; i < roiManager("count"); i++) { 
	roiManager("select", i);
	roiManager("measure");
}

saveAs("Results", "Z:/Data/Imaging/Myelin_Analysis/FINAL_FLUOROMYELIN_RED_x20/FM_Analysis/"+filename+"_FM_Analysis.csv");
run("Close All");
close("Results");
selectWindow("ROI Manager");
run("Close");