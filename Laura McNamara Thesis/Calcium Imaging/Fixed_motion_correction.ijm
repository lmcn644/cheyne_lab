// Macro that adjusts the x-y positioning of all frames in a z-stack by a fixed amount. Used to supplement Normcorre.

//run("Images to Stack", "use");
run("In [+]");
run("In [+]");
run("In [+]");
//setTool("point");
run("ROI Manager...");

waitForUser("Select landmarks for pre- and post-correction, add both to ROI Manager");

roiManager("Select All");
roiManager("Measure");

Xi = getResult("X",0);
Xf = getResult("X",1);
Yi = getResult("Y",0);
Yf = getResult("Y",1);

Xshift = Xi-Xf;
Yshift = Yi-Yf;

waitForUser("Open stack to apply drift correction to");	

  macro "Translate..." {
      requires("1.34m");
      Dialog.create("Translate");
      Dialog.addNumber("X:", Xshift);
      Dialog.addNumber("Y:", Yshift);
      Dialog.show();
      x = Dialog.getNumber();
      y = Dialog.getNumber();
      for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    translate (x, y);
}
      
  }
  
  function translate(x, y) {
  	
      run("Select All");
      run("Cut");
      makeRectangle(x, y, getWidth(), getHeight());
      run("Paste");
      run("Select None");
  }

