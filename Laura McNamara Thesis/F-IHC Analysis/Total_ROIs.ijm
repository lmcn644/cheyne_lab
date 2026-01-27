// Make sure current image stack is selected
title = getTitle();
filename = substring(title, 0, (lengthOf(title)-4));
//print(filename);

run("ROI Manager...");
roiManager("Open", "Z:/Data/Imaging/Myelin_Analysis/FINAL_FLUOROMYELIN_RED_x20/Z-Stack_ROIs/"+ filename +".zip");

for (i = 0; i < roiManager("count"); i++) { 
	roiManager("select", i);
	roiManager("measure");
}

saveAs("Results", "Z:/Data/Imaging/Myelin_Analysis/FINAL_FLUOROMYELIN_RED_x20/Total_Areas/"+filename+"_Total_Areas.csv");
run("Close All");
close("Results");
selectWindow("ROI Manager");
run("Close");