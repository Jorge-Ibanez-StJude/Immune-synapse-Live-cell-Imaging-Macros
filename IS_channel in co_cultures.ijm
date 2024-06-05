/////Channel order definition (please modify accordingly)
c1=1;///T cell
c2=2;///Calcium
c3=3;///Tumor

///open folder
setOption("JFileChooser", true);
dir= getDirectory("Choose cell's folder");///to get directory that contains the images
File.makeDirectory(dir+File.separator+"Z_IS_Images");///to create a new folder with the segmentated images
imagenames=getFileList(dir); ///list with the name of all images to process
nbimages=lengthOf(imagenames); ///number of images to analyze
setOption("BlackBackground", false);

for(image=0; image<nbimages-1; image++) { /// Loop to analyze cells	
	name=imagenames[image];
	totnamelength=lengthOf(name);
	namelength=totnamelength-4;
	name1=substring(name, 0, namelength);
	extension=substring(name, namelength, totnamelength);
	print(image+","+name);
	open(dir+name);
	run("Duplicate...", "title=Tcell duplicate channels="+c1);
	selectWindow(name);
	run("Duplicate...", "title=Calcium duplicate channels="+c2);
	selectWindow(name);
	run("Duplicate...", "title=Tumor duplicate channels="+c3);
	selectWindow(name);
	run("Split Channels");	
	wait(120);	
	///T cell segmentation
	selectWindow("Tcell");
	setThreshold(200, 65535);/// Please adjust	
	run("Convert to Mask", "method=Default background=Dark");
	close("Threshold");
	selectWindow("Tcell");
	run("Erode", "stack");
	run("Dilate", "stack");
	wait(50);
	///Tumor cell segmentation
	selectWindow("Tumor");
	setThreshold(400, 65535);/// Please adjust	
	run("Convert to Mask", "method=Default background=Dark");
	close("Threshold");
	selectWindow("Tumor");
	run("Erode", "stack");
	run("Dilate", "stack");
	wait(50);
	/// Creation of T cell mask
	selectWindow("Tcell");
	run("Duplicate...", "duplicate title=Tcell2");
	run("8-bit");
	imageCalculator("Divide create stack", "Tcell","Tcell2");
	selectWindow("Result of Tcell");
	rename("Tcell_mask");
	run("16-bit");		
	wait(50);	
	/// T cell calcium flux segmented channel
	imageCalculator("Divide create stack", "Calcium","Tcell_mask");
	selectWindow("Result of Calcium");
	rename("Tcell_Calcium");
	run("16-bit");		
	/// Immune synapse channel (intersection between T cell and Tumor cells
	imageCalculator("AND create stack","Tumor", "Tcell");
	selectWindow("Result of Tumor");
	rename("Synapse");	
	run("16-bit");	
	//// merging and saving teh segmented image
	wait(50);
	close("Tcell");
	close("Tcell2");
	close("Tcell_mask");
	close("Tumor");	
	close("Calcium");	
	run("Merge Channels...", "c1=[C1-"+name+"] c2=[C2-"+name+"] c3=[C3-"+name+"] c4=[Synapse] c5=[Tcell_Calcium] create ignore");
	saveAs("Tiff", dir+File.separator+"Z_IS_Images"+File.separator+name);    
	run("Close");			
}

