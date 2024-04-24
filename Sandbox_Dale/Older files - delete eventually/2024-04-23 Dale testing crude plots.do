********************************************************************************
*
* Dale trying some quick and dirty ideas to show elements of a crude elbow plot
*
* Graphic choices are hardwired here; come back and use globals for flexibility.
*
* This mock-up shows data from card *and* register *and* recall, which is
* somewhat different than the v1 code.
*
* This mock-up also puts the tabular outcomes directly on the cartesian 
* space of the evidence, which is also different.
*
* This mock-up assigns each source (card, recall, register) a slightly
* different y-coordinate, which is maybe too distracting; the v1 code 
* puts it all at the same y-value and uses a line with 6 or 12 segments
* if there is evidence from numerous sources.  This is something to explore,
* but the proposed data structure would support either approach, or others.
*
* This code doesn't do any value checking and it doesn't manage the case 
* or any padded spaces around the data.  Come back and add those.
*
* This code doesn't make a legend; come back and add that.
*
*  Date       Who                 What
* 2024-04-23  Dale Rhoda          Original version
*
********************************************************************************

cd "E:/Biostat Global Dropbox/Dale Rhoda/DAR GitHub Repos/elbow_plots_v2_sandbox/Sandbox_Dale"

import delimited "../test_datasets/2024-04-23 Dale testing a crude plot data structure.csv", varnames(1) case(lower) clear

* Enforce variable type for strings
foreach v in dose card_tick_original card_hole card_tick_imputed register_tick_original register_hole register_tick_imputed recall bgc_scar crude_by_card crude_by_register crude_by_recall crude_by_anysource title subtitle footnote xtitle {
	capture tostring `v', replace
}

levelsof respid, local(rlist)

scalar xaxis_max = 750 // This will be a global later

foreach r in `rlist' {
	preserve
	keep if respid == `r'
	
	* Clear out the plotting local macros
	local grid
	local nsched
	local carddates
	local registerdates
	local tr
	local vlist
	local vlabel
	local tabular
	
	* Set up the value labels for the y-axis
	levelsof order, local(olist)
	forvalues i = 1/`=_N' {
		label define doselist `=order[`i']' "`=dose[`i']'", modify
	}
	label values order doselist
	
	* Highest label for x-axis
	local xmax_over_100 = 100*int(xaxis_max/100)
	
	* Code to plot the nominal schedule and value labels for y-axis
	* TODO: Come back and start with an empty plot and value labels
	* TODO: because currently we plot the nominal schedule twice so it 
	* TODO: is not covered by recall and tick evidence.  Needs fixed.
	
	summarize order
	local nsched (scatter order nominal_age, m(|) msize(small) mcolor(black) ylabel(`olist',valuelabel nogrid labsize(small) ) yscale(range(0,`r(max)')) xlabel(0(100)`xmax_over_100',nogrid labsize(small)) ytitle("") xtitle("`=xtitle[1]'", size(small)))
	
	* Local for faint horizontal line for every dose
	forvalues i = 1/`=_N' {
		local grid `grid' (scatteri `=order[`i']' 0 `=order[`i']' `=xaxis_max', m(i) connect(l) lwidth(vthin) lcolor(gs14) lpattern(solid))
	}
	
	* y-coordinates for card and register evidence
	gen ycard = order - .05
	gen ycardtick = order - .1
	gen yregister  = order + .05
	gen yregistertick = order + 0.1
	
	* Locals to plot dots for dates on cards and register
	local carddates (scatter ycard card_age, m(o) msize(small) mcolor(blue))
	local registerdates  (scatter yregister  register_age, m(o) msize(small) mcolor(orange))
	
	* Local for evidence recorded with ticks and recall
	local tr
	forvalues i = 1/`=_N' {
        if recall[`i'] == "y"                 local tr `tr' (scatteri `=order[`i']'         5   `=order[`i']'         `=xaxis_max - 5', m(i) connect(l) lwidth(thick) lcolor(red*.25))
		if card_tick_original[`i'] == "y" 	  local tr `tr' (scatteri `=ycardtick[`i']'     5   `=ycardtick[`i']'     `=xaxis_max - 5', m(i) connect(l) lwidth(thick) lcolor(blue*.25))
		if card_tick_imputed[`i'] == "y" 	  local tr `tr' (scatteri `=ycardtick[`i']'     5   `=ycardtick[`i']'     `=xaxis_max - 5', m(i) connect(l) lwidth(thick) lcolor(blue*0.25) lpattern(dash))
		if register_tick_original[`i'] == "y" local tr `tr' (scatteri `=yregistertick[`i']' 5   `=yregistertick[`i']' `=xaxis_max - 5', m(i) connect(l) lwidth(thick) lcolor(green*.25))
		if register_tick_imputed[`i'] == "y"  local tr `tr' (scatteri `=yregistertick[`i']' 5   `=yregistertick[`i']' `=xaxis_max - 5', m(i) connect(l) lwidth(thick) lcolor(green*0.25) lpattern(dash))
	}
	
	* Local for vertical lines at each visit and for age labels
	* at alternating y-coordinates near the base of the lines
	forvalues i = 1/`=_N' {
		local vlist `vlist' `=card_age[`i']' `=register_age[`i']'
	}
	local vlist `vlist' `=age_at_survey[1]' 
	local vlist : list sort vlist
	local vlist : list uniq vlist 
	local vlist `=subinstr("`vlist'","."," ",.)'
	if "`vlist'" != "" {
		numlist "`: list uniq vlist'", sort
		local vlist `=r(numlist)'
		local i 0
		foreach v in `vlist' {
			local ++i
			if mod(`i',2)==1 local vlabel `vlabel' text( 0.15 `v' "`v'", place(c) size(vsmall))
			else             local vlabel `vlabel' text( 0.45 `v' "`v'", place(c) size(vsmall))
		}
		local vlabel xline(`vlist', lc(gs12) lw(vthin)) `vlabel'
	}
	
	* Local to hold code to portray tabular information
	forvalues i = 1/`=_N' {
		if crude_by_card[`i']      == "y" local tabular `tabular' text( `=order[`i']' `=xaxis_max +  25' "C", place(c) size(small))
		else                              local tabular `tabular' text( `=order[`i']' `=xaxis_max +  25' ".", place(c) size(small))
		if crude_by_register[`i']  == "y" local tabular `tabular' text( `=order[`i']' `=xaxis_max +  50' "R", place(c) size(small))
		else                              local tabular `tabular' text( `=order[`i']' `=xaxis_max +  50' ".", place(c) size(small))
		if crude_by_recall[`i']    == "y" local tabular `tabular' text( `=order[`i']' `=xaxis_max +  75' "H", place(c) size(small))
		else                              local tabular `tabular' text( `=order[`i']' `=xaxis_max +  75' ".", place(c) size(small))
		if crude_by_anysource[`i'] == "y" local tabular `tabular' text( `=order[`i']' `=xaxis_max + 100' "Y", place(c) size(small))
		else                              local tabular `tabular' text( `=order[`i']' `=xaxis_max + 100' "N", place(c) size(small))
		if recall[`i'] == "dnk"           local tabular `tabular' text( `=order[`i']+0.2' `=xaxis_max/2' "DNK", place(c) size(vsmall))
	}
	
	* Make the plot, using all of the local macros defined above
	twoway `nsched' `grid' `tr' `nsched' `carddates' `registerdates'  ///
	, name(r`r', replace) legend(off)  `vlabel' `tabular' aspect(0.7) ///
	title("`=title[1]'", size()) subtitle("`=subtitle[1]'") ///
	note("`=footnote[1]'", size(vsmall)) ///
	xline(`=age_at_survey[1]', lpattern(solid) lcolor(gs12) lw(vthin))
	
	* Pad the resp_id for clean plot filenames
	local fr `r'
	if      `r' < 10     local fr 00000`r'
	else if `r' < 100    local fr 0000`r'
	else if `r' < 1000   local fr 000`r'
	else if `r' < 10000  local fr 00`r'
	else if `r' < 100000 local fr 0`r'
	
	graph export "crude_plot_for_respid_`fr'.png", width(2000) replace
	
	restore
}

* TODO: Code to create a legend.  (Re-use or adapt Mary's code.)