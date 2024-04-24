## Background

Biostat Global Consulting developed the idea for elbow plots in 2017 and wrote Stata code to produce them in 2018.  Some of the ideas that underlie them are documented in the supplement to [this 2021 paper](https://doi.org/10.3390/vaccines9070795).  In formal settings we call them "vaccination evidence and indicator plots".  They are quite useful for confirming that VCQI is assigning the correct indicator outcomes to individual children and we can make faux data to check how VCQI handles any combination of inputs.

In 2024 we want to revisit the elbow plot code to accomplish several goals:
1. Simplify the code; separate code that does calculations from code that does visualization.
   (This will allow us to base the visualization code on datasets that already hold everything needed for visualization.)
2. Give Biostat staff and our collaborators a chance to write elbow plot code in R.
3. Modify the plots to show some additional features:
	a) show card and register and recall data all on a single figure
	b) show original holes in evidence and indicate where VCQI filled them
	c) show when card or register has the same date for two doses in a series
	d) show when card or register has a vx date that is out-of-bounds so later changed to tick
	e) Features (b-d) might be put into a new type of plot; something like a 'data quality' plot
5. Flexibility for other ideas.

Toward that end, Dale is spending some time defining the data elements that need to be present in datasets to reproduce some of the current types of elbow plot, starting with crude plots and crude MOV plots.  This is an unpaid side activity, so will proceed at an irregular pace.

We're setting up a GitHub site to hold code and datasets for use by our team and collaborators.

We will start documenting some progress here.

## Activities

### 2024-04-23
- Dale creates file of faux crude plot data for three children for working out some ideas.  Feel free to suggest other data elements.  The file is in:
  ~/test_datasets/2024-04-23 Dale testing a crude plot data structure.xlsx 
  (has a codebook sheet) and .csv (no codebook)
- Dale creates a simple Stata .do file to read that data structure and plot
	- axes with doses in order
	- date and tick evidence from card and register 
	  (with different line type for original vs. imputed ticks)
	  (I think I am convolving elements from our current crude plot and my idea for a new data quality plot...may need to come back and disentangle these ideas.)
	- recall evidence (yes and do not know)
	- lines and labels to indicate age at vaccination visits and age at survey
	- Tabular outcomes from VCQI RI_COVG_01 indicator
	- Title, subtitle, footnote, x-axis label all passed through from dataset
- Of course the info could be represented in many other ways, this code is a quick start to convince myself that the data structure supports what I want to portray.
- Still TO DO:
	1. Add code that makes a legend
	2. All style choices are hard-coded here; go back and use the named Stata global macros so the user has flexibility over most elements


At this time I think the data structure holds everything we need to show what evidence VCQI takes into its calculations.  I have this new idea of making a figure that shows what evidence was passed into VCQI and the limited circumstances where VCQI modifies the evidence and imputes tick marks, and why.  We might call that a DQ elbow plot.  That will probably require some different data elements.  

### 2024-04-24
- Made a few small improvements to the code and data structure; it is ready to share now.
