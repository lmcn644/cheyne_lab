title = getTitle();
directory = getDirectory("image");
folder = directory + File.separator + title+"_data"
File.makeDirectory(folder);

run("Split Channels");

selectImage("C1-"+title);
saveAs("Tiff", folder+"/background.tif");
close("background.tif");

selectImage("C2-"+title);
saveAs("Tiff", folder+"/synapsin.tif");  //check if synapsin or shank3
close("synapsin.tif");

selectImage("C3-"+title);
saveAs("Tiff", folder+"/shank3.tif");  //check if synapsin or shank3
close("shank3.tif");