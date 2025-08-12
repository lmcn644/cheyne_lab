Roi.setPosition(1);
roiManager("Add");
title = getTitle();
run("Split Channels");
selectImage("C1-"+title);
close();
selectImage("C3-"+title);
close();
selectImage("C4-"+title);
close();
selectImage("C2-"+title);

setAutoThreshold("Default no-reset");
//run("Threshold...");
setThreshold(383.334, 65535, "raw");

roiManager("Select", 0);
run("Set Measurements...", "area mean min integrated limit redirect=None decimal=3");
run("Measure");
